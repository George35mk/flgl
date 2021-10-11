import 'package:flgl_example/bfx/math/box3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/plane.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'dart:math' as math;

final _box = Box3();
final _v1 = Vector3();
final _toFarthestPoint = Vector3();
final _toPoint = Vector3();

/// A sphere defined by a center and radius.
class Sphere {
  Vector3 center = Vector3();
  double radius = -1;

  Sphere([Vector3? center, double radius = -1]) {
    this.center = center ?? Vector3();
    this.radius = radius ?? -1;
  }

  /// Sets the center and radius properties of this sphere.
  /// Please note that this method only copies the values from the given center.
  ///
  /// - [center] - center of the sphere.
  /// - [radius] - radius of the sphere.
  Sphere set(Vector3 center, double radius) {
    this.center.copy(center);
    this.radius = radius;
    return this;
  }

  /// Computes the minimum bounding sphere for an array of points. If optionalCenteris
  /// given, it is used as the sphere's center. Otherwise, the center of the axis-aligned
  /// bounding box encompassing points is calculated.
  ///
  /// - [points] - an Array of Vector3 positions.
  /// - [optionalCenter] - Optional Vector3 position for the sphere's center.
  Sphere setFromPoints(List<Vector3> points, [Vector3? optionalCenter]) {
    final center = this.center;

    if (optionalCenter != null) {
      center.copy(optionalCenter);
    } else {
      _box.setFromPoints(points).getCenter(center);
    }

    double maxRadiusSq = 0;

    for (var i = 0, il = points.length; i < il; i++) {
      maxRadiusSq = math.max(maxRadiusSq, center.distanceToSquared(points[i]));
    }

    radius = math.sqrt(maxRadiusSq);

    return this;
  }

  /// Copies the values of the passed sphere's center and radius properties to this sphere.
  Sphere copy(Sphere sphere) {
    center.copy(sphere.center);
    radius = sphere.radius;
    return this;
  }

  /// Checks to see if the sphere is empty (the radius set to a negative number).
  /// Spheres with a radius of 0 contain only their center point and are not considered to be empty.
  bool isEmpty() {
    return (radius < 0);
  }

  /// Makes the sphere empty by setting center to (0, 0, 0) and radius to -1.
  Sphere makeEmpty() {
    center.set(0, 0, 0);
    radius = -1;

    return this;
  }

  /// Checks to see if the sphere contains the provided point inclusive of the surface of the sphere.
  ///
  /// - [point] - the Vector3 to be checked
  bool containsPoint(Vector3 point) {
    return (point.distanceToSquared(center) <= (radius * radius));
  }

  /// Returns the closest distance from the boundary of the sphere to the point. If the sphere contains
  /// the point, the distance will be negative.
  double distanceToPoint(Vector3 point) {
    return (point.distanceTo(center) - radius);
  }

  /// Checks to see if two spheres intersect.
  ///
  /// - [sphere] - Sphere to check for intersection against.
  bool intersectsSphere(Sphere sphere) {
    final radiusSum = radius + sphere.radius;
    return sphere.center.distanceToSquared(center) <= (radiusSum * radiusSum);
  }

  /// Determines whether or not this sphere intersects a given box.
  ///
  /// - [box] - Box3 to check for intersection against.
  bool intersectsBox(Box3 box) {
    return box.intersectsSphere(this);
  }

  /// Determines whether or not this sphere intersects a given plane.
  ///
  /// - plane - Plane to check for intersection against.
  bool intersectsPlane(Plane plane) {
    return plane.distanceToPoint(center).abs() <= radius;
  }

  /// Clamps a point within the sphere. If the point is outside the sphere,
  /// it will clamp it to the closest point on the edge of the sphere.
  /// Points already inside the sphere will not be affected.
  ///
  /// - [point] - Vector3 The point to clamp.
  /// - [target] — the result will be copied into this Vector3.
  Vector3 clampPoint(Vector3 point, Vector3 target) {
    final deltaLengthSq = center.distanceToSquared(point);

    target.copy(point);

    if (deltaLengthSq > (radius * radius)) {
      target.sub(center).normalize();
      target.multiplyScalar(radius).add(center);
    }

    return target;
  }

  /// Returns aMinimum Bounding Box for the sphere.
  ///
  /// - [target] — the result will be copied into this Box3.
  Box3 getBoundingBox(Box3 target) {
    if (isEmpty()) {
      // Empty sphere produces empty bounding box
      target.makeEmpty();
      return target;
    }

    target.set(center, center);
    target.expandByScalar(radius);

    return target;
  }

  /// Transforms this sphere with the provided Matrix4.
  ///
  /// - matrix - the Matrix4 to apply
  Sphere applyMatrix4(Matrix4 matrix) {
    center.applyMatrix4(matrix);
    radius = radius * matrix.getMaxScaleOnAxis();
    return this;
  }

  /// Translate the sphere's center by the provided offset Vector3.
  Sphere translate(Vector3 offset) {
    center.add(offset);
    return this;
  }

  /// Expands the boundaries of this sphere to include point.
  ///
  /// - [point] - Vector3 that should be included in the sphere.
  Sphere expandByPoint(Vector3 point) {
    // from https://github.com/juj/MathGeoLib/blob/2940b99b99cfe575dd45103ef20f4019dee15b54/src/Geometry/Sphere.cpp#L649-L671

    _toPoint.subVectors(point, center);

    final lengthSq = _toPoint.lengthSq();

    if (lengthSq > (radius * radius)) {
      final length = math.sqrt(lengthSq);
      final missingRadiusHalf = (length - radius) * 0.5;

      // Nudge this sphere towards the target point. Add half the missing distance to radius,
      // and the other half to position. This gives a tighter enclosure, instead of if
      // the whole missing distance were just added to radius.

      center.add(_toPoint.multiplyScalar(missingRadiusHalf / length));
      radius += missingRadiusHalf;
    }

    return this;
  }

  /// Expands this sphere to enclose both the original sphere and the given sphere.
  ///
  /// - [sphere] - Bounding sphere that will be unioned with this sphere.
  Sphere union(Sphere sphere) {
    // from https://github.com/juj/MathGeoLib/blob/2940b99b99cfe575dd45103ef20f4019dee15b54/src/Geometry/Sphere.cpp#L759-L769

    // To enclose another sphere into this sphere, we only need to enclose two points:
    // 1) Enclose the farthest point on the other sphere into this sphere.
    // 2) Enclose the opposite point of the farthest point into this sphere.

    _toFarthestPoint.subVectors(sphere.center, center).normalize().multiplyScalar(sphere.radius);

    expandByPoint(_v1.copy(sphere.center).add(_toFarthestPoint));
    expandByPoint(_v1.copy(sphere.center).sub(_toFarthestPoint));

    return this;
  }

  /// Checks to see if the two spheres' centers and radii are equal.
  bool equals(Sphere sphere) {
    return sphere.center.equals(center) && (sphere.radius == radius);
  }

  /// Returns a new sphere with the same center and radius as this one.
  Sphere clone() {
    return Sphere().copy(this);
  }
}
