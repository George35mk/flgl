import 'math_utils.dart';
import 'matrix4.dart';
import 'dart:math' as math;

import 'quaternion.dart';
import 'vector3.dart';

const String DefaultOrder = 'XYZ';
const List<String> RotationOrders = ['XYZ', 'YZX', 'ZXY', 'XZY', 'YXZ', 'ZYX'];

var _matrix = Matrix4();
var _quaternion = Quaternion();

class Euler {
  bool isEuler = true;

  double x;
  double y;
  double z;
  String order;

  Euler([this.x = 0, this.y = 0, this.z = 0, this.order = DefaultOrder]);

  Euler set(_x, _y, _z, [_order = 'XYZ']) {
    x = _x;
    y = _y;
    z = _z;
    order = _order;

    // this._onChangeCallback();

    return this;
  }

  Euler clone() {
    return Euler(x, y, z, order);
  }

  Euler copy(Euler euler) {
    x = euler.x;
    y = euler.y;
    z = euler.z;
    order = euler.order;

    return this;
  }

  /// Sets the angles of this euler transform from a pure rotation matrix
  /// based on the orientation specified by order.
  ///
  /// - [m] - a Matrix4 of which the upper 3x3 of matrix is a pure rotation matrix (i.e. unscaled).
  /// - [order] - (optional) a string representing the order that the rotations are applied.
  Euler setFromRotationMatrix(Matrix4 m, [_order = 'XYZ', update = true]) {
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)

    var te = m.elements;
    var m11 = te[0], m12 = te[4], m13 = te[8];
    var m21 = te[1], m22 = te[5], m23 = te[9];
    var m31 = te[2], m32 = te[6], m33 = te[10];

    switch (_order) {
      case 'XYZ':
        y = math.asin(MathUtils.clamp(m13, -1, 1));

        if (m13.abs() < 0.9999999) {
          x = math.atan2(-m23, m33);
          z = math.atan2(-m12, m11);
        } else {
          x = math.atan2(m32, m22);
          z = 0;
        }

        break;

      case 'YXZ':
        x = math.asin(-MathUtils.clamp(m23, -1, 1));

        if (m23.abs() < 0.9999999) {
          y = math.atan2(m13, m33);
          z = math.atan2(m21, m22);
        } else {
          y = math.atan2(-m31, m11);
          z = 0;
        }

        break;

      case 'ZXY':
        x = math.asin(MathUtils.clamp(m32, -1, 1));

        if (m32.abs() < 0.9999999) {
          y = math.atan2(-m31, m33);
          z = math.atan2(-m12, m22);
        } else {
          y = 0;
          z = math.atan2(m21, m11);
        }

        break;

      case 'ZYX':
        y = math.asin(-MathUtils.clamp(m31, -1, 1));

        if (m31.abs() < 0.9999999) {
          x = math.atan2(m32, m33);
          z = math.atan2(m21, m11);
        } else {
          x = 0;
          z = math.atan2(-m12, m22);
        }

        break;

      case 'YZX':
        z = math.asin(MathUtils.clamp(m21, -1, 1));

        if (m21.abs() < 0.9999999) {
          x = math.atan2(-m23, m22);
          y = math.atan2(-m31, m11);
        } else {
          x = 0;
          y = math.atan2(m13, m33);
        }

        break;

      case 'XZY':
        z = math.asin(-MathUtils.clamp(m12, -1, 1));

        if (m12.abs() < 0.9999999) {
          x = math.atan2(m32, m22);
          y = math.atan2(m13, m11);
        } else {
          x = math.atan2(-m23, m33);
          y = 0;
        }

        break;

      default:
        print('THREE.Euler: .setFromRotationMatrix() encountered an unknown order: $order');
    }

    order = _order;

    // if ( update == true ) this._onChangeCallback();

    return this;
  }

  Euler setFromQuaternion(Quaternion q, String order, [update]) {
    _matrix.makeRotationFromQuaternion(q);
    return setFromRotationMatrix(_matrix, order, update);
  }

  Euler setFromVector3(Vector3 v, [_order = 'XYZ']) {
    return set(v.x, v.y, v.z, _order);
  }

  Euler reorder(newOrder) {
    // WARNING: this discards revolution information -bhouston

    _quaternion.setFromEuler(this);

    return setFromQuaternion(_quaternion, newOrder);
  }

  bool equals(Euler euler) {
    return (euler.x == x) && (euler.y == y) && (euler.z == z) && (euler.order == order);
  }

  Euler fromArray(array) {
    x = array[0];
    y = array[1];
    z = array[2];
    if (array[3] != null) order = array[3];

    // this._onChangeCallback();

    return this;
  }

  /// Returns an array of the form [x, y, z, order ].
  ///
  /// - [array] - (optional) array to store the euler in.
  /// - [offset] (optional) offset in the array.
  List<double> toArray([array = List, offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;
    array[offset + 2] = z;
    array[offset + 3] = order;

    return array;
  }

  /// Returns the Euler's x, y and z properties as a Vector3.
  /// - [optionalResult] — (optional) If specified, the result will be
  ///   copied into this Vector, otherwise a new one will be created.
  Vector3 toVector3([optionalResult]) {
    // you should have a problem here
    if (optionalResult) {
      return optionalResult.set(x, y, z);
    } else {
      return Vector3(x, y, z);
    }
  }

  onChange(Function callback) {
    // onChangeCallback = callback;
    return this;
  }

  onChangeCallback() {}
}
