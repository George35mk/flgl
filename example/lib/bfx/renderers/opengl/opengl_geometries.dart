import 'package:weak_map/weak_map.dart';

class OpenGLGeometries {
  Map geometries = Map();
  WeakMap wireframeAttributes = WeakMap();

  OpenGLGeometries(gl, attributes, info, bindingStates);

  onGeometryDispose(event) {}

  get(object, geometry) {}

  update(geometry) {}

  updateWireframeAttribute(geometry) {}

  getWireframeAttribute(geometry) {}
}
