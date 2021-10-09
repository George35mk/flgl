import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/core/buffer_attribute.dart';
import 'dart:math' as math;
import 'cylindrical.dart';
import 'euler.dart';
import 'math_utils.dart';
import 'matrix3.dart';
import 'matrix4.dart';
import 'quaternion.dart';
import 'spherical.dart';

var _vector = Vector3();
var _quaternion = Quaternion();

class Vector3 {
  bool isVector3 = true;

  double x;
  double y;
  double z;

  Vector3([this.x = 0, this.y = 0, this.z = 0]);

  /// Sets the x, y and z components of this vector.
  Vector3 set(double _x, double _y, double _z) {
    _z ??= z; // sprite.scale.set(x,y)

    x = _x;
    y = _y;
    z = _z;

    return this;
  }

  /// Set the x, y and z values of this vector both equal to scalar.
  Vector3 setScalar(double scalar) {
    x = scalar;
    y = scalar;
    z = scalar;

    return this;
  }

  /// Replace this vector's x value with x.
  Vector3 setX(x) {
    this.x = x;
    return this;
  }

  /// Replace this vector's y value with y.
  Vector3 setY(y) {
    this.y = y;
    return this;
  }

  /// Replace this vector's z value with z.
  Vector3 setZ(z) {
    this.z = z;
    return this;
  }

  /// - index - 0, 1 or 2.
  /// - value - Float
  ///
  /// - If index equals 0 set x to value.
  /// - If index equals 1 set y to value.
  /// - If index equals 2 set z to value
  Vector3 setComponent(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      case 2:
        z = value;
        break;
      default:
        throw ('index is out of range: $index');
    }

