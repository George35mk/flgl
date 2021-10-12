import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:weak_map/weak_map.dart';

import 'opengl_attributes.dart';
import 'opengl_geometries.dart';
import 'opengl_info.dart';

class OpenGLObjects {
  OpenGLContextES gl;
  OpenGLGeometries geometries;
  OpenGLAttributes attributes;
  OpenGLInfo info;

  WeakMap updateMap = WeakMap();

  OpenGLObjects(this.gl, this.geometries, this.attributes, this.info);

  update(object) {
    final frame = info.render['frame'];

    final geometry = object.geometry;
    final buffergeometry = geometries.get(object, geometry);

    // Update once per frame

    if (updateMap.get(buffergeometry) != frame) {
      geometries.update(buffergeometry);

      // updateMap.set( buffergeometry, frame );
      updateMap.add(key: buffergeometry, value: frame);
    }

    if (object.isInstancedMesh) {
      if (object.hasEventListener('dispose', _onInstancedMeshDispose) == false) {
        object.addEventListener('dispose', _onInstancedMeshDispose);
      }

      attributes.update(object.instanceMatrix, gl.ARRAY_BUFFER);

      if (object.instanceColor != null) {
        attributes.update(object.instanceColor, gl.ARRAY_BUFFER);
      }
    }

    return buffergeometry;
  }

  dispose() {
    updateMap = WeakMap(); // or a better idea is to clean the map and then set a new map to this variable.
  }

  _onInstancedMeshDispose(event) {
    final instancedMesh = event.target;

    instancedMesh.removeEventListener('dispose', _onInstancedMeshDispose);

    attributes.remove(instancedMesh.instanceMatrix);

    if (instancedMesh.instanceColor != null) attributes.remove(instancedMesh.instanceColor);
  }
}
