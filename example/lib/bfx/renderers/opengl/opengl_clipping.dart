import 'dart:typed_data';

import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/plane.dart';

import 'opengl_properties.dart';

class OpenGLClipping {
  OpenGLProperties properties;
  late OpenGLClipping scope;
  dynamic globalState;
  dynamic numGlobalPlanes = 0;
  bool localClippingEnabled = false;
  bool renderingShadows = false;

  Plane plane = Plane();
  Matrix3 viewNormalMatrix = Matrix3();
  Map uniform = {
    'value': null,
    'needsUpdate': false,
  };

  dynamic numPlanes = 0;
  dynamic numIntersection = 0;

  OpenGLClipping(this.properties) {
    scope = this;
  }

  init(planes, enableLocalClipping, camera) {
    final enabled = planes.length != 0 ||
        enableLocalClipping ||
        // enable state of previous frame - the clipping code has to
        // run another frame in order to reset the state:
        numGlobalPlanes != 0 ||
        localClippingEnabled;

    localClippingEnabled = enableLocalClipping;

    globalState = projectPlanes(planes, camera, 0);
    numGlobalPlanes = planes.length;

    return enabled;
  }

  beginShadows() {
    renderingShadows = true;
    projectPlanes(null);
  }

  endShadows() {
    renderingShadows = false;
    resetGlobalState();
  }

  setState(material, camera, useCache) {
    final planes = material.clippingPlanes,
        clipIntersection = material.clipIntersection,
        clipShadows = material.clipShadows;

    final materialProperties = properties.get(material);

    if (!localClippingEnabled || planes == null || planes.length == 0 || renderingShadows && !clipShadows) {
      // there's no local clipping

      if (renderingShadows) {
        // there's no global clipping

        projectPlanes(null);
      } else {
        resetGlobalState();
      }
    } else {
      final nGlobal = renderingShadows ? 0 : numGlobalPlanes, lGlobal = nGlobal * 4;

      var dstArray = materialProperties.clippingState ?? null;

      uniform['value'] = dstArray; // ensure unique state

      dstArray = projectPlanes(planes, camera, lGlobal, useCache);

      for (var i = 0; i != lGlobal; ++i) {
        dstArray[i] = globalState[i];
      }

      materialProperties.clippingState = dstArray;
      numIntersection = clipIntersection ? numPlanes : 0;
      numPlanes += nGlobal;
    }
  }

  resetGlobalState() {
    if (uniform['value'] != globalState) {
      uniform['value'] = globalState;
      uniform['needsUpdate'] = numGlobalPlanes > 0;
    }

    scope.numPlanes = numGlobalPlanes;
    scope.numIntersection = 0;
  }

  projectPlanes([planes, camera, dstOffset, skipTransform]) {
    final nPlanes = planes != null ? planes.length : 0;
    var dstArray;

    if (nPlanes != 0) {
      dstArray = uniform['value'];

      if (skipTransform != true || dstArray == null) {
        final flatSize = dstOffset + nPlanes * 4, viewMatrix = camera.matrixWorldInverse;

        viewNormalMatrix.getNormalMatrix(viewMatrix);

        if (dstArray == null || dstArray.length < flatSize) {
          dstArray = Float32List(flatSize);
        }

        for (var i = 0, i4 = dstOffset; i != nPlanes; ++i, i4 += 4) {
          plane.copy(planes[i]).applyMatrix4(viewMatrix, viewNormalMatrix);

          plane.normal.toArray(dstArray as List<double>, i4);
          dstArray[i4 + 3] = plane.constant;
        }
      }

      uniform['value'] = dstArray;
      uniform['needsUpdate'] = true;
    }

    scope.numPlanes = nPlanes;
    scope.numIntersection = 0;

    return dstArray;
  }
}
