import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flgl_example/bfx/cameras/perspective_camera.dart';
import 'package:flgl_example/bfx/core/buffer_geometry.dart';
import 'package:flgl_example/bfx/core/interleaved_buffer.dart';
import 'package:flgl_example/bfx/core/interleaved_buffer_attribute.dart';
import 'package:flgl_example/bfx/core/object_3d.dart';
import 'package:flgl_example/bfx/core/raycaster.dart';
import 'package:flgl_example/bfx/materials/sprite_material.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/triangle.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

var _geometry;

final _intersectPoint = Vector3();
final _worldScale = Vector3();
final _mvPosition = Vector3();

final _alignedPosition = Vector2();
final _rotatedPosition = Vector2();
final _viewWorldMatrix = Matrix4();

final _vA = Vector3();
final _vB = Vector3();
final _vC = Vector3();

final _uvA = Vector2();
final _uvB = Vector2();
final _uvC = Vector2();

class Sprite extends Object3D {
  bool isSprite = true;
  SpriteMaterial material;
  Vector2 center = Vector2(0.5, 0.5);

  late BufferGeometry geometry;

  /// ## Example use
  ///```dart
  ///const map = new THREE.TextureLoader().load( 'sprite.png' );
  /// const material = new THREE.SpriteMaterial( { map: map } );
  ///
  /// const sprite = new THREE.Sprite( material );
  /// scene.add( sprite );
  ///```
  Sprite(this.material) {
    type = 'Sprite';

    if (_geometry == null) {
      _geometry = BufferGeometry();

      final float32Array = Float32List.fromList([
        ///
        -0.5, -0.5, 0, 0, 0,
        0.5, -0.5, 0, 1, 0,
        0.5, 0.5, 0, 1, 1,
        -0.5, 0.5, 0, 0, 1,
      ]);

      final interleavedBuffer = InterleavedBuffer(float32Array, 5);

      _geometry.setIndex([0, 1, 2, 0, 2, 3]);
      _geometry.setAttribute('position', InterleavedBufferAttribute(interleavedBuffer, 3, 0, false));
      _geometry.setAttribute('uv', InterleavedBufferAttribute(interleavedBuffer, 2, 3, false));
    }

    geometry = _geometry;
    material = (material != null) ? material : SpriteMaterial();

    center = Vector2(0.5, 0.5);
  }

  /// Get intersections between a casted ray and this sprite. Raycaster.intersectObject()
  /// will call this method. The raycaster must be initialized by calling Raycaster.setFromCamera()
  /// before raycasting against sprites.
  void raycast(Raycaster raycaster, List intersects) {
    if (raycaster.camera == null) {
      print('THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.');
    }

    _worldScale.setFromMatrixScale(matrixWorld);
    _viewWorldMatrix.copy(raycaster.camera.matrixWorld);
    modelViewMatrix.multiplyMatrices(raycaster.camera.matrixWorldInverse, matrixWorld);

    _mvPosition.setFromMatrixPosition(modelViewMatrix);

    if (raycaster.camera is PerspectiveCamera && material.sizeAttenuation == false) {
      _worldScale.multiplyScalar(-_mvPosition.z);
    }

    final rotation = material.rotation;
    var sin, cos;

    if (rotation != 0) {
      cos = math.cos(rotation);
      sin = math.sin(rotation);
    }

    final center = this.center;

    transformVertex(_vA.set(-0.5, -0.5, 0), _mvPosition, center, _worldScale, sin, cos);
    transformVertex(_vB.set(0.5, -0.5, 0), _mvPosition, center, _worldScale, sin, cos);
    transformVertex(_vC.set(0.5, 0.5, 0), _mvPosition, center, _worldScale, sin, cos);

    _uvA.set(0, 0);
    _uvB.set(1, 0);
    _uvC.set(1, 1);

    // check first triangle
    var intersect = raycaster.ray.intersectTriangle(_vA, _vB, _vC, false, _intersectPoint);

    if (intersect == null) {
      // check second triangle
      transformVertex(_vB.set(-0.5, 0.5, 0), _mvPosition, center, _worldScale, sin, cos);
      _uvB.set(0, 1);

      intersect = raycaster.ray.intersectTriangle(_vA, _vC, _vB, false, _intersectPoint);
      if (intersect == null) {
        return;
      }
    }

    final distance = raycaster.ray.origin.distanceTo(_intersectPoint);

    if (distance < raycaster.near || distance > raycaster.far) return;

    intersects.add({
      'distance': distance,
      'point': _intersectPoint.clone(),
      'uv': Triangle.s_getUV(_intersectPoint, _vA, _vB, _vC, _uvA, _uvB, _uvC, Vector2()),
      'face': null,
      'object': this
    });
  }

  /// Copies the properties of the passed sprite to this one.
  @override
  Sprite copy(dynamic source, [bool recursive = true]) {
    super.copy(source);

    if (source.center != null) center.copy(source.center);

    material = source.material;

    return this;
  }
}

/// problem with the types check this method.
transformVertex(vertexPosition, mvPosition, center, scale, sin, cos) {
  // compute position in camera space
  _alignedPosition.subVectors(vertexPosition, center).addScalar(0.5).multiply(scale);

  // to check if rotation is not zero
  if (sin != null) {
    _rotatedPosition.x = (cos * _alignedPosition.x) - (sin * _alignedPosition.y);
    _rotatedPosition.y = (sin * _alignedPosition.x) + (cos * _alignedPosition.y);
  } else {
    _rotatedPosition.copy(_alignedPosition);
  }

  vertexPosition.copy(mvPosition);
  vertexPosition.x += _rotatedPosition.x;
  vertexPosition.y += _rotatedPosition.y;

  // transform to world space
  vertexPosition.applyMatrix4(_viewWorldMatrix);
}