    return this;
  }

  /// - index - 0, 1 or 2.
  ///
  /// - If index equals 0 returns the x value.
  /// - If index equals 1 returns the y value.
  /// - If index equals 2 returns the z value.
  double getComponent(int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      default:
        throw ('index is out of range: $index');
    }
  }

  /// Returns a new vector3 with the same x, y and z values as this one.
  Vector3 clone() {
    return Vector3(x, y, z);
  }

  /// Copies the values of the passed vector3's x, y and z properties to this vector3.
  Vector3 copy(Vector3 v) {
    x = v.x;
    y = v.y;
    z = v.z;
    return this;
  }

  /// Adds v to this vector.
  Vector3 add(Vector3 v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;
    z += v.z;

    return this;
  }

  /// Adds the scalar value s to this vector's x, y and z values.
  Vector3 addScalar(double s) {
    x += s;
    y += s;
    z += s;
    return this;
  }

  /// Sets this vector to a + b.
  Vector3 addVectors(Vector3 a, Vector3 b) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    return this;
  }

  /// Adds the multiple of v and s to this vector.
  Vector3 addScaledVector(Vector3 v, double s) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;
    return this;
  }

  /// Subtracts v from this vector.
  Vector3 sub(Vector3 v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;
    z -= v.z;

    return this;
  }

  /// Subtracts s from this vector's x, y and z compnents.
  Vector3 subScalar(double s) {
    x -= s;
    y -= s;
    z -= s;
    return this;
  }

  /// Sets this vector to a - b.
  Vector3 subVectors(Vector3 a, Vector3 b) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    return this;
  }

  /// Multiplies this vector by v.
  Vector3 multiply(v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .multiply() now only accepts one argument. Use .multiplyVectors( a, b ) instead.');
      return multiplyVectors(v, w);
    }

    x *= v.x;
    y *= v.y;
    z *= v.z;
    return this;
  }

  /// Multiplies this vector by scalar s.
  Vector3 multiplyScalar(double scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
    return this;
  }

  /// Sets this vector equal to a * b, component-wise
  Vector3 multiplyVectors(Vector3 a, Vector3 b) {
    x = a.x * b.x;
    y = a.y * b.y;
    z = a.z * b.z;
    return this;
  }

  /// Applies euler transform to this vector by converting
  /// the Euler object to a Quaternion and applying.
  applyEuler(Euler euler) {
    if (!(euler != null && euler.isEuler)) {
      print('THREE.Vector3: .applyEuler() now expects an Euler rotation rather than a Vector3 and order.');
    }

    return applyQuaternion(_quaternion.setFromEuler(euler));
  }

  /// Applies a rotation specified by an axis and an angle to this vector.
  ///
  /// - [axis] - A normalized Vector3.
  /// - [angle] - An angle in radians.
  applyAxisAngle(Vector3 axis, double angle) {
    return applyQuaternion(_quaternion.setFromAxisAngle(axis, angle));
  }

  /// Multiplies this vector by [m]
  Vector3 applyMatrix3(Matrix3 m) {
    var x = this.x;
    var y = this.y;
    var z = this.z;
    var e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6] * z;
    this.y = e[1] * x + e[4] * y + e[7] * z;
    this.z = e[2] * x + e[5] * y + e[8] * z;

    return this;
  }

  /// Multiplies this vector by normal matrix m and normalizes the result.
  Vector3 applyNormalMatrix(Matrix3 m) {
    return applyMatrix3(m).normalize();
  }

  /// Multiplies this vector (with an implicit 1 in the 4th dimension) and m, and divides by perspective.
  Vector3 applyMatrix4(Matrix4 m) {
    var x = this.x;
    var y = this.y;
    var z = this.z;
    var e = m.elements;

    var w = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15]);

    this.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * w;
    this.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * w;
    this.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w;

    return this;
  }

  /// Applies a Quaternion transform to this vector.
  Vector3 applyQuaternion(Quaternion q) {
    var x = this.x, y = this.y, z = this.z;
    var qx = q.x, qy = q.y, qz = q.z, qw = q.w;

    // calculate quat * vector

    var ix = qw * x + qy * z - qz * y;
    var iy = qw * y + qz * x - qx * z;
    var iz = qw * z + qx * y - qy * x;
    var iw = -qx * x - qy * y - qz * z;

    // calculate result * inverse quat

    this.x = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    this.y = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    this.z = iz * qw + iw * -qz + ix * -qy - iy * -qx;

    return this;
  }

  /// Projects this vector from world space into the camera's
  /// normalized device coordinate (NDC) space.
  ///
  /// - [camera] — camera to use in the projection.
  Vector3 project(Camera camera) {
    return applyMatrix4(camera.matrixWorldInverse).applyMatrix4(camera.projectionMatrix);
  }

  /// Projects this vector from the camera's normalized device
  /// coordinate (NDC) space into world space.
  ///
  /// - [camera] — camera to use in the projection.
  Vector3 unproject(Camera camera) {
    return applyMatrix4(camera.projectionMatrixInverse).applyMatrix4(camera.matrixWorld);
  }

  /// Transforms the direction of this vector by a matrix
  /// (the upper left 3 x 3 subset of a m) and then
  /// normalizes the result.
  Vector3 transformDirection(Matrix4 m) {
    // input: THREE.Matrix4 affine matrix
    // vector interpreted as a direction

    var x = this.x;
    var y = this.y;
    var z = this.z;
    var e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z;
    this.y = e[1] * x + e[5] * y + e[9] * z;
    this.z = e[2] * x + e[6] * y + e[10] * z;

    return normalize();
  }

  /// Divides this vector by v.
  Vector3 divide(Vector3 v) {
    x /= v.x;
    y /= v.y;
    z /= v.z;

    return this;
  }

  /// Divides this vector by scalar s.
  /// Sets vector to ( 0, 0, 0 ) if *s = 0*.
  Vector3 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }

  /// If this vector's x, y or z value is greater than v's x, y or z
  /// value, replace that value with the corresponding min value.
  Vector3 min(Vector3 v) {
    x = math.min(x, v.x);
    y = math.min(y, v.y);
    z = math.min(z, v.z);

    return this;
  }

  /// If this vector's x, y or z value is less than v's x, y or z
  /// value, replace that value with the corresponding max value.
  Vector3 max(Vector3 v) {
    x = math.max(x, v.x);
    y = math.max(y, v.y);
    z = math.max(z, v.z);

    return this;
  }

  /// If this vector's x, y or z value is greater than the max
  /// vector's x, y or z value, it is replaced by the corresponding value.
  ///
  /// If this vector's x, y or z value is less than the min vector's x, y or z
  /// value, it is replaced by the corresponding value.
  ///
  /// - [min] - the minimum x, y and z values.
  /// - [max] - the maximum x, y and z values in the desired range
  Vector3 clamp(Vector3 min, Vector3 max) {
    // assumes min < max, componentwise

    x = math.max(min.x, math.min(max.x, x));
    y = math.max(min.y, math.min(max.y, y));
    z = math.max(min.z, math.min(max.z, z));

    return this;
  }

  /// If this vector's x, y or z values are greater than the max
  /// value, they are replaced by the max value.
  ///
  /// If this vector's x, y or z values are less than the min value,
  /// they are replaced by the min value.
  ///
  /// - [min] - the minimum value the components will be clamped to
  /// - [max] - the maximum value the components will be clamped to
  Vector3 clampScalar(double minVal, double maxVal) {
    x = math.max(minVal, math.min(maxVal, x));
    y = math.max(minVal, math.min(maxVal, y));
    z = math.max(minVal, math.min(maxVal, z));

    return this;
  }

  /// If this vector's length is greater than the max value, the
  /// vector will be scaled down so its length is the max value.
  ///
  /// If this vector's length is less than the min value, the
  /// vector will be scaled up so its length is the min value.
  ///
  /// - [min] - the minimum value the length will be clamped to
  /// - [max] - the maximum value the length will be clamped to
  Vector3 clampLength(double min, double max) {
    var _length = length();
    var _max = math.max(min, math.min(max, _length));
    return divideScalar(_length ?? 1).multiplyScalar(_max);
  }

  /// The components of this vector are rounded down to the nearest
  /// integer value.
  Vector3 floor() {
    x = x.floor().toDouble();
    y = y.floor().toDouble();
    z = z.floor().toDouble();

    return this;
  }

  /// The x, y and z components of this vector are rounded up to
  /// the nearest integer value.
  Vector3 ceil() {
    x = x.ceil().toDouble();
    y = y.ceil().toDouble();
    z = z.ceil().toDouble();

    return this;
  }

  /// The components of this vector are rounded to the nearest
  /// integer value.
  Vector3 round() {
    x = x.round().toDouble();
    y = y.round().toDouble();
    z = z.round().toDouble();
    return this;
  }

  /// The components of this vector are rounded towards zero
  /// (up if negative, down if positive) to an integer value.
  Vector3 roundToZero() {
    x = (x < 0) ? x.ceil().toDouble() : x.floor().toDouble();
    y = (y < 0) ? y.ceil().toDouble() : y.floor().toDouble();
    z = (z < 0) ? z.ceil().toDouble() : z.floor().toDouble();

    return this;
  }

  /// Inverts this vector - i.e. sets x = -x, y = -y and z = -z.
  Vector3 negate() {
    x = -x;
    y = -y;
    z = -z;

    return this;
  }

  /// Calculate the dot product of this vector and v.
  double dot(Vector3 v) {
    return x * v.x + y * v.y + z * v.z;
  }

  /// Computes the square of the Euclidean length (straight-line length)
  /// from (0, 0, 0) to (x, y, z). If you are comparing the lengths of
  /// vectors, you should compare the length squared instead as it is
  /// slightly more efficient to calculate.
  double lengthSq() {
    return x * x + y * y + z * z;
  }

  /// Computes the Euclidean length (straight-line length)
  /// from (0, 0, 0) to (x, y, z).
  double length() {
    return math.sqrt(x * x + y * y + z * z);
  }

  /// Computes the Manhattan length of this vector.
  double manhattanLength() {
    return x.abs() + y.abs() + z.abs();
  }

  /// Convert this vector to a unit vector - that is, sets it equal to a vector
  /// with the same direction as this one, but length 1.
  Vector3 normalize() {
    return divideScalar(length() ?? 1);
  }

  /// Set this vector to a vector with the same direction as this one, but length l.
  Vector3 setLength(double length) {
    return normalize().multiplyScalar(length);
  }

  /// Linearly interpolate between this vector and v, where alpha is the percent
  /// distance along the line - alpha = 0 will be this vector,
  /// and alpha = 1 will be v.
  ///
  /// - [v] - Vector3 to interpolate towards.
  /// - [alpha] - interpolation factor, typically in the closed interval [0, 1].
  Vector3 lerp(Vector3 v, double alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;

    return this;
  }

  /// Sets this vector to be the vector linearly interpolated between v1 and v2
  /// where alpha is the percent distance along the line connecting the two
  /// vectors - alpha = 0 will be v1, and alpha = 1 will be v2.
  ///
  /// - [v1] - the starting Vector3.
  /// - [v2] - Vector3 to interpolate towards.
  /// - [alpha] - interpolation factor, typically in the closed interval [0, 1].
  Vector3 lerpVectors(Vector3 v1, Vector3 v2, alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;

    return this;
  }

  /// Sets this vector to cross product of itself and v.
  Vector3 cross(Vector3 v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .cross() now only accepts one argument. Use .crossVectors( a, b ) instead.');
      return crossVectors(v, w);
    }

    return crossVectors(this, v);
  }

  /// Sets this vector to cross product of a and b.
  Vector3 crossVectors(Vector3 a, Vector3 b) {
    var ax = a.x, ay = a.y, az = a.z;
    var bx = b.x, by = b.y, bz = b.z;

    x = ay * bz - az * by;
    y = az * bx - ax * bz;
    z = ax * by - ay * bx;

    return this;
  }

  /// Projects this vector onto [v].
  Vector3 projectOnVector(Vector3 v) {
    var denominator = v.lengthSq();

    if (denominator == 0) return set(0, 0, 0);

    var scalar = v.dot(this) / denominator;

    return copy(v).multiplyScalar(scalar);
  }

  /// Projects this vector onto a plane by subtracting this vector
  /// projected onto the plane's normal from this vector.
  ///
  /// - [planeNormal] - A vector representing a plane normal.
  Vector3 projectOnPlane(Vector3 planeNormal) {
    _vector.copy(this).projectOnVector(planeNormal);

    return sub(_vector);
  }

  /// Reflect this vector off of plane orthogonal to normal.
  /// Normal is assumed to have unit length.
  ///
  /// - [normal] - the normal to the reflecting plane
  Vector3 reflect(Vector3 normal) {
    // reflect incident vector off plane orthogonal to normal
    // normal is assumed to have unit length

    return sub(_vector.copy(normal).multiplyScalar(2 * dot(normal)));
  }

  /// Returns the angle between this vector and vector v in radians.
  double angleTo(Vector3 v) {
    var denominator = math.sqrt(lengthSq() * v.lengthSq());

    if (denominator == 0) return math.pi / 2;

    var theta = dot(v) / denominator;

    // clamp, to handle numerical problems

    return math.acos(MathUtils.clamp(theta, -1, 1));
  }

  /// Computes the distance from this vector to v.
  double distanceTo(Vector3 v) {
    return math.sqrt(distanceToSquared(v));
  }

  /// Computes the squared distance from this vector to v.
  /// If you are just comparing the distance with another distance,
  /// you should compare the distance squared instead as it is
  /// slightly more efficient to calculate.
  double distanceToSquared(Vector3 v) {
    var dx = x - v.x, dy = y - v.y, dz = z - v.z;

    return dx * dx + dy * dy + dz * dz;
  }

  /// Computes the Manhattan distance from this vector to v.
  double manhattanDistanceTo(Vector3 v) {
    return (x - v.x).abs() + (y - v.y).abs() + (z - v.z).abs();
  }

  /// Sets this vector from the spherical coordinates s.
  Vector3 setFromSpherical(Spherical s) {
    return setFromSphericalCoords(s.radius, s.phi, s.theta);
  }

  /// Sets this vector from the spherical coordinates radius, phi and theta.
  Vector3 setFromSphericalCoords(double radius, double phi, double theta) {
    var sinPhiRadius = math.sin(phi) * radius;

    x = sinPhiRadius * math.sin(theta);
    y = math.cos(phi) * radius;
    z = sinPhiRadius * math.cos(theta);

    return this;
  }

  /// Sets this vector from the cylindrical coordinates c.
  setFromCylindrical(Cylindrical c) {
    return setFromCylindricalCoords(c.radius, c.theta, c.y);
  }

  /// Sets this vector from the cylindrical coordinates radius, theta and y.
  Vector3 setFromCylindricalCoords(double radius, double theta, double _y) {
    x = radius * math.sin(theta);
    y = _y;
    z = radius * math.cos(theta);

    return this;
  }

  /// Sets this vector to the position elements of the transformation matrix m.
  Vector3 setFromMatrixPosition(Matrix4 m) {
    var e = m.elements;

    x = e[12];
    y = e[13];
    z = e[14];

    return this;
  }

  /// Sets this vector to the scale elements of the transformation matrix m.
  Vector3 setFromMatrixScale(Matrix4 m) {
    var sx = setFromMatrixColumn(m, 0).length();
    var sy = setFromMatrixColumn(m, 1).length();
    var sz = setFromMatrixColumn(m, 2).length();

    x = sx;
    y = sy;
    z = sz;

    return this;
  }

  /// Sets this vector's x, y and z components from index column of matrix.
  Vector3 setFromMatrixColumn(Matrix4 m, int index) {
    return fromArray(m.elements, index * 4);
  }

  /// Sets this vector's x, y and z components from index column of matrix.
  Vector3 setFromMatrix3Column(Matrix3 m, int index) {
    return fromArray(m.elements, index * 3);
  }

  /// Returns true if the components of this vector and v are strictly equal;
  /// false otherwise.
  bool equals(Vector3 v) {
    return ((v.x == x) && (v.y == y) && (v.z == z));
  }

  /// Sets this vector's x value to be array[ offset + 0 ], y value to be
  /// array[ offset + 1 ] and z value to be array[ offset + 2 ].
  ///
  /// - [array] - the source array.
  /// - [offset] - ( optional) offset into the array. Default is 0.
  Vector3 fromArray(List<double> array, [int offset = 0]) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];

    return this;
  }

  /// Returns an array [x, y, z], or copies x, y and z into the provided array.
  ///
  ///- [array] - (optional) array to store this vector to. If this is not provided a new array will be created.
  ///- [offset] - (optional) optional offset into the array.
  List<double> toArray([List<double> array = const [], int offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;

    return array;
  }

  Vector3 fromBufferAttribute(BufferAttribute attribute, int index, [offset]) {
    if (offset != null) {
      print('THREE.Vector3: offset has been removed from .fromBufferAttribute().');
    }

    x = attribute.getX(index);
    y = attribute.getY(index);
    z = attribute.getZ(index);

    return this;
  }

  /// Sets each component of this vector to a pseudo-random value between 0 and 1, excluding 1.
  Vector3 random() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();

    return this;
  }

  /// Sets this vector to a uniformly random point on a unit sphere.
  Vector3 randomDirection() {
    // Derived from https://mathworld.wolfram.com/SpherePointPicking.html

    var u = (math.Random().nextDouble() - 0.5) * 2;
    var t = math.Random().nextDouble() * math.pi * 2;
    // var f = math.sqrt( 1 - u ** 2 );
    var f = math.sqrt(1 - u * 2); // this will be a problem

    x = f * math.cos(t);
    y = f * math.sin(t);
    z = u;

    return this;
  }

  // operator [](String i) => list[i]; // get
  operator []=(String i, double value) => {
        if (i == 'x')
          {x = value}
        else if (i == 'y')
          {y = value}
        else if (i == 'z')
          {z = value}
        else
          {throw 'Unknown operator'}
      }; // set

}
