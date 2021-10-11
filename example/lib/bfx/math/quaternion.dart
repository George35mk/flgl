import 'dart:math' as math;

import 'package:flgl_example/bfx/core/buffer_attribute.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';

import 'euler.dart';
import 'math_utils.dart';
import 'vector3.dart';

class Quaternion {
  /// x coordinate
  double x;

  /// y coordinate
  double y;

  /// z coordinate
  double z;

  /// w coordinate
  double w;

  Quaternion([this.x = 0, this.y = 0, this.z = 0, this.w = 0]);

  static _slerp(Quaternion qa, Quaternion qb, Quaternion qm, double t) {
    print('THREE.Quaternion: Static .slerp() has been deprecated. Use qm.slerpQuaternions( qa, qb, t ) instead.');
    return qm.slerpQuaternions(qa, qb, t);
  }

  /// Like the static slerp method above, but operates directly on flat arrays of numbers.
  ///
  /// - [dst] - The output array.
  /// - [dstOffset] - An offset into the output array.
  /// - [src0] - The source array of the starting quaternion.
  /// - [srcOffset0] - An offset into the array src0.
  /// - [src1] - The source array of the target quatnerion.
  /// - [srcOffset1] - An offset into the array src1.
  /// - [t] - Normalized interpolation factor (between 0 and 1).
  static slerpFlat(List dst, int dstOffset, List src0, int srcOffset0, List src1, int srcOffset1, double t) {
    // fuzz-free, array-based Quaternion SLERP operation

    var x0 = src0[srcOffset0 + 0];
    var y0 = src0[srcOffset0 + 1];
    var z0 = src0[srcOffset0 + 2];
    var w0 = src0[srcOffset0 + 3];

    var x1 = src1[srcOffset1 + 0];
    var y1 = src1[srcOffset1 + 1];
    var z1 = src1[srcOffset1 + 2];
    var w1 = src1[srcOffset1 + 3];

    if (t == 0) {
      dst[dstOffset + 0] = x0;
      dst[dstOffset + 1] = y0;
      dst[dstOffset + 2] = z0;
      dst[dstOffset + 3] = w0;
      return;
    }

    if (t == 1) {
      dst[dstOffset + 0] = x1;
      dst[dstOffset + 1] = y1;
      dst[dstOffset + 2] = z1;
      dst[dstOffset + 3] = w1;
      return;
    }

    if (w0 != w1 || x0 != x1 || y0 != y1 || z0 != z1) {
      var s = 1 - t;
      var cos = x0 * x1 + y0 * y1 + z0 * z1 + w0 * w1, dir = (cos >= 0 ? 1 : -1), sqrSin = 1 - cos * cos;

      // Skip the Slerp for tiny steps to avoid numeric problems:
      // if ( sqrSin > Number.EPSILON ) {
      if (sqrSin > math.e) {
        var sin = math.sqrt(sqrSin);
        var len = math.atan2(sin, cos * dir);

        s = math.sin(s * len) / sin;
        t = math.sin(t * len) / sin;
      }

      var tDir = t * dir;

      x0 = x0 * s + x1 * tDir;
      y0 = y0 * s + y1 * tDir;
      z0 = z0 * s + z1 * tDir;
      w0 = w0 * s + w1 * tDir;

      // Normalize in case we just did a lerp:
      if (s == 1 - t) {
        var f = 1 / math.sqrt(x0 * x0 + y0 * y0 + z0 * z0 + w0 * w0);

        x0 *= f;
        y0 *= f;
        z0 *= f;
        w0 *= f;
      }
    }

    dst[dstOffset] = x0;
    dst[dstOffset + 1] = y0;
    dst[dstOffset + 2] = z0;
    dst[dstOffset + 3] = w0;
  }

