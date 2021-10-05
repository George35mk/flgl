import 'dart:math';
import 'quaternion.dart';
import 'vector3.dart';

var _v1 = Vector3();
var _m1 = Matrix4();
var _zero = Vector3(0, 0, 0);
var _one = Vector3(1, 1, 1);
var _x = Vector3();
var _y = Vector3();
var _z = Vector3();

class Matrix4 {
  bool isMatrix4 = true;

  List<double> elements = [
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1 //
  ];

  Matrix4();

  /// Sets this matrix elements.
  set(
    double n11,
    double n12,
    double n13,
    double n14,
    double n21,
    double n22,
    double n23,
    double n24,
    double n31,
    double n32,
    double n33,
    double n34,
    double n41,
    double n42,
    double n43,
    double n44,
  ) {
    var te = elements;
    te[0] = n11;
    te[1] = n21;
    te[2] = n31;
    te[3] = n41;

    te[4] = n12;
    te[5] = n22;
    te[6] = n32;
    te[7] = n42;

    te[8] = n13;
    te[9] = n23;
    te[10] = n33;
    te[11] = n43;

    te[12] = n14;
    te[13] = n24;
    te[14] = n34;
    te[15] = n44;
    return this;
  }

  identity() {
    set(
      1, 0, 0, 0, //
      0, 1, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    );
    return this;
  }

  clone() {
    return Matrix4().fromArray(elements);
  }

  copy(Matrix4 m) {
    var te = elements;
    var me = m.elements;
    te[0] = me[0];
    te[1] = me[1];
    te[2] = me[2];
    te[3] = me[3];
    te[4] = me[4];
    te[5] = me[5];
    te[6] = me[6];
    te[7] = me[7];
    te[8] = me[8];
    te[9] = me[9];
    te[10] = me[10];
    te[11] = me[11];
    te[12] = me[12];
    te[13] = me[13];
    te[14] = me[14];
    te[15] = me[15];
    return this;
  }

  copyPosition(Matrix4 m) {
    var te = elements;
    var me = m.elements;

    te[12] = me[12];
    te[13] = me[13];
    te[14] = me[14];

    return this;
  }

