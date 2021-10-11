import 'package:weak_map/weak_map.dart';

class OpenGLObjects {
  WeakMap updateMap = WeakMap();

  OpenGLObjects(gl, geometries, attributes, info);

  update(object) {}

  dispose() {
    updateMap = WeakMap(); // or a better idea is to clean the map and then set a new map to this variable.
  }

  onInstancedMeshDispose(event) {}
}
