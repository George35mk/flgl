import 'package:flgl_example/bfx/core/object_3d.dart';
import 'package:flgl_example/bfx/math/box3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/plane.dart';
import 'package:flgl_example/bfx/math/sphere.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/objects/mesh.dart';
import 'package:flgl_example/bfx/objects/sprite.dart';

final _sphere = Sphere();
final _vector = Vector3();

/// Frustums are used to determine what is inside the camera's field of view.
/// They help speed up the rendering process - objects which lie outside a camera's
/// frustum can safely be excluded from rendering.
///
/// This class is mainly intended for use internally by a renderer for calculating a
/// camera or shadowCamera's frustum.
class Frustum {
  Plane p0 = Plane();
  Plane p1 = Plane();
  Plane p2 = Plane();
  Plane p3 = Plane();
  Plane p4 = Plane();
  Plane p5 = Plane();

  List<Plane> planes = [];

  Frustum([Plane? _p0, Plane? _p1, Plane? _p2, Plane? _p3, Plane? _p4, Plane? _p5]) {
    p0 = _p0 ?? Plane();
    p1 = _p1 ?? Plane();
    p2 = _p2 ?? Plane();
    p3 = _p3 ?? Plane();
    p4 = _p4 ?? Plane();
    p5 = _p5 ?? Plane();

    planes = [p0, p1, p2, p3, p4, p5];
  }

  /// Sets the frustum from the passed planes. No plane order is implied.
  /// Note that this method only copies the values from the given objects.
  Frustum set(Plane p0, Plane p1, Plane p2, Plane p3, Plane p4, Plane p5) {
    final planes = this.planes;

    planes[0].copy(p0);
    planes[1].copy(p1);
    planes[2].copy(p2);
    planes[3].copy(p3);
    planes[4].copy(p4);
    planes[5].copy(p5);

    return this;
  }

  /// Copies the properties of the passed frustum into this one.
  ///
  /// - [frustum] - The frustum to copy
  Frustum copy(Frustum frustum) {
    final planes = this.planes;

    for (var i = 0; i < 6; i++) {
      planes[i].copy(frustum.planes[i]);
    }

    return this;
  }

  /// Sets the frustum planes from the projection matrix.
  ///
  /// - [m] - Projection Matrix4 used to set the planes
  Frustum setFromProjectionMatrix(Matrix4 m) {
    final planes = this.planes;
    final me = m.elements;
    final me0 = me[0], me1 = me[1], me2 = me[2], me3 = me[3];
    final me4 = me[4], me5 = me[5], me6 = me[6], me7 = me[7];
    final me8 = me[8], me9 = me[9], me10 = me[10], me11 = me[11];
    final me12 = me[12], me13 = me[13], me14 = me[14], me15 = me[15];

    planes[0].setComponents(me3 - me0, me7 - me4, me11 - me8, me15 - me12).normalize();
    planes[1].setComponents(me3 + me0, me7 + me4, me11 + me8, me15 + me12).normalize();
    planes[2].setComponents(me3 + me1, me7 + me5, me11 + me9, me15 + me13).normalize();
    planes[3].setComponents(me3 - me1, me7 - me5, me11 - me9, me15 - me13).normalize();
    planes[4].setComponents(me3 - me2, me7 - me6, me11 - me10, me15 - me14).normalize();
    planes[5].setComponents(me3 + me2, me7 + me6, me11 + me10, me15 + me14).normalize();

    return this;
  }

  /// Checks whether the object's bounding sphere is intersecting the Frustum.
  /// Note that the object must have a geometry so that the bounding sphere can be calculated.
  /// - returns bool
  intersectsObject(Object3D object) {
    if (object is Mesh) {
      final geometry = object.geometry;

      if (geometry.boundingSphere == null) geometry.computeBoundingSphere();

      _sphere.copy(geometry.boundingSphere).applyMatrix4(object.matrixWorld);

      return intersectsSphere(_sphere);
    }
  }

  /// Checks whether the sprite is intersecting the Frustum.
  ///
  /// - Checks whether the [sprite] is intersecting the Frustum.
  bool intersectsSprite(Sprite sprite) {
    _sphere.center.set(0, 0, 0);
    _sphere.radius = 0.7071067811865476;
    _sphere.applyMatrix4(sprite.matrixWorld);

    return intersectsSphere(_sphere);
  }

  /// Return true if sphere intersects with this frustum.
  ///
  /// - sphere - Sphere to check for intersection.
  bool intersectsSphere(Sphere sphere) {
    final planes = this.planes;
    final center = sphere.center;
    final negRadius = -sphere.radius;

    for (var i = 0; i < 6; i++) {
      final distance = planes[i].distanceToPoint(center);

      if (distance < negRadius) {
        return false;
      }
    }

    return true;
  }

  /// Return true if box intersects with this frustum.
  ///
  /// - box - Box3 to check for intersection.
  bool intersectsBox(Box3 box) {
    final planes = this.planes;

    for (var i = 0; i < 6; i++) {
      final plane = planes[i];

      // corner at max distance

      _vector.x = plane.normal.x > 0 ? box.max.x : box.min.x;
      _vector.y = plane.normal.y > 0 ? box.max.y : box.min.y;
      _vector.z = plane.normal.z > 0 ? box.max.z : box.min.z;

      if (plane.distanceToPoint(_vector) < 0) {
        return false;
      }
    }

    return true;
  }

  /// Checks to see if the frustum contains the point.
  ///
  /// - [point] - Vector3 to test.
  bool containsPoint(Vector3 point) {
    final planes = this.planes;

    for (var i = 0; i < 6; i++) {
      if (planes[i].distanceToPoint(point) < 0) {
        return false;
      }
    }

    return true;
  }

  /// Return a new Frustum with the same parameters as this one.
  Frustum clone() {
    return Frustum().copy(this);
  }
}
