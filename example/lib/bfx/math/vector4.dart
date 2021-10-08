import 'matrix4.dart';
import 'quaternion.dart';
import 'dart:math' as math;

class Vector4 {
  bool isVector4 = true;

  double x;
  double y;
  double z;
  double w;

  Vector4([this.x = 0, this.y = 0, this.z = 0, this.w = 0]);

  get width {
    return z;
  }

  set width(value) {
    z = value;
  }

  get height {
    return w;
  }

  set height(value) {
    w = value;
  }

  Vector4 set(x, y, z, w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;

    return this;
  }

  Vector4 setScalar(scalar) {
    x = scalar;
    y = scalar;
    z = scalar;
    w = scalar;

    return this;
  }

  Vector4 setX(x) {
    this.x = x;

    return this;
  }

  Vector4 setY(y) {
    this.y = y;

    return this;
  }

  Vector4 setZ(z) {
    this.z = z;

    return this;
  }

  Vector4 setW(w) {
    this.w = w;

    return this;
  }

  Vector4 setComponent(index, value) {
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
      case 3:
        w = value;
        break;
      default:
        throw ('index is out of range: $index');
    }

    return this;
  }

  getComponent(index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return w;
      default:
        throw ('index is out of range: $index');
    }
  }

  Vector4 clone() {
    return Vector4(x, y, z, w);
  }

  Vector4 copy(Vector4 v) {
    x = v.x;
    y = v.y;
    z = v.z;
    w = (v.w != null) ? v.w : 1;

    return this;
  }

  Vector4 add(Vector4 v, [w]) {
    if (w != null) {
      print('THREE.Vector4: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;
    z += v.z;
    w += v.w;

    return this;
  }

  Vector4 addScalar(double s) {
    x += s;
    y += s;
    z += s;
    w += s;

    return this;
  }

  Vector4 addVectors(Vector4 a, Vector4 b) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    w = a.w + b.w;

    return this;
  }

  Vector4 addScaledVector(Vector4 v, double s) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;
    w += v.w * s;

    return this;
  }

  Vector4 sub(Vector4 v, [w]) {
    if (w != null) {
      print('THREE.Vector4: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;
    z -= v.z;
    w -= v.w;

    return this;
  }

  Vector4 subScalar(double s) {
    x -= s;
    y -= s;
    z -= s;
    w -= s;

    return this;
  }

  Vector4 subVectors(Vector4 a, Vector4 b) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    w = a.w - b.w;

    return this;
  }

  Vector4 multiply(Vector4 v) {
    x *= v.x;
    y *= v.y;
    z *= v.z;
    w *= v.w;

    return this;
  }

  Vector4 multiplyScalar(double scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
    w *= scalar;

    return this;
  }

  Vector4 applyMatrix4(Matrix4 m) {
    var x = this.x, y = this.y, z = this.z, w = this.w;
    final e = m.elements;

    this.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w;
    this.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w;
    this.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w;
    this.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w;

    return this;
  }

  Vector4 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }

  setAxisAngleFromQuaternion(Quaternion q) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/index.htm

    // q is assumed to be normalized

    w = 2 * math.acos(q.w);

    var s = math.sqrt(1 - q.w * q.w);

    if (s < 0.0001) {
      x = 1;
      y = 0;
      z = 0;
    } else {
      x = q.x / s;
      y = q.y / s;
      z = q.z / s;
    }

    return this;
  }

  Vector4 setAxisAngleFromRotationMatrix(m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToAngle/index.htm

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    var angle, x, y, z; // variables for result
    var epsilon = 0.01; // margin to allow for rounding errors
    var epsilon2 = 0.1; // margin to distinguish between 0 and 180 degrees

    var te = m.elements,
        m11 = te[0],
        m12 = te[4],
        m13 = te[8],
        m21 = te[1],
        m22 = te[5],
        m23 = te[9],
        m31 = te[2],
        m32 = te[6],
        m33 = te[10];

    if (((m12 - m21).abs() < epsilon) && ((m13 - m31).abs() < epsilon) && ((m23 - m32).abs() < epsilon)) {
      // singularity found
      // first check for identity matrix which must have +1 for all terms
      // in leading diagonal and zero in other terms

      if (((m12 + m21).abs() < epsilon2) &&
          ((m13 + m31).abs() < epsilon2) &&
          ((m23 + m32).abs() < epsilon2) &&
          ((m11 + m22 + m33 - 3).abs() < epsilon2)) {
        // this singularity is identity matrix so angle = 0

        set(1, 0, 0, 0);

        return this; // zero angle, arbitrary axis

      }

      // otherwise this singularity is angle = 180

      angle = math.pi;

      var xx = (m11 + 1) / 2;
      var yy = (m22 + 1) / 2;
      var zz = (m33 + 1) / 2;
      var xy = (m12 + m21) / 4;
      var xz = (m13 + m31) / 4;
      var yz = (m23 + m32) / 4;

      if ((xx > yy) && (xx > zz)) {
        // m11 is the largest diagonal term

        if (xx < epsilon) {
          x = 0;
          y = 0.707106781;
          z = 0.707106781;
        } else {
          x = math.sqrt(xx);
          y = xy / x;
          z = xz / x;
        }
      } else if (yy > zz) {
        // m22 is the largest diagonal term

        if (yy < epsilon) {
          x = 0.707106781;
          y = 0;
          z = 0.707106781;
        } else {
          y = math.sqrt(yy);
          x = xy / y;
          z = yz / y;
        }
      } else {
        // m33 is the largest diagonal term so base result on this

        if (zz < epsilon) {
          x = 0.707106781;
          y = 0.707106781;
          z = 0;
        } else {
          z = math.sqrt(zz);
          x = xz / z;
          y = yz / z;
        }
      }

      set(x, y, z, angle);

      return this; // return 180 deg rotation

    }

    // as we have reached here there are no singularities so we can handle normally

    double s = math
        .sqrt((m32 - m23) * (m32 - m23) + (m13 - m31) * (m13 - m31) + (m21 - m12) * (m21 - m12)); // used to normalize

    if (s.abs() < 0.001) s = 1;

    // prevent divide by zero, should not happen if matrix is orthogonal and should be
    // caught by singularity test above, but I've left it in just in case

    this.x = (m32 - m23) / s;
    this.y = (m13 - m31) / s;
    this.z = (m21 - m12) / s;
    this.w = math.acos((m11 + m22 + m33 - 1) / 2);

    return this;
  }

  Vector4 min(Vector4 v) {
    x = math.min(x, v.x);
    y = math.min(y, v.y);
    z = math.min(z, v.z);
    w = math.min(w, v.w);

    return this;
  }

  Vector4 max(Vector4 v) {
    x = math.max(x, v.x);
    y = math.max(y, v.y);
    z = math.max(z, v.z);
    w = math.max(w, v.w);

    return this;
  }

  Vector4 clamp(Vector4 min, Vector4 max) {
    // assumes min < max, componentwise

    x = math.max(min.x, math.min(max.x, x));
    y = math.max(min.y, math.min(max.y, y));
    z = math.max(min.z, math.min(max.z, z));
    w = math.max(min.w, math.min(max.w, w));

    return this;
  }

  Vector4 clampScalar(minVal, maxVal) {
    x = math.max(minVal, math.min(maxVal, x));
    y = math.max(minVal, math.min(maxVal, y));
    z = math.max(minVal, math.min(maxVal, z));
    w = math.max(minVal, math.min(maxVal, w));

    return this;
  }

  Vector4 clampLength(min, max) {
    var _length = length();

    return divideScalar(_length ?? 1).multiplyScalar(math.max(min, math.min(max, _length)));
  }

  Vector4 floor() {
    x = x.floor().toDouble();
    y = y.floor().toDouble();
    z = z.floor().toDouble();
    w = w.floor().toDouble();

    return this;
  }

  Vector4 ceil() {
    x = x.ceil().toDouble();
    y = y.ceil().toDouble();
    z = z.ceil().toDouble();
    w = w.ceil().toDouble();

    return this;
  }

  Vector4 round() {
    x = x.round().toDouble();
    y = y.round().toDouble();
    z = z.round().toDouble();
    w = w.round().toDouble();

    return this;
  }

  Vector4 roundToZero() {
    x = (x < 0) ? x.ceil().toDouble() : x.floor().toDouble();
    y = (y < 0) ? y.ceil().toDouble() : y.floor().toDouble();
    z = (z < 0) ? z.ceil().toDouble() : z.floor().toDouble();
    w = (w < 0) ? w.ceil().toDouble() : w.floor().toDouble();

    return this;
  }

  Vector4 negate() {
    x = -x;
    y = -y;
    z = -z;
    w = -w;

    return this;
  }

  dot(Vector4 v) {
    return x * v.x + y * v.y + z * v.z + w * v.w;
  }

  lengthSq() {
    return x * x + y * y + z * z + w * w;
  }

  length() {
    return math.sqrt(x * x + y * y + z * z + w * w);
  }

  manhattanLength() {
    return x.abs() + y.abs() + z.abs() + w.abs();
  }

  normalize() {
    return divideScalar(length() ?? 1);
  }

  setLength(length) {
    return normalize().multiplyScalar(length);
  }

  Vector4 lerp(Vector4 v, alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;
    w += (v.w - w) * alpha;

    return this;
  }

  Vector4 lerpVectors(Vector4 v1, Vector4 v2, alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;
    z = v1.z + (v2.z - v1.z) * alpha;
    w = v1.w + (v2.w - v1.w) * alpha;

    return this;
  }

  equals(Vector4 v) {
    return ((v.x == x) && (v.y == y) && (v.z == z) && (v.w == w));
  }

  Vector4 fromArray(array, [offset = 0]) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];
    w = array[offset + 3];

    return this;
  }

  toArray([array = const [], offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;
    array[offset + 3] = w;

    return array;
  }

  Vector4 fromBufferAttribute(attribute, index, [offset]) {
    if (offset != null) {
      print('THREE.Vector4: offset has been removed from .fromBufferAttribute().');
    }

    x = attribute.getX(index);
    y = attribute.getY(index);
    z = attribute.getZ(index);
    w = attribute.getW(index);

    return this;
  }

  Vector4 random() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    w = math.Random().nextDouble();

    return this;
  }
}
