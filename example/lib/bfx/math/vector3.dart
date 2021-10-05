import 'package:flgl_example/bfx/cameras/camera.dart';
import 'dart:math' as math;
import 'math_utils.dart';
import 'matrix3.dart';
import 'matrix4.dart';
import 'quaternion.dart';

var _vector = Vector3();
var _quaternion = Quaternion();

class Vector3 {
  bool isVector3 = true;

  double x;
  double y;
  double z;

  Vector3([this.x = 0, this.y = 0, this.z = 0]);

  set(double _x, double _y, double _z) {
    _z ??= z; // sprite.scale.set(x,y)

    x = _x;
    y = _y;
    z = _z;

    return this;
  }

  setScalar(scalar) {
    x = scalar;
    y = scalar;
    z = scalar;

    return this;
  }

  setX(x) {
    this.x = x;
    return this;
  }

  setY(y) {
    this.y = y;
    return this;
  }

  setZ(z) {
    this.z = z;
    return this;
  }

  setComponent(int index, value) {
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

  getComponent(int index) {
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

  clone() {
    return Vector3(x, y, z);
  }

  copy(Vector3 v) {
    x = v.x;
    y = v.y;
    z = v.z;
    return this;
  }

  add(v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;
    z += v.z;

    return this;
  }

  addScalar(s) {
    x += s;
    y += s;
    z += s;
    return this;
  }

  addVectors(Vector3 a, Vector3 b) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    return this;
  }

  addScaledVector(Vector3 v, s) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;
    return this;
  }

  sub(Vector3 v, [w]) {
    if (w != null) {
      print('THREE.Vector3: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;
    z -= v.z;

    return this;
  }

  subScalar(s) {
    x -= s;
    y -= s;
    z -= s;
    return this;
  }

  subVectors(Vector3 a, Vector3 b) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    return this;
  }

  multiply(v, w) {
    if (w != null) {
      print('THREE.Vector3: .multiply() now only accepts one argument. Use .multiplyVectors( a, b ) instead.');
      return this.multiplyVectors(v, w);
    }

    x *= v.x;
    y *= v.y;
    z *= v.z;
    return this;
  }

  multiplyScalar(scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
    return this;
  }

  multiplyVectors(Vector3 a, Vector3 b) {
    x = a.x * b.x;
    y = a.y * b.y;
    z = a.z * b.z;
    return this;
  }

  applyEuler(euler) {
    if (!(euler && euler.isEuler)) {
      print('THREE.Vector3: .applyEuler() now expects an Euler rotation rather than a Vector3 and order.');
    }

    return applyQuaternion(_quaternion.setFromEuler(euler));
  }

  applyAxisAngle(axis, angle) {
    return applyQuaternion(_quaternion.setFromAxisAngle(axis, angle));
  }

  applyMatrix3(Matrix3 m) {
    var x = this.x, y = this.y, z = this.z;
    var e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6] * z;
    this.y = e[1] * x + e[4] * y + e[7] * z;
    this.z = e[2] * x + e[5] * y + e[8] * z;

    return this;
  }

  applyNormalMatrix(m) {
    return applyMatrix3(m).normalize();
  }

