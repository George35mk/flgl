import 'box3.dart';
import 'matrix3.dart';
import 'matrix4.dart';
import 'sphere.dart';
import 'vector3.dart';

final _vector1 = Vector3();
final _vector2 = Vector3();
final _normalMatrix = Matrix3();

/// A two dimensional surface that extends infinitely in 3d space,
/// represented in Hessian normal form by a unit length normal vector
/// and a constant.
class Plane {
  Vector3 normal = Vector3(1, 0, 0);
  double constant;

  Plane([Vector3? normal, this.constant = 0]) {
    this.normal = normal ?? Vector3(1, 0, 0);
  }

  /// Sets this plane's normal and constant properties by copying the values from the given normal.
  ///
  /// - normal - a unit length Vector3 defining the normal of the plane.
  /// - constant - the signed distance from the origin to the plane. Default is 0.
  Plane set(Vector3 normal, double constant) {
    this.normal.copy(normal);
    this.constant = constant;

    return this;
  }

  /// Set the individual components that define the plane.
  ///
  /// - [x] - x value of the unit length normal vector.
  /// - [y] - y value of the unit length normal vector.
  /// - [z] - z value of the unit length normal vector.
  /// - [w] - the value of the plane's constant property.
  Plane setComponents(double x, double y, double z, double w) {
    normal.set(x, y, z);
    constant = w;

    return this;
  }

  /// Sets the plane's properties as defined by a normal and an arbitrary coplanar point.
  ///
  /// - [normal] - a unit length Vector3 defining the normal of the plane.
  /// - [point] - Vector3
  Plane setFromNormalAndCoplanarPoint(Vector3 normal, Vector3 point) {
    this.normal.copy(normal);
    constant = -point.dot(this.normal);

    return this;
  }

  /// Defines the plane based on the 3 provided points. The winding order is assumed to
  /// be counter-clockwise, and determines the direction of the normal.
  ///
  /// - [a] - first point on the plane.
  /// - [b] - second point on the plane.
  /// - [c] - third point on the plane.
  Plane setFromCoplanarPoints(Vector3 a, Vector3 b, Vector3 c) {
    final normal = _vector1.subVectors(c, b).cross(_vector2.subVectors(a, b)).normalize();

    // Q: should an error be thrown if normal is zero (e.g. degenerate plane)?

    setFromNormalAndCoplanarPoint(normal, a);

    return this;
  }

  /// Copies the values of the passed plane's normal and constant properties to this plane.
  Plane copy(Plane plane) {
    normal.copy(plane.normal);
    constant = plane.constant;

    return this;
  }

  /// Normalizes the normal vector, and adjusts the constant value accordingly.
  Plane normalize() {
    // Note: will lead to a divide by zero if the plane is invalid.

    final inverseNormalLength = 1.0 / normal.length();
    normal.multiplyScalar(inverseNormalLength);
    constant *= inverseNormalLength;

    return this;
  }

  /// Negates both the normal vector and the constant.
  Plane negate() {
    constant *= -1;
    normal.negate();

    return this;
  }

  /// Returns the signed distance from the point to the plane.
  double distanceToPoint(Vector3 point) {
    return normal.dot(point) + constant;
  }

  /// Returns the signed distance from the sphere to the plane.
  double distanceToSphere(Sphere sphere) {
    return distanceToPoint(sphere.center) - sphere.radius;
  }

  /// Projects a point onto the plane.
  ///
  /// - [point] - the Vector3 to project onto the plane.
  /// - [target] — the result will be copied into this Vector3.
  Vector3 projectPoint(Vector3 point, Vector3 target) {
    return target.copy(normal).multiplyScalar(-distanceToPoint(point)).add(point);
  }

  /// Returns the intersection point of the passed line and the plane.
  /// Returns null if the line does not intersect. Returns the line's
  /// starting point if the line is coplanar with the plane.
  ///
  /// - [line] - the Line3 to check for intersection.
  /// - [target] — the result will be copied into this Vector3.
  /// - returns Vector3 or null
  intersectLine(Line3 line, Vector3 target) {
    final direction = line.delta(_vector1);

    final denominator = normal.dot(direction);

    if (denominator == 0) {
      // line is coplanar, return origin
      if (distanceToPoint(line.start) == 0) {
        return target.copy(line.start);
      }

      // Unsure if this is the correct method to handle this case.
      return null;
    }

    final t = -(line.start.dot(normal) + constant) / denominator;

    if (t < 0 || t > 1) {
      return null;
    }

    return target.copy(direction).multiplyScalar(t).add(line.start);
  }

  /// Tests whether a line segment intersects with (passes through) the plane.
  ///
  /// - [line] - the Line3 to check for intersection.
  bool intersectsLine(Line3 line) {
    // Note: this tests if a line intersects the plane, not whether it (or its end-points) are coplanar with it.

    final startSign = distanceToPoint(line.start);
    final endSign = distanceToPoint(line.end);

    return (startSign < 0 && endSign > 0) || (endSign < 0 && startSign > 0);
  }

  /// Determines whether or not this plane intersects box.
  ///
  /// - [box] - the Box3 to check for intersection.
  bool intersectsBox(Box3 box) {
    return box.intersectsPlane(this);
  }

  /// Determines whether or not this plane intersects sphere.
  ///
  /// - [sphere] - the Sphere to check for intersection.
  bool intersectsSphere(Sphere sphere) {
    return sphere.intersectsPlane(this);
  }

  /// Returns a Vector3 coplanar to the plane, by calculating the projection of
  /// the normal vector at the origin onto the plane.
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 coplanarPoint(Vector3 target) {
    return target.copy(normal).multiplyScalar(-constant);
  }

  /// Apply a Matrix4 to the plane. The matrix must be an affine, homogeneous transform.
  /// If supplying an optionalNormalMatrix, it can be created like so:
  ///
  /// - [matrix] - the Matrix4 to apply.
  /// - [optionalNormalMatrix] - (optional) pre-computed normal Matrix3 of the Matrix4 being applied.
  Plane applyMatrix4(Matrix4 matrix, [Matrix3? optionalNormalMatrix]) {
    final normalMatrix = optionalNormalMatrix ?? _normalMatrix.getNormalMatrix(matrix);

    final referencePoint = coplanarPoint(_vector1).applyMatrix4(matrix);

    final normal = this.normal.applyMatrix3(normalMatrix).normalize();

    constant = -referencePoint.dot(normal);

    return this;
  }

  /// Translates the plane by the distance defined by the offset vector. Note that this only affects
  /// the plane constant and will not affect the normal vector.
  ///
  /// - [offset] - the amount to move the plane by.
  Plane translate(Vector3 offset) {
    constant -= offset.dot(normal);

    return this;
  }

  /// Checks to see if two planes are equal (their normal and constant properties match).
  bool equals(Plane plane) {
    return plane.normal.equals(normal) && (plane.constant == constant);
  }

  /// Returns a new plane with the same normal and constant as this one.
  Plane clone() {
    return Plane().copy(this);
  }
}