  setFromMatrix3(Matrix4 m) {
    var me = m.elements;

    set(
      me[0], me[3], me[6], 0, //
      me[1], me[4], me[7], 0, //
      me[2], me[5], me[8], 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  extractBasis(xAxis, yAxis, zAxis) {
    xAxis.setFromMatrixColumn(this, 0);
    yAxis.setFromMatrixColumn(this, 1);
    zAxis.setFromMatrixColumn(this, 2);

    return this;
  }

  makeBasis(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis) {
    set(
      xAxis.x, yAxis.x, zAxis.x, 0, //
      xAxis.y, yAxis.y, zAxis.y, 0, //
      xAxis.z, yAxis.z, zAxis.z, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  extractRotation(Matrix4 m) {
    // this method does not support reflection matrices

    var te = elements;
    var me = m.elements;

    var scaleX = 1 / _v1.setFromMatrixColumn(m, 0).length();
    var scaleY = 1 / _v1.setFromMatrixColumn(m, 1).length();
    var scaleZ = 1 / _v1.setFromMatrixColumn(m, 2).length();

    te[0] = me[0] * scaleX;
    te[1] = me[1] * scaleX;
    te[2] = me[2] * scaleX;
    te[3] = 0;

    te[4] = me[4] * scaleY;
    te[5] = me[5] * scaleY;
    te[6] = me[6] * scaleY;
    te[7] = 0;

    te[8] = me[8] * scaleZ;
    te[9] = me[9] * scaleZ;
    te[10] = me[10] * scaleZ;
    te[11] = 0;

    te[12] = 0;
    te[13] = 0;
    te[14] = 0;
    te[15] = 1;

    return this;
  }

  invert() {
    // based on http://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/fourD/index.htm
    var te = elements;
    var n11 = te[0];
    var n21 = te[1];
    var n31 = te[2];
    var n41 = te[3];
    var n12 = te[4];
    var n22 = te[5];
    var n32 = te[6];
    var n42 = te[7];
    var n13 = te[8];
    var n23 = te[9];
    var n33 = te[10];
    var n43 = te[11];
    var n14 = te[12];
    var n24 = te[13];
    var n34 = te[14];
    var n44 = te[15];
    var t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    var t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    var t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    var t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;
    var det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    if (det == 0) return set(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    var detInv = 1 / det;
    te[0] = t11 * detInv;
    te[1] =
        (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) *
            detInv;
    te[2] =
        (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) *
            detInv;
    te[3] =
        (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) *
            detInv;
    te[4] = t12 * detInv;
    te[5] =
        (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) *
            detInv;
    te[6] =
        (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) *
            detInv;
    te[7] =
        (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) *
            detInv;
    te[8] = t13 * detInv;
    te[9] =
        (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) *
            detInv;
    te[10] =
        (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) *
            detInv;
    te[11] =
        (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) *
            detInv;
    te[12] = t14 * detInv;
    te[13] =
        (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) *
            detInv;
    te[14] =
        (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) *
            detInv;
    te[15] =
        (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) *
            detInv;
    return this;
  }

  multiplyMatrices(Matrix4 a, Matrix4 b) {
    var ae = a.elements;
    var be = b.elements;
    var te = elements;
    var a11 = ae[0], a12 = ae[4], a13 = ae[8], a14 = ae[12];
    var a21 = ae[1], a22 = ae[5], a23 = ae[9], a24 = ae[13];
    var a31 = ae[2], a32 = ae[6], a33 = ae[10], a34 = ae[14];
    var a41 = ae[3], a42 = ae[7], a43 = ae[11], a44 = ae[15];
    var b11 = be[0], b12 = be[4], b13 = be[8], b14 = be[12];
    var b21 = be[1], b22 = be[5], b23 = be[9], b24 = be[13];
    var b31 = be[2], b32 = be[6], b33 = be[10], b34 = be[14];
    var b41 = be[3], b42 = be[7], b43 = be[11], b44 = be[15];
    te[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
    te[4] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
    te[8] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
    te[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;
    te[1] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
    te[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
    te[9] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
    te[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;
    te[2] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
    te[6] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
    te[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
    te[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;
    te[3] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
    te[7] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
    te[11] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
    te[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;
    return this;
  }

  compose(Vector3 position, Quaternion quaternion, Vector3 scale) {
    var te = elements;

    var x = quaternion.x;
    var y = quaternion.y;
    var z = quaternion.z;
    var w = quaternion.w;

    var x2 = x + x;
    var y2 = y + y;
    var z2 = z + z;

    var xx = x * x2;
    var xy = x * y2;
    var xz = x * z2;

    var yy = y * y2;
    var yz = y * z2;
    var zz = z * z2;

    var wx = w * x2;
    var wy = w * y2;
    var wz = w * z2;

    var sx = scale.x, sy = scale.y, sz = scale.z;

    te[0] = (1 - (yy + zz)) * sx;
    te[1] = (xy + wz) * sx;
    te[2] = (xz - wy) * sx;
    te[3] = 0;
    te[4] = (xy - wz) * sy;
    te[5] = (1 - (xx + zz)) * sy;
    te[6] = (yz + wx) * sy;
    te[7] = 0;
    te[8] = (xz + wy) * sz;
    te[9] = (yz - wx) * sz;
    te[10] = (1 - (xx + yy)) * sz;
    te[11] = 0;
    te[12] = position.x;
    te[13] = position.y;
    te[14] = position.z;
    te[15] = 1;
    return this;
  }

  makePerspective(left, right, top, bottom, near, far) {
    var te = elements;
    var x = 2 * near / (right - left);
    var y = 2 * near / (top - bottom);
    var a = (right + left) / (right - left);
    var b = (top + bottom) / (top - bottom);
    var c = -(far + near) / (far - near);
    var d = -2 * far * near / (far - near);
    te[0] = x;
    te[4] = 0;
    te[8] = a;
    te[12] = 0;
    te[1] = 0;
    te[5] = y;
    te[9] = b;
    te[13] = 0;
    te[2] = 0;
    te[6] = 0;
    te[10] = c;
    te[14] = d;
    te[3] = 0;
    te[7] = 0;
    te[11] = -1;
    te[15] = 0;
    return this;
  }

  makeOrthographic(left, right, top, bottom, near, far) {
    var te = elements;
    var w = 1.0 / (right - left);
    var h = 1.0 / (top - bottom);
    var p = 1.0 / (far - near);
    var x = (right + left) * w;
    var y = (top + bottom) * h;
    var z = (far + near) * p;
    te[0] = 2 * w;
    te[4] = 0;
    te[8] = 0;
    te[12] = -x;
    te[1] = 0;
    te[5] = 2 * h;
    te[9] = 0;
    te[13] = -y;
    te[2] = 0;
    te[6] = 0;
    te[10] = -2 * p;
    te[14] = -z;
    te[3] = 0;
    te[7] = 0;
    te[11] = 0;
    te[15] = 1;
    return this;
  }

  static List<num> lookAt(Vector3 cameraPosition, Vector3 target, Vector3 up) {
    Vector3 zAxis = normalize(subtractVectors(cameraPosition, target));
    Vector3 xAxis = normalize(cross(up, zAxis));
    Vector3 yAxis = normalize(cross(zAxis, xAxis));

    return [
      xAxis.x, xAxis.y, xAxis.z, 0, //
      yAxis.x, yAxis.y, yAxis.z, 0, //
      zAxis.x, zAxis.y, zAxis.z, 0, //
      cameraPosition.x, cameraPosition.y, cameraPosition.z, 1, //
    ];
  }

  static Vector3 normalize(Vector3 v) {
    var length = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    // make sure we don't divide by 0.
    if (length > 0.00001) {
      return Vector3(v.x / length, v.y / length, v.z / length);
    } else {
      return Vector3(0, 0, 0);
    }
  }

  static Vector3 subtractVectors(Vector3 a, Vector3 b) {
    return Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
  }

  static Vector3 cross(Vector3 a, Vector3 b) {
    return Vector3(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x,
    );
  }

  fromArray(array, [offset = 0]) {
    for (var i = 0; i < 16; i++) {
      elements[i] = array[i + offset];
    }
    return this;
  }

  toArray([array = List, offset = 0]) {
    var te = elements;

    array[offset] = te[0];
    array[offset + 1] = te[1];
    array[offset + 2] = te[2];
    array[offset + 3] = te[3];

    array[offset + 4] = te[4];
    array[offset + 5] = te[5];
    array[offset + 6] = te[6];
    array[offset + 7] = te[7];

    array[offset + 8] = te[8];
    array[offset + 9] = te[9];
    array[offset + 10] = te[10];
    array[offset + 11] = te[11];

    array[offset + 12] = te[12];
    array[offset + 13] = te[13];
    array[offset + 14] = te[14];
    array[offset + 15] = te[15];

    return array;
  }

  makeRotationFromQuaternion(Quaternion q) {
    return compose(_zero, q, _one);
  }
}