  applyMatrix4(Matrix4 m) {
    var x = this.x, y = this.y, z = this.z;
    var e = m.elements;

    var w = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15]);

    this.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * w;
    this.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * w;
    this.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * w;

    return this;
  }

  applyQuaternion(q) {
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

  project(Camera camera) {
    return applyMatrix4(camera.matrixWorldInverse).applyMatrix4(camera.projectionMatrix);
  }

  unproject(Camera camera) {
    return applyMatrix4(camera.projectionMatrixInverse).applyMatrix4(camera.matrixWorld);
  }

  transformDirection(m) {
    // input: THREE.Matrix4 affine matrix
    // vector interpreted as a direction

    var x = this.x, y = this.y, z = this.z;
    var e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z;
    this.y = e[1] * x + e[5] * y + e[9] * z;
    this.z = e[2] * x + e[6] * y + e[10] * z;

    return normalize();
  }

  divide(Vector3 v) {
    x /= v.x;
    y /= v.y;
    z /= v.z;

    return this;
  }

  divideScalar(scalar) {
    return multiplyScalar(1 / scalar);
  }

  min(Vector3 v) {
    x = math.min(x, v.x);
    y = math.min(y, v.y);
    z = math.min(z, v.z);

    return this;
  }

  max(v) {
    x = math.max(x, v.x);
    y = math.max(y, v.y);
    z = math.max(z, v.z);

    return this;
  }

  clamp(Vector3 min, Vector3 max) {
    // assumes min < max, componentwise

    x = math.max(min.x, math.min(max.x, x));
    y = math.max(min.y, math.min(max.y, y));
    z = math.max(min.z, math.min(max.z, z));

    return this;
  }

  clampScalar(minVal, maxVal) {
    x = math.max(minVal, math.min(maxVal, x));
    y = math.max(minVal, math.min(maxVal, y));
    z = math.max(minVal, math.min(maxVal, z));

    return this;
  }

  clampLength(num min, num max) {
    var _length = length();
    var _max = math.max(min, math.min(max, _length));
    return divideScalar(_length ?? 1).multiplyScalar(_max);
  }

  floor() {
    x = x.floor().toDouble();
    y = y.floor().toDouble();
    z = z.floor().toDouble();

    return this;
  }

  ceil() {
    x = x.ceil().toDouble();
    y = y.ceil().toDouble();
    z = z.ceil().toDouble();

    return this;
  }

  round() {
    x = x.round().toDouble();
    y = y.round().toDouble();
    z = z.round().toDouble();
    return this;
  }

  roundToZero() {
    x = (x < 0) ? x.ceil().toDouble() : x.floor().toDouble();
    y = (y < 0) ? y.ceil().toDouble() : y.floor().toDouble();
    z = (z < 0) ? z.ceil().toDouble() : z.floor().toDouble();

    return this;
  }

  negate() {
    x = -x;
    y = -y;
    z = -z;

    return this;
  }

  dot(Vector3 v) {
    return x * v.x + y * v.y + z * v.z;
  }

  lengthSq() {
    return x * x + y * y + z * z;
  }

  double length() {
    return math.sqrt(x * x + y * y + z * z);
  }

  manhattanLength() {
    return x.abs() + y.abs() + z.abs();
  }

  normalize() {
    return divideScalar(length() ?? 1);
  }

  setLength(length) {
    return normalize().multiplyScalar(length);
  }

  lerp(v, alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;

    return this;
  }

  lerpVectors(Vector3 v1, Vector3 v2, alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;

    return this;
  }

  cross(v, w) {
    if (w != null) {
      print('THREE.Vector3: .cross() now only accepts one argument. Use .crossVectors( a, b ) instead.');
      return crossVectors(v, w);
    }

    return crossVectors(this, v);
  }

  crossVectors(Vector3 a, Vector3 b) {
    var ax = a.x, ay = a.y, az = a.z;
    var bx = b.x, by = b.y, bz = b.z;

    x = ay * bz - az * by;
    y = az * bx - ax * bz;
    z = ax * by - ay * bx;

    return this;
  }

  projectOnVector(Vector3 v) {
    var denominator = v.lengthSq();

    if (denominator == 0) return set(0, 0, 0);

    var scalar = v.dot(this) / denominator;

    return copy(v).multiplyScalar(scalar);
  }

  projectOnPlane(planeNormal) {
    _vector.copy(this).projectOnVector(planeNormal);

    return sub(_vector);
  }

  reflect(normal) {
    // reflect incident vector off plane orthogonal to normal
    // normal is assumed to have unit length

    return sub(_vector.copy(normal).multiplyScalar(2 * dot(normal)));
  }

  angleTo(Vector3 v) {
    var denominator = math.sqrt(lengthSq() * v.lengthSq());

    if (denominator == 0) return math.pi / 2;

    var theta = dot(v) / denominator;

    // clamp, to handle numerical problems

    return math.acos(MathUtils.clamp(theta, -1, 1));
  }

  distanceTo(Vector3 v) {
    return math.sqrt(distanceToSquared(v));
  }

  distanceToSquared(Vector3 v) {
    var dx = x - v.x, dy = y - v.y, dz = z - v.z;

    return dx * dx + dy * dy + dz * dz;
  }

  manhattanDistanceTo(Vector3 v) {
    return (x - v.x).abs() + (y - v.y).abs() + (z - v.z).abs();
  }

  setFromSpherical(s) {
    return setFromSphericalCoords(s.radius, s.phi, s.theta);
  }

  setFromSphericalCoords(radius, phi, theta) {
    var sinPhiRadius = math.sin(phi) * radius;

    x = sinPhiRadius * math.sin(theta);
    y = math.cos(phi) * radius;
    z = sinPhiRadius * math.cos(theta);

    return this;
  }

  setFromCylindrical(c) {
    return setFromCylindricalCoords(c.radius, c.theta, c.y);
  }

  setFromCylindricalCoords(radius, theta, y) {
    x = radius * math.sin(theta);
    y = y;
    z = radius * math.cos(theta);

    return this;
  }

  setFromMatrixPosition(m) {
    var e = m.elements;

    x = e[12];
    y = e[13];
    z = e[14];

    return this;
  }

  setFromMatrixScale(m) {
    var sx = setFromMatrixColumn(m, 0).length();
    var sy = setFromMatrixColumn(m, 1).length();
    var sz = setFromMatrixColumn(m, 2).length();

    x = sx;
    y = sy;
    z = sz;

    return this;
  }

  setFromMatrixColumn(m, index) {
    return fromArray(m.elements, index * 4);
  }

  setFromMatrix3Column(Matrix3 m, index) {
    return fromArray(m.elements, index * 3);
  }

  equals(Vector3 v) {
    return ((v.x == x) && (v.y == y) && (v.z == z));
  }

  fromArray(array, [offset = 0]) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];

    return this;
  }

  toArray([array = List, offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;

    return array;
  }

  fromBufferAttribute(attribute, index, [offset]) {
    if (offset != null) {
      print('THREE.Vector3: offset has been removed from .fromBufferAttribute().');
    }

    x = attribute.getX(index);
    y = attribute.getY(index);
    z = attribute.getZ(index);

    return this;
  }

  random() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();

    return this;
  }

  randomDirection() {
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
