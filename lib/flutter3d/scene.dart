import 'core/object_3d.dart';

class Scene {
  List<Object3D> children = [];
  Scene();

  add(dynamic object) {
    children.add(object);
  }
}
