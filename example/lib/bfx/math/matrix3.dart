import 'dart:math';

import 'matrix4.dart';
import 'vector3.dart';

class Matrix3 {
  bool isMatrix3 = true;

  List<double> elements = [
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1 //
  ];

  Matrix3();

  /// Sets the 3x3 matrix values to the given row-major sequence of values.
  ///
  /// ```
  /// n11 - value to put in row 1, col 1.
  /// n12 - value to put in row 1, col 2.
  /// ...
  /// ...
  /// n32 - value to put in row 3, col 2.
  /// n33 - value to put in row 3, col 3.
  /// ```
  Matrix3 set(
    double n11,
    double n12,
    double n13,
    double n21,
    double n22,
    double n23,
    double n31,
    double n32,
    double n33,
  ) {
    var te = elements;

    te[0] = n11;
    te[1] = n21;
    te[2] = n31;
    te[3] = n12;
    te[4] = n22;
    te[5] = n32;
    te[6] = n13;
    te[7] = n23;
    te[8] = n33;

    return this;
  }

  /// Resets this matrix to the 3x3 identity matrix:
  ///
  /// ```
  /// 1, 0, 0
  /// 0, 1, 0
  /// 0, 0, 1
  /// ```
  Matrix3 identity() {
    set(
      1, 0, 0, //
      0, 1, 0, //
      0, 0, 1, //
    );

    return this;
  }

  /// Copies the elements of matrix m into this matrix.
  Matrix3 copy(Matrix3 m) {
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

    return this;
  }

  /// Extracts the basis of this matrix into the three axis vectors provided. If this matrix is:
  ///
  /// ```dart
  /// a, b, c,
  /// d, e, f,
  /// g, h, i
  ///
  /// then the xAxis, yAxis, zAxis will be set to:
  ///
  /// xAxis = (a, d, g)
  /// yAxis = (b, e, h)
  /// zAxis = (c, f, i)
  /// ```
  Matrix3 extractBasis(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis) {
    xAxis.setFromMatrix3Column(this, 0);
    yAxis.setFromMatrix3Column(this, 1);
    zAxis.setFromMatrix3Column(this, 2);

    return this;
  }

  /// Set this matrix to the upper 3x3 matrix of the Matrix4 m.
  Matrix3 setFromMatrix4(Matrix4 m) {
    var me = m.elements;

    set(
      me[0], me[4], me[8], //
      me[1], me[5], me[9], //
      me[2], me[6], me[10], //
    );

    return this;
  }

  /// Post-multiplies this matrix by [m].
  Matrix3 multiply(Matrix3 m) {
    return multiplyMatrices(this, m);
  }

  /// Pre-multiplies this matrix by [m].
  Matrix3 premultiply(Matrix3 m) {
    return multiplyMatrices(m, this);
  }

  /// Sets this matrix to a x b.
  Matrix3 multiplyMatrices(Matrix3 a, Matrix3 b) {
    var ae = a.elements;
    var be = b.elements;
    var te = elements;

    var a11 = ae[0], a12 = ae[3], a13 = ae[6];
    var a21 = ae[1], a22 = ae[4], a23 = ae[7];
    var a31 = ae[2], a32 = ae[5], a33 = ae[8];

    var b11 = be[0], b12 = be[3], b13 = be[6];
    var b21 = be[1], b22 = be[4], b23 = be[7];
    var b31 = be[2], b32 = be[5], b33 = be[8];

    te[0] = a11 * b11 + a12 * b21 + a13 * b31;
    te[3] = a11 * b12 + a12 * b22 + a13 * b32;
    te[6] = a11 * b13 + a12 * b23 + a13 * b33;

    te[1] = a21 * b11 + a22 * b21 + a23 * b31;
    te[4] = a21 * b12 + a22 * b22 + a23 * b32;
    te[7] = a21 * b13 + a22 * b23 + a23 * b33;

    te[2] = a31 * b11 + a32 * b21 + a33 * b31;
    te[5] = a31 * b12 + a32 * b22 + a33 * b32;
    te[8] = a31 * b13 + a32 * b23 + a33 * b33;

    return this;
  }

  /// Multiplies every component of the matrix by the scalar value s.
  Matrix3 multiplyScalar(double s) {
    var te = elements;

    te[0] *= s;
    te[3] *= s;
    te[6] *= s;
    te[1] *= s;
    te[4] *= s;
    te[7] *= s;
    te[2] *= s;
    te[5] *= s;
    te[8] *= s;

    return this;
  }

  /// Computes and returns the determinant of this matrix.
  double determinant() {
    var te = elements;

    var a = te[0];
    var b = te[1];
    var c = te[2];
    var d = te[3];
    var e = te[4];
    var f = te[5];
    var g = te[6];
    var h = te[7];
    var i = te[8];

    return a * e * i - a * f * h - b * d * i + b * f * g + c * d * h - c * e * g;
  }

