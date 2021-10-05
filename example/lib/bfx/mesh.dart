import 'package:flgl_example/bfx/object_3d.dart';

import 'buffer_geometry.dart';
import 'fbx_material.dart';

class Mesh extends Object3D {
  /// The geometry data.
  BufferGeometry geometry;

  /// The material data.
  FBXMaterial material;

  Mesh(this.geometry, this.material) : super() {
    print('geometry: $geometry, material: $material');
  }
}
