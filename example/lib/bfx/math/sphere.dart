import 'package:flgl_example/bfx/math/box3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'dart:math' as math;

final _box = Box3();
final _v1 = Vector3();
final _toFarthestPoint = Vector3();
final _toPoint = Vector3();

class Sphere {
  Vector3 center = Vector3();
  double radius = -1;

  Sphere([Vector3? center, double radius = -1]) {
    center ??= Vector3();
    radius = -1;
  }

  Sphere set(center, radius) {
    this.center.copy(center);
    this.radius = radius;

    return this;
  }

  Sphere setFromPoints(points, [Vector3? optionalCenter]) {
    final center = this.center;

    if (optionalCenter != null) {
      center.copy(optionalCenter);
    } else {
      _box.setFromPoints(points).getCenter(center);
    }

    var maxRadiusSq = 0;

    for (var i = 0, il = points.length; i < il; i++) {
      maxRadiusSq = math.max(maxRadiusSq, center.distanceToSquared(points[i]));
    }

    radius = math.sqrt(maxRadiusSq);

    return this;
  }

  Sphere copy(Sphere sphere) {
    center.copy(sphere.center);
    radius = sphere.radius;

    return this;
  }

  isEmpty() {
    return (radius < 0);
  }

  Sphere makeEmpty() {
    center.set(0, 0, 0);
    radius = -1;

    return this;
  }

  containsPoint(point) {
    return (point.distanceToSquared(center) <= (radius * radius));
  }

  distanceToPoint(point) {
    return (point.distanceTo(center) - radius);
  }

  intersectsSphere(Sphere sphere) {
    final radiusSum = radius + sphere.radius;

    return sphere.center.distanceToSquared(center) <= (radiusSum * radiusSum);
  }

  intersectsBox(box) {
    return box.intersectsSphere(this);
  }

  intersectsPlane(plane) {
    return plane.distanceToPoint(center).abs() <= radius;
  }

  clampPoint(point, target) {
    final deltaLengthSq = center.distanceToSquared(point);

    target.copy(point);

    if (deltaLengthSq > (radius * radius)) {
      target.sub(center).normalize();
      target.multiplyScalar(radius).add(center);
    }

    return target;
  }

  getBoundingBox(target) {
    if (isEmpty()) {
      // Empty sphere produces empty bounding box
      target.makeEmpty();
      return target;
    }

    target.set(center, center);
    target.expandByScalar(radius);

    return target;
  }

  Sphere applyMatrix4(Matrix4 matrix) {
    center.applyMatrix4(matrix);
    radius = radius * matrix.getMaxScaleOnAxis();

    return this;
  }

  Sphere translate(offset) {
    center.add(offset);

    return this;
  }

  Sphere expandByPoint(point) {
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

  equals(Sphere sphere) {
    return sphere.center.equals(center) && (sphere.radius == radius);
  }

  Sphere clone() {
    return Sphere().copy(this);
  }
}
