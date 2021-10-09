import 'package:flgl_example/bfx/math/vector3.dart';
import 'dart:math' as math;
import 'matrix4.dart';

final _points = [Vector3(), Vector3(), Vector3(), Vector3(), Vector3(), Vector3(), Vector3(), Vector3()];
final _vector = Vector3();
final _box = Box3();

// triangle centered vertices
final _v0 = Vector3();
final _v1 = Vector3();
final _v2 = Vector3();

// triangle edge vectors
final _f0 = Vector3();
final _f1 = Vector3();
final _f2 = Vector3();

final _center = Vector3();
final _extents = Vector3();
final _triangleNormal = Vector3();
final _testAxis = Vector3();

class Box3 {
  Vector3 min = Vector3();
  Vector3 max = Vector3();

  Box3([Vector3? min, Vector3? max]) {
    this.min = min ?? Vector3(double.infinity, double.infinity, double.infinity);
    this.max = max ?? Vector3(double.negativeInfinity, double.negativeInfinity, double.negativeInfinity);
  }

  Box3 set(Vector3 min, Vector3 max) {
    this.min.copy(min);
    this.max.copy(max);

    return this;
  }

  Box3 setFromArray(List<double> array) {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;

    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    var maxZ = double.negativeInfinity;

    for (var i = 0, l = array.length; i < l; i += 3) {
      final x = array[i];
      final y = array[i + 1];
      final z = array[i + 2];

      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (z < minZ) minZ = z;

      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
      if (z > maxZ) maxZ = z;
    }

    min.set(minX, minY, minZ);
    max.set(maxX, maxY, maxZ);

    return this;
  }

  Box3 setFromBufferAttribute(attribute) {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;

    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    var maxZ = double.negativeInfinity;

    for (var i = 0, l = attribute.count; i < l; i++) {
      final x = attribute.getX(i);
      final y = attribute.getY(i);
      final z = attribute.getZ(i);

      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (z < minZ) minZ = z;

      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
      if (z > maxZ) maxZ = z;
    }

    min.set(minX, minY, minZ);
    max.set(maxX, maxY, maxZ);

    return this;
  }

  Box3 setFromPoints(points) {
    makeEmpty();

    for (var i = 0, il = points.length; i < il; i++) {
      expandByPoint(points[i]);
    }

    return this;
  }

  Box3 setFromCenterAndSize(center, size) {
    final halfSize = _vector.copy(size).multiplyScalar(0.5);

    this.min.copy(center).sub(halfSize);
    this.max.copy(center).add(halfSize);

    return this;
  }

  setFromObject(object) {
    makeEmpty();

    return expandByObject(object);
  }

  Box3 clone() {
    return Box3().copy(this);
  }

  Box3 copy(Box3 box) {
    min.copy(box.min);
    max.copy(box.max);

    return this;
  }

  Box3 makeEmpty() {
    min.x = min.y = min.z = double.infinity;
    max.x = max.y = max.z = double.negativeInfinity;

    return this;
  }

  isEmpty() {
    // this is a more robust check for empty than ( volume <= 0 ) because volume can get positive with two negative axes

    return (max.x < min.x) || (max.y < min.y) || (max.z < min.z);
  }

  getCenter(target) {
    return isEmpty() ? target.set(0, 0, 0) : target.addVectors(min, max).multiplyScalar(0.5);
  }

  getSize(target) {
    return isEmpty() ? target.set(0, 0, 0) : target.subVectors(max, min);
  }

  expandByPoint(point) {
    min.min(point);
    max.max(point);

    return this;
  }

  expandByVector(vector) {
    min.sub(vector);
    max.add(vector);

    return this;
  }

  expandByScalar(double scalar) {
    min.addScalar(-scalar);
    max.addScalar(scalar);

    return this;
  }

