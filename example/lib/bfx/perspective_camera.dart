import 'dart:math';

import 'package:flgl_example/bfx/camera.dart';
import 'package:flgl_example/examples/math/m4.dart';
import 'package:flgl_example/examples/math/math_utils.dart';

import 'matrix4.dart';

const DEG2RAD = 0.017453292519943295;

class PerspectiveCamera extends Camera {
  /// The camera FoV
  double fov = 45;

  /// The camera aspect ratio.
  double aspect = 1;

  /// The camera z near value.
  double near = 1;

  /// The camera z far values.
  double far = 2000;

  double zoom = 1;
  dynamic view = null;
  dynamic filmOffset = 0;
  dynamic filmGauge = 35;

  PerspectiveCamera(this.fov, this.aspect, this.near, this.far) : super() {
    type = 'PerspectiveCamera';
    name = 'PerspectiveCamera';
    updateProjectionMatrix();
  }

  /// Compute the projection matrix
  // computeProjectionMatrix() {
  //   double _fov = MathUtils.degToRad(fov);
  //   double _aspect = aspect;
  //   double _zNear = zNear;
  //   double _zFar = zFar;
  //   return M4.perspective(_fov, _aspect, _zNear, _zFar);
  // }

  /// Updates the projection matrix.
  // updateProjectionMatrix() {
  //   cameraMatrix = Matrix4.lookAt(position, target, up);
  //   viewMatrix = M4.inverse(cameraMatrix);
  //   projectionMatrix = computeProjectionMatrix();
  //   viewProjectionMatrix = M4.multiply(projectionMatrix, viewMatrix);
  // }

  getFilmWidth() {
    // film not completely covered in portrait format (aspect < 1)
    return filmGauge * min(aspect, 1);
  }

  updateProjectionMatrix() {
    var top = near * tan(DEG2RAD * 0.5 * fov) / zoom;
    var height = 2 * top;
    var width = aspect * height;
    var left = -0.5 * width;

    if (view != null && view.enabled) {
      var fullWidth = view.fullWidth;
      var fullHeight = view.fullHeight;
      left += view.offsetX * width / fullWidth;
      top -= view.offsetY * height / fullHeight;
      width *= view.width / fullWidth;
      height *= view.height / fullHeight;
    }

    var skew = filmOffset;
    if (skew != 0) left += near * skew / getFilmWidth();
    projectionMatrix.makePerspective(left, left + width, top, top - height, near, far);
    projectionMatrixInverse.copy(projectionMatrix).invert();
  }
}
