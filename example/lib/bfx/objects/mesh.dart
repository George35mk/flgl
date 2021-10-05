import 'package:flgl_example/bfx/core/object_3d.dart';

import '../core/buffer_geometry.dart';
import '../materials/fbx_material.dart';

class Mesh extends Object3D {
  /// The geometry data.
  BufferGeometry geometry;

  /// The material data.
  FBXMaterial material;

  Mesh(this.geometry, this.material) : super() {
    print('geometry: $geometry, material: $material');
  }
}