  expandByObject(object) {
    // Computes the world-axis-aligned bounding box of an object (including its children),
    // accounting for both the object's, and children's, world transforms

    object.updateWorldMatrix(false, false);

    final geometry = object.geometry;

    if (geometry != null) {
      if (geometry.boundingBox == null) {
        geometry.computeBoundingBox();
      }

      _box.copy(geometry.boundingBox);
      _box.applyMatrix4(object.matrixWorld);

      union(_box);
    }

    final children = object.children;

    for (var i = 0, l = children.length; i < l; i++) {
      this.expandByObject(children[i]);
    }

    return this;
  }

  containsPoint(point) {
    return point.x < min.x ||
            point.x > max.x ||
            point.y < min.y ||
            point.y > max.y ||
            point.z < min.z ||
            point.z > max.z
        ? false
        : true;
  }

  containsBox(box) {
    return min.x <= box.min.x &&
        box.max.x <= max.x &&
        min.y <= box.min.y &&
        box.max.y <= max.y &&
        min.z <= box.min.z &&
        box.max.z <= max.z;
  }

  getParameter(point, target) {
    // This can potentially have a divide by zero if the box
    // has a size dimension of 0.

    return target.set(
      (point.x - min.x) / (max.x - min.x),
      (point.y - min.y) / (max.y - min.y),
      (point.z - min.z) / (max.z - min.z),
    );
  }

  intersectsBox(Box3 box) {
    // using 6 splitting planes to rule out intersections.
    return box.max.x < min.x ||
            box.min.x > max.x ||
            box.max.y < min.y ||
            box.min.y > max.y ||
            box.max.z < min.z ||
            box.min.z > max.z
        ? false
        : true;
  }

  intersectsSphere(sphere) {
    // Find the point on the AABB closest to the sphere center.
    clampPoint(sphere.center, _vector);

    // If that point is inside the sphere, the AABB and sphere intersect.
    return _vector.distanceToSquared(sphere.center) <= (sphere.radius * sphere.radius);
  }

  intersectsPlane(plane) {
    // We compute the minimum and maximum dot product values. If those values
    // are on the same side (back or front) of the plane, then there is no intersection.

    var min, max;

    if (plane.normal.x > 0) {
      min = plane.normal.x * this.min.x;
      max = plane.normal.x * this.max.x;
    } else {
      min = plane.normal.x * this.max.x;
      max = plane.normal.x * this.min.x;
    }

    if (plane.normal.y > 0) {
      min += plane.normal.y * this.min.y;
      max += plane.normal.y * this.max.y;
    } else {
      min += plane.normal.y * this.max.y;
      max += plane.normal.y * this.min.y;
    }

    if (plane.normal.z > 0) {
      min += plane.normal.z * this.min.z;
      max += plane.normal.z * this.max.z;
    } else {
      min += plane.normal.z * this.max.z;
      max += plane.normal.z * this.min.z;
    }

    return (min <= -plane.constant && max >= -plane.constant);
  }

  intersectsTriangle(triangle) {
    if (isEmpty()) {
      return false;
    }

    // compute box center and extents
    getCenter(_center);
    _extents.subVectors(max, _center);

    // translate triangle to aabb origin
    _v0.subVectors(triangle.a, _center);
    _v1.subVectors(triangle.b, _center);
    _v2.subVectors(triangle.c, _center);

    // compute edge vectors for triangle
    _f0.subVectors(_v1, _v0);
    _f1.subVectors(_v2, _v1);
    _f2.subVectors(_v0, _v2);

    // test against axes that are given by cross product combinations of the edges of the triangle and the edges of the aabb
    // make an axis testing of each of the 3 sides of the aabb against each of the 3 sides of the triangle = 9 axis of separation
    // axis_ij = u_i x f_j (u0, u1, u2 = face normals of aabb = x,y,z axes vectors since aabb is axis aligned)
    var axes = [
      0,
      -_f0.z,
      _f0.y,
      0,
      -_f1.z,
      _f1.y,
      0,
      -_f2.z,
      _f2.y,
      _f0.z,
      0,
      -_f0.x,
      _f1.z,
      0,
      -_f1.x,
      _f2.z,
      0,
      -_f2.x,
      -_f0.y,
      _f0.x,
      0,
      -_f1.y,
      _f1.x,
      0,
      -_f2.y,
      _f2.x,
      0
    ];
    if (!satForAxes(axes, _v0, _v1, _v2, _extents)) {
      return false;
    }

    // test 3 face normals from the aabb
    axes = [1, 0, 0, 0, 1, 0, 0, 0, 1];
    if (!satForAxes(axes, _v0, _v1, _v2, _extents)) {
      return false;
    }

    // finally testing the face normal of the triangle
    // use already existing triangle edge vectors here
    _triangleNormal.crossVectors(_f0, _f1);
    axes = [_triangleNormal.x, _triangleNormal.y, _triangleNormal.z];

    return satForAxes(axes, _v0, _v1, _v2, _extents);
  }

