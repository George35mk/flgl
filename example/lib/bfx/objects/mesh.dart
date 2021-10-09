import 'package:flgl_example/bfx/core/object_3d.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/ray.dart';
import 'package:flgl_example/bfx/math/sphere.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import '../core/buffer_geometry.dart';
import '../materials/fbx_material.dart';

final _inverseMatrix = Matrix4();
final _ray = Ray();
final _sphere = Sphere();

final _vA = Vector3();
final _vB = Vector3();
final _vC = Vector3();

final _tempA = Vector3();
final _tempB = Vector3();
final _tempC = Vector3();

final _morphA = Vector3();
final _morphB = Vector3();
final _morphC = Vector3();

final _uvA = Vector2();
final _uvB = Vector2();
final _uvC = Vector2();

final _intersectionPoint = Vector3();
final _intersectionPointWorld = Vector3();

class Mesh extends Object3D {
  /// The geometry data.
  BufferGeometry geometry;

  /// The material data.
  FBXMaterial material;

  Mesh(this.geometry, this.material) : super() {
    print('geometry: $geometry, material: $material');
  }
}
