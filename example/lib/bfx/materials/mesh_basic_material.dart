import 'package:flgl_example/bfx/materials/fbx_material.dart';

class MeshBasicMaterial extends FBXMaterial {
  int color;

  MeshBasicMaterial({this.color = 0x000000}) : super() {
    type = 'MeshBasicMaterial';
  }
}