  static multiplyQuaternionsFlat(dst, dstOffset, src0, srcOffset0, src1, srcOffset1) {
    var x0 = src0[srcOffset0];
    var y0 = src0[srcOffset0 + 1];
    var z0 = src0[srcOffset0 + 2];
    var w0 = src0[srcOffset0 + 3];

    var x1 = src1[srcOffset1];
    var y1 = src1[srcOffset1 + 1];
    var z1 = src1[srcOffset1 + 2];
    var w1 = src1[srcOffset1 + 3];

    dst[dstOffset] = x0 * w1 + w0 * x1 + y0 * z1 - z0 * y1;
    dst[dstOffset + 1] = y0 * w1 + w0 * y1 + z0 * x1 - x0 * z1;
    dst[dstOffset + 2] = z0 * w1 + w0 * z1 + x0 * y1 - y0 * x1;
    dst[dstOffset + 3] = w0 * w1 - x0 * x1 - y0 * y1 - z0 * z1;

    return dst;
  }

  /// Sets x, y, z, w properties of this quaternion.
  Quaternion set(double x, double y, double z, double w) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;

    return this;
  }

  /// Creates a new Quaternion with identical x, y, z and w properties to this one.
  Quaternion clone() {
    return Quaternion(x, y, z, w);
  }

  /// Copies the x, y, z and w properties of q into this quaternion.
  Quaternion copy(Quaternion quaternion) {
    x = quaternion.x;
    y = quaternion.y;
    z = quaternion.z;
    w = quaternion.w;

    return this;
  }

  /// Sets this quaternion from the rotation specified by Euler angle.
  Quaternion setFromEuler(Euler euler, [update]) {
    if (!(euler != null && euler.isEuler)) {
      throw ('THREE.Quaternion: .setFromEuler() now expects an Euler rotation rather than a Vector3 and order.');
    }

    var _x = euler.x;
    var _y = euler.y;
    var _z = euler.z;
    var _order = euler.order;

    // http://www.mathworks.com/matlabcentral/fileexchange/
    // 	20696-function-to-convert-between-dcm-euler-angles-quaternions-and-euler-vectors/
    //	content/SpinCalc.m

    var cos = math.cos;
    var sin = math.sin;

    var c1 = cos(_x / 2);
    var c2 = cos(_y / 2);
    var c3 = cos(_z / 2);

    var s1 = sin(_x / 2);
    var s2 = sin(_y / 2);
    var s3 = sin(_z / 2);

    switch (_order) {
      case 'XYZ':
        x = s1 * c2 * c3 + c1 * s2 * s3;
        y = c1 * s2 * c3 - s1 * c2 * s3;
        z = c1 * c2 * s3 + s1 * s2 * c3;
        w = c1 * c2 * c3 - s1 * s2 * s3;
        break;

      case 'YXZ':
        x = s1 * c2 * c3 + c1 * s2 * s3;
        y = c1 * s2 * c3 - s1 * c2 * s3;
        z = c1 * c2 * s3 - s1 * s2 * c3;
        w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      case 'ZXY':
        x = s1 * c2 * c3 - c1 * s2 * s3;
        y = c1 * s2 * c3 + s1 * c2 * s3;
        z = c1 * c2 * s3 + s1 * s2 * c3;
        w = c1 * c2 * c3 - s1 * s2 * s3;
        break;

      case 'ZYX':
        x = s1 * c2 * c3 - c1 * s2 * s3;
        y = c1 * s2 * c3 + s1 * c2 * s3;
        z = c1 * c2 * s3 - s1 * s2 * c3;
        w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      case 'YZX':
        x = s1 * c2 * c3 + c1 * s2 * s3;
        y = c1 * s2 * c3 + s1 * c2 * s3;
        z = c1 * c2 * s3 - s1 * s2 * c3;
        w = c1 * c2 * c3 - s1 * s2 * s3;
        break;

      case 'XZY':
        x = s1 * c2 * c3 - c1 * s2 * s3;
        y = c1 * s2 * c3 - s1 * c2 * s3;
        z = c1 * c2 * s3 + s1 * s2 * c3;
        w = c1 * c2 * c3 + s1 * s2 * s3;
        break;

      default:
        print('THREE.Quaternion: .setFromEuler() encountered an unknown order: $_order');
    }

    // if (update != false) _onChangeCallback();

    return this;
  }

  /// Sets this quaternion from rotation specified by axis and angle.
  /// Adapted from the method here.
  /// Axis is assumed to be normalized, angle is in radians.
  Quaternion setFromAxisAngle(Vector3 axis, double angle) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToQuaternion/index.htm

    // assumes axis is normalized

    var halfAngle = angle / 2, s = math.sin(halfAngle);

    x = axis.x * s;
    y = axis.y * s;
    z = axis.z * s;
    w = math.cos(halfAngle);

    // _onChangeCallback();

    return this;
  }

  /// Sets this quaternion from rotation component of m.
  /// Adapted from the method here.
  ///
  /// - [m] - a Matrix4 of which the upper 3x3 of matrix is a pure rotation matrix (i.e. unscaled).
  Quaternion setFromRotationMatrix(Matrix4 m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm

    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    var te = m.elements;
    var m11 = te[0];
    var m12 = te[4];
    var m13 = te[8];
    var m21 = te[1];
    var m22 = te[5];
    var m23 = te[9];
    var m31 = te[2];
    var m32 = te[6];
    var m33 = te[10];
    var trace = m11 + m22 + m33;

    if (trace > 0) {
      var s = 0.5 / math.sqrt(trace + 1.0);

      w = 0.25 / s;
      x = (m32 - m23) * s;
      y = (m13 - m31) * s;
      z = (m21 - m12) * s;
    } else if (m11 > m22 && m11 > m33) {
      var s = 2.0 * math.sqrt(1.0 + m11 - m22 - m33);

      w = (m32 - m23) / s;
      x = 0.25 * s;
      y = (m12 + m21) / s;
      z = (m13 + m31) / s;
    } else if (m22 > m33) {
      var s = 2.0 * math.sqrt(1.0 + m22 - m11 - m33);

      w = (m13 - m31) / s;
      x = (m12 + m21) / s;
      y = 0.25 * s;
      z = (m23 + m32) / s;
    } else {
      var s = 2.0 * math.sqrt(1.0 + m33 - m11 - m22);

      w = (m21 - m12) / s;
      x = (m13 + m31) / s;
      y = (m23 + m32) / s;
      z = 0.25 * s;
    }

    // _onChangeCallback();

    return this;
  }

  /// Sets this quaternion to the rotation required to rotate direction vector vFrom to direction vector vTo.
  /// Adapted from the method here.
  /// vFrom and vTo are assumed to be normalized.
  Quaternion setFromUnitVectors(Vector3 vFrom, Vector3 vTo) {
    // assumes direction vectors vFrom and vTo are normalized

    var r = vFrom.dot(vTo) + 1;

    // if ( r < Number.EPSILON ) {
    if (r < math.e) {
      // vFrom and vTo point in opposite directions

      r = 0;

      if (vFrom.x.abs() > vFrom.z.abs()) {
        x = -vFrom.y;
        y = vFrom.x;
        z = 0;
        w = r;
      } else {
        x = 0;
        y = -vFrom.z;
        z = vFrom.y;
        w = r;
      }
    } else {
      // crossVectors( vFrom, vTo ); // inlined to avoid cyclic dependency on Vector3

      x = vFrom.y * vTo.z - vFrom.z * vTo.y;
      y = vFrom.z * vTo.x - vFrom.x * vTo.z;
      z = vFrom.x * vTo.y - vFrom.y * vTo.x;
      w = r;
    }

    return normalize();
  }

  /// Returns the angle between this quaternion and quaternion q in radians.
  double angleTo(Quaternion q) {
    return 2 * math.acos(MathUtils.clamp(dot(q), -1, 1).abs());
  }

  /// Rotates this quaternion by a given angular step to the defined quaternion q.
  /// The method ensures that the final quaternion will not overshoot q.
  ///
  /// - [q] - The target quaternion.
  /// - [step] - The angular step in radians.
  Quaternion rotateTowards(Quaternion q, double step) {
    var angle = angleTo(q);

    if (angle == 0) return this;

    double t = math.min(1, step / angle);

    slerp(q, t);

    return this;
  }

  /// Sets this quaternion to the identity quaternion; that is, to the quaternion
  /// that represents "no rotation".
  Quaternion identity() {
    return set(0, 0, 0, 1);
  }

  /// Inverts this quaternion - calculates the conjugate.
  /// The quaternion is assumed to have unit length.
  Quaternion invert() {
    // quaternion is assumed to have unit length
    return conjugate();
  }

  /// Returns the rotational conjugate of this quaternion. The conjugate of a
  /// quaternion represents the same rotation in the opposite direction about
  /// the rotational axis.
  Quaternion conjugate() {
    x *= -1;
    y *= -1;
    z *= -1;
    return this;
  }

  /// Calculates the dot product of quaternions v and this one.
  double dot(Quaternion v) {
    return x * v.x + y * v.y + z * v.z + w * v.w;
  }

  /// Computes the squared Euclidean length (straight-line length) of this
  /// quaternion, considered as a 4 dimensional vector. This can be useful
  /// if you are comparing the lengths of two quaternions, as this is a
  /// slightly more efficient calculation than length().
  double lengthSq() {
    return x * x + y * y + z * z + w * w;
  }

  /// Computes the Euclidean length (straight-line length) of this quaternion,
  /// considered as a 4 dimensional vector.
  double length() {
    return math.sqrt(x * x + y * y + z * z + w * w);
  }

  /// Normalizes this quaternion - that is, calculated the quaternion that
  /// performs the same rotation as this one, but has length equal to 1.
  Quaternion normalize() {
    var l = length();

    if (l == 0) {
      x = 0;
      y = 0;
      z = 0;
      w = 1;
    } else {
      l = 1 / l;

      x = x * l;
      y = y * l;
      z = z * l;
      w = w * l;
    }

    return this;
  }

  /// Multiplies this quaternion by q.
  Quaternion multiply(Quaternion q, [Quaternion? p]) {
    if (p != null) {
      print('THREE.Quaternion: .multiply() now only accepts one argument. Use .multiplyQuaternions( a, b ) instead.');
      return multiplyQuaternions(q, p);
    }

    return multiplyQuaternions(this, q);
  }

  /// Pre-multiplies this quaternion by q.
  Quaternion premultiply(Quaternion q) {
    return multiplyQuaternions(q, this);
  }

  /// Sets this quaternion to a x b.
  /// Adapted from the method outlined here.
  Quaternion multiplyQuaternions(Quaternion a, Quaternion b) {
    // from http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/code/index.htm

    var qax = a.x, qay = a.y, qaz = a.z, qaw = a.w;
    var qbx = b.x, qby = b.y, qbz = b.z, qbw = b.w;

    x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

    return this;
  }

  /// Handles the spherical linear interpolation between quaternions. t represents the
  /// amount of rotation between this quaternion (where t is 0) and qb (where t is 1).
  /// This quaternion is set to the result. Also see the static version of the slerp below.
  ///
  /// - [qb] - The other quaternion rotation
  /// - [t] - interpolation factor in the closed interval [0, 1].
  Quaternion slerp(Quaternion qb, double t) {
    if (t == 0) return this;
    if (t == 1) return copy(qb);

    // http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/

    var cosHalfTheta = w * qb.w + x * qb.x + y * qb.y + z * qb.z;

    if (cosHalfTheta < 0) {
      w = -qb.w;
      x = -qb.x;
      y = -qb.y;
      z = -qb.z;

      cosHalfTheta = -cosHalfTheta;
    } else {
      copy(qb);
    }

    if (cosHalfTheta >= 1.0) {
      w = w;
      x = x;
      y = y;
      z = z;

      return this;
    }

    var sqrSinHalfTheta = 1.0 - cosHalfTheta * cosHalfTheta;

    // if (sqrSinHalfTheta <= Number.EPSILON) {
    if (sqrSinHalfTheta <= math.e) {
      var s = 1 - t;
      w = s * w + t * w;
      x = s * x + t * x;
      y = s * y + t * y;
      z = s * z + t * z;

      normalize();

      return this;
    }

    var sinHalfTheta = math.sqrt(sqrSinHalfTheta);
    var halfTheta = math.atan2(sinHalfTheta, cosHalfTheta);
    var ratioA = math.sin((1 - t) * halfTheta) / sinHalfTheta;
    var ratioB = math.sin(t * halfTheta) / sinHalfTheta;

    w = (w * ratioA + w * ratioB);
    x = (x * ratioA + x * ratioB);
    y = (y * ratioA + y * ratioB);
    z = (z * ratioA + z * ratioB);

    return this;
  }

  /// Performs a spherical linear interpolation between the given
  /// quaternions and stores the result in this quaternion.
  slerpQuaternions(Quaternion qa, Quaternion qb, double t) {
    copy(qa).slerp(qb, t);
  }

  /// Sets this quaternion to a uniformly random, normalized quaternion.
  Quaternion random() {
    // Derived from http://planning.cs.uiuc.edu/node198.html
    // Note, this source uses w, x, y, z ordering,
    // so we swap the order below.

    var u1 = math.Random().nextDouble();
    var sqrt1u1 = math.sqrt(1 - u1);
    var sqrtu1 = math.sqrt(u1);

    var u2 = 2 * math.pi * math.Random().nextDouble();
    var u3 = 2 * math.pi * math.Random().nextDouble();

    return set(
      sqrt1u1 * math.cos(u2), //
      sqrtu1 * math.sin(u3), //
      sqrtu1 * math.cos(u3), //
      sqrt1u1 * math.sin(u2), //
    );
  }

  /// Compares the x, y, z and w properties of v to the equivalent properties
  /// of this quaternion to determine if they represent the same rotation.
  ///
  /// - [v] - Quaternion that this quaternion will be compared to.
  bool equals(Quaternion quaternion) {
    return (quaternion.x == x) && (quaternion.y == y) && (quaternion.z == z) && (quaternion.w == w);
  }

  /// Sets this quaternion's x, y, z and w properties from an array.
  ///
  /// - [array] - array of format (x, y, z, w) used to construct the quaternion.
  /// - [offset] - (optional) an offset into the array.
  Quaternion fromArray(List<double> array, [int offset = 0]) {
    x = array[offset];
    y = array[offset + 1];
    z = array[offset + 2];
    w = array[offset + 3];

    return this;
  }

  /// Returns the numerical elements of this quaternion in an array of format [x, y, z, w].
  ///
  /// - [array] - An optional array to store the quaternion. If not specified, a new array will be created.
  /// - [offset] - (optional) if specified, the result will be copied into this Array.
  List<double> toArray([array = List, int offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;
    array[offset + 3] = w;

    return array;
  }

  /// Sets x, y, z, w properties of this quaternion from the attribute.
  ///
  /// - [attribute] - the source attribute.
  /// - [index] - index in the attribute.
  Quaternion fromBufferAttribute(BufferAttribute attribute, int index) {
    x = attribute.getX(index);
    y = attribute.getY(index);
    z = attribute.getZ(index);
    w = attribute.getW(index);

    return this;
  }

  Quaternion onChange(callback) {
    // onChangeCallback = callback;

    return this;
  }

  onChangeCallback() {}
}