  clampPoint(point, target) {
    return target.copy(point).clamp(min, max);
  }

  distanceToPoint(point) {
    final clampedPoint = _vector.copy(point).clamp(min, max);

    return clampedPoint.sub(point).length();
  }

  getBoundingSphere(target) {
    getCenter(target.center);

    target.radius = getSize(_vector).length() * 0.5;

    return target;
  }

  Box3 intersect(Box3 box) {
    min.max(box.min);
    max.min(box.max);

    // ensure that if there is no overlap, the result is fully empty, not slightly empty with non-inf/+inf values that will cause subsequence intersects to erroneously return valid values.
    if (isEmpty()) makeEmpty();

    return this;
  }

  Box3 union(Box3 box) {
    min.min(box.min);
    max.max(box.max);

    return this;
  }

  Box3 applyMatrix4(Matrix4 matrix) {
    // transform of empty box is an empty box.
    if (isEmpty()) return this;

    // NOTE: I am using a binary pattern to specify all 2^3 combinations below
    _points[0].set(min.x, min.y, min.z).applyMatrix4(matrix); // 000
    _points[1].set(min.x, min.y, max.z).applyMatrix4(matrix); // 001
    _points[2].set(min.x, max.y, min.z).applyMatrix4(matrix); // 010
    _points[3].set(min.x, max.y, max.z).applyMatrix4(matrix); // 011
    _points[4].set(max.x, min.y, min.z).applyMatrix4(matrix); // 100
    _points[5].set(max.x, min.y, max.z).applyMatrix4(matrix); // 101
    _points[6].set(max.x, max.y, min.z).applyMatrix4(matrix); // 110
    _points[7].set(max.x, max.y, max.z).applyMatrix4(matrix); // 111

    setFromPoints(_points);

    return this;
  }

  Box3 translate(offset) {
    min.add(offset);
    max.add(offset);

    return this;
  }

  equals(Box3 box) {
    return box.min.equals(min) && box.max.equals(max);
  }
}

bool satForAxes(axes, Vector3 v0, Vector3 v1, Vector3 v2, Vector3 extents) {
  for (var i = 0, j = axes.length - 3; i <= j; i += 3) {
    _testAxis.fromArray(axes, i);
    // project the aabb onto the seperating axis
    final r = extents.x * _testAxis.x.abs() + extents.y * _testAxis.y.abs() + extents.z * _testAxis.z.abs();
    // project all 3 vertices of the triangle onto the seperating axis
    final p0 = v0.dot(_testAxis);
    final p1 = v1.dot(_testAxis);
    final p2 = v2.dot(_testAxis);

    final maxp0p1 = math.max(p0, p1);
    final minp0p1 = math.min(p0, p1);

    // actual test, basically see if either of the most extreme of the triangle points intersects r
    if (math.max(-math.max(maxp0p1, p2), math.min(minp0p1, p2)) > r) {
      // points of the projected triangle are outside the projected half-length of the aabb
      // the axis is seperating and we can exit
      return false;
    }
  }

  return true;
}