  /// Inverts this matrix, using the analytic method.
  /// You can not invert with a determinant of zero.
  /// If you attempt this, the method produces a zero
  /// matrix instead.
  Matrix3 invert() {
    var te = elements;

    var n11 = te[0], n21 = te[1], n31 = te[2];
    var n12 = te[3], n22 = te[4], n32 = te[5];
    var n13 = te[6], n23 = te[7], n33 = te[8];

    var t11 = n33 * n22 - n32 * n23;
    var t12 = n32 * n13 - n33 * n12;
    var t13 = n23 * n12 - n22 * n13;

    var det = n11 * t11 + n21 * t12 + n31 * t13;

    if (det == 0) return set(0, 0, 0, 0, 0, 0, 0, 0, 0);

    var detInv = 1 / det;

    te[0] = t11 * detInv;
    te[1] = (n31 * n23 - n33 * n21) * detInv;
    te[2] = (n32 * n21 - n31 * n22) * detInv;

    te[3] = t12 * detInv;
    te[4] = (n33 * n11 - n31 * n13) * detInv;
    te[5] = (n31 * n12 - n32 * n11) * detInv;

    te[6] = t13 * detInv;
    te[7] = (n21 * n13 - n23 * n11) * detInv;
    te[8] = (n22 * n11 - n21 * n12) * detInv;

    return this;
  }

  /// Transposes this matrix in place.
  Matrix3 transpose() {
    var tmp;
    var m = elements;

    tmp = m[1];
    m[1] = m[3];
    m[3] = tmp;
    tmp = m[2];
    m[2] = m[6];
    m[6] = tmp;
    tmp = m[5];
    m[5] = m[7];
    m[7] = tmp;

    return this;
  }

  /// Sets this matrix as the upper left 3x3 of the normal matrix of
  /// the passed matrix4. The normal matrix is the inverse transpose
  /// of the matrix m.
  ///
  /// - [m] - Matrix4
  ///
  Matrix3 getNormalMatrix(Matrix4 matrix4) {
    return setFromMatrix4(matrix4).invert().transpose();
  }

  /// Transposes this matrix into the supplied array, and returns
  /// itself unchanged.
  ///
  /// - [r] - array to store the resulting vector in.
  Matrix3 transposeIntoArray(List<double> r) {
    var m = elements;

    r[0] = m[0];
    r[1] = m[3];
    r[2] = m[6];
    r[3] = m[1];
    r[4] = m[4];
    r[5] = m[7];
    r[6] = m[2];
    r[7] = m[5];
    r[8] = m[8];

    return this;
  }

  /// Sets the UV transform matrix from offset, repeat, rotation, and center.
  ///
  /// - [tx] - offset x
  /// - [ty] - offset y
  /// - [sx] - repeat x
  /// - [sy] - repeat y
  /// - [rotation] - rotation (in radians)
  /// - [cx] - center x of rotation
  /// - [cy] - center y of rotation
  Matrix3 setUvTransform(double tx, double ty, double sx, double sy, double rotation, double cx, double cy) {
    var c = cos(rotation);
    var s = sin(rotation);

    set(
      sx * c, sx * s, -sx * (c * cx + s * cy) + cx + tx, //
      -sy * s, sy * c, -sy * (-s * cx + c * cy) + cy + ty, //
      0, 0, 1, //
    );

    return this;
  }

  Matrix3 scale(sx, sy) {
    var te = elements;

    te[0] *= sx;
    te[3] *= sx;
    te[6] *= sx;
    te[1] *= sy;
    te[4] *= sy;
    te[7] *= sy;

    return this;
  }

  Matrix3 rotate(theta) {
    var c = cos(theta);
    var s = sin(theta);

    var te = elements;

    var a11 = te[0], a12 = te[3], a13 = te[6];
    var a21 = te[1], a22 = te[4], a23 = te[7];

    te[0] = c * a11 + s * a21;
    te[3] = c * a12 + s * a22;
    te[6] = c * a13 + s * a23;

    te[1] = -s * a11 + c * a21;
    te[4] = -s * a12 + c * a22;
    te[7] = -s * a13 + c * a23;

    return this;
  }

  Matrix3 translate(tx, ty) {
    var te = elements;

    te[0] += tx * te[2];
    te[3] += tx * te[5];
    te[6] += tx * te[8];
    te[1] += ty * te[2];
    te[4] += ty * te[5];
    te[7] += ty * te[8];

    return this;
  }

  /// Return true if this matrix and m are equal.
  bool equals(Matrix3 matrix) {
    var te = elements;
    var me = matrix.elements;

    for (var i = 0; i < 9; i++) {
      if (te[i] != me[i]) return false;
    }

    return true;
  }

  /// Sets the elements of this matrix based on an array in column-major format.
  ///
  /// - [array] - the array to read the elements from.
  /// - [offset] - (optional) index of first element in the array. Default is 0.
  Matrix3 fromArray(List<double> array, [int offset = 0]) {
    for (var i = 0; i < 9; i++) {
      elements[i] = array[i + offset];
    }

    return this;
  }

  /// Writes the elements of this matrix to an array in column-major format.
  ///
  /// - [array] - (optional) array to store the resulting vector in. If not given a new array will be created.
  /// - [offset] - (optional) offset in the array at which to put the result.
  List toArray([List array = const [], int offset = 0]) {
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

    return array;
  }

  /// Creates a new Matrix3 and with identical elements to this one.
  Matrix3 clone() {
    return Matrix3().fromArray(elements);
  }
}
