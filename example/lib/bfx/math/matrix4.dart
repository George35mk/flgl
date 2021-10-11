import 'dart:math' as math;
import 'euler.dart';
import 'matrix3.dart';
import 'quaternion.dart';
import 'vector3.dart';

final _v1 = Vector3();
final _m1 = Matrix4();
final _zero = Vector3(0, 0, 0);
final _one = Vector3(1, 1, 1);
final _x = Vector3();
final _y = Vector3();
final _z = Vector3();

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

  /// Resets this matrix to the identity matrix.
  Matrix4 identity() {
    set(
      1, 0, 0, 0, //
      0, 1, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    );
    return this;
  }

  /// Creates a new Matrix4 with identical elements to this one.
  Matrix4 clone() {
    return Matrix4().fromArray(elements);
  }

  /// Copies the elements of matrix m into this matrix.
  Matrix4 copy(Matrix4 m) {
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

  /// Copies the translation component of the supplied matrix m
  /// into this matrix's translation component.
  Matrix4 copyPosition(Matrix4 m) {
    var te = elements;
    var me = m.elements;

    te[12] = me[12];
    te[13] = me[13];
    te[14] = me[14];

    return this;
  }

  /// Set the upper 3x3 elements of this matrix to the values of the Matrix3 m.
  Matrix4 setFromMatrix3(Matrix3 m) {
    var me = m.elements;

    set(
      me[0], me[3], me[6], 0, //
      me[1], me[4], me[7], 0, //
      me[2], me[5], me[8], 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Extracts the basis of this matrix into the three axis vectors provided.
  /// If this matrix is:
  ///
  /// ```dart
  /// a, b, c, d,
  /// e, f, g, h,
  /// i, j, k, l,
  /// m, n, o, p
  /// ```
  ///
  /// Then the xAxis, yAxis, zAxis will be set to:
  ///
  /// ```dart
  /// xAxis = (a, e, i)
  /// yAxis = (b, f, j)
  /// zAxis = (c, g, k)
  /// ```
  Matrix4 extractBasis(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis) {
    xAxis.setFromMatrixColumn(this, 0);
    yAxis.setFromMatrixColumn(this, 1);
    zAxis.setFromMatrixColumn(this, 2);

    return this;
  }

  /// Set this to the basis matrix consisting of the three provided basis vectors:
  ///
  /// ```dart
  /// xAxis.x, yAxis.x, zAxis.x, 0,
  /// xAxis.y, yAxis.y, zAxis.y, 0,
  /// xAxis.z, yAxis.z, zAxis.z, 0,
  /// 0,       0,       0,       1
  /// ```
  Matrix4 makeBasis(Vector3 xAxis, Vector3 yAxis, Vector3 zAxis) {
    set(
      xAxis.x, yAxis.x, zAxis.x, 0, //
      xAxis.y, yAxis.y, zAxis.y, 0, //
      xAxis.z, yAxis.z, zAxis.z, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Extracts the rotation component of the supplied matrix m into this matrix's rotation component.
  Matrix4 extractRotation(Matrix4 m) {
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

  /// Sets the rotation component (the upper left 3x3 matrix) of this matrix
  /// to the rotation specified by the given Euler Angle. The rest of the
  /// matrix is set to the identity. Depending on the order of the euler,
  /// there are six possible outcomes. See this page for a complete list.
  Matrix4 makeRotationFromEuler(Euler euler) {
    if (!(euler != null && euler.isEuler)) {
      print('THREE.Matrix4: .makeRotationFromEuler() now expects a Euler rotation rather than a Vector3 and order.');
    }

    var te = elements;

    var x = euler.x, y = euler.y, z = euler.z;
    var a = math.cos(x), b = math.sin(x);
    var c = math.cos(y), d = math.sin(y);
    var e = math.cos(z), f = math.sin(z);

    if (euler.order == 'XYZ') {
      var ae = a * e;
      var af = a * f;
      var be = b * e;
      var bf = b * f;

      te[0] = c * e;
      te[4] = -c * f;
      te[8] = d;

      te[1] = af + be * d;
      te[5] = ae - bf * d;
      te[9] = -b * c;

      te[2] = bf - ae * d;
      te[6] = be + af * d;
      te[10] = a * c;
    } else if (euler.order == 'YXZ') {
      var ce = c * e;
      var cf = c * f;
      var de = d * e;
      var df = d * f;

      te[0] = ce + df * b;
      te[4] = de * b - cf;
      te[8] = a * d;

      te[1] = a * f;
      te[5] = a * e;
      te[9] = -b;

      te[2] = cf * b - de;
      te[6] = df + ce * b;
      te[10] = a * c;
    } else if (euler.order == 'ZXY') {
      var ce = c * e;
      var cf = c * f;
      var de = d * e;
      var df = d * f;

      te[0] = ce - df * b;
      te[4] = -a * f;
      te[8] = de + cf * b;

      te[1] = cf + de * b;
      te[5] = a * e;
      te[9] = df - ce * b;

      te[2] = -a * d;
      te[6] = b;
      te[10] = a * c;
    } else if (euler.order == 'ZYX') {
      var ae = a * e;
      var af = a * f;
      var be = b * e;
      var bf = b * f;

      te[0] = c * e;
      te[4] = be * d - af;
      te[8] = ae * d + bf;

      te[1] = c * f;
      te[5] = bf * d + ae;
      te[9] = af * d - be;

      te[2] = -d;
      te[6] = b * c;
      te[10] = a * c;
    } else if (euler.order == 'YZX') {
      var ac = a * c;
      var ad = a * d;
      var bc = b * c;
      var bd = b * d;

      te[0] = c * e;
      te[4] = bd - ac * f;
      te[8] = bc * f + ad;

      te[1] = f;
      te[5] = a * e;
      te[9] = -b * e;

      te[2] = -d * e;
      te[6] = ad * f + bc;
      te[10] = ac - bd * f;
    } else if (euler.order == 'XZY') {
      var ac = a * c;
      var ad = a * d;
      var bc = b * c;
      var bd = b * d;

      te[0] = c * e;
      te[4] = -f;
      te[8] = d * e;

      te[1] = ac * f + bd;
      te[5] = a * e;
      te[9] = ad * f - bc;

      te[2] = bc * f - ad;
      te[6] = b * e;
      te[10] = bd * f + ac;
    }

    // bottom row
    te[3] = 0;
    te[7] = 0;
    te[11] = 0;

    // last column
    te[12] = 0;
    te[13] = 0;
    te[14] = 0;
    te[15] = 1;

    return this;
  }

  /// Sets the rotation component of this matrix to the rotation specified by q, as outlined here.
  /// The rest of the matrix is set to the identity.
  /// So, given q = w + xi + yj + zk, the resulting matrix will be:
  ///
  /// ```
  /// 1-2y²-2z²    2xy-2zw    2xz+2yw    0
  /// 2xy+2zw      1-2x²-2z²  2yz-2xw    0
  /// 2xz-2yw      2yz+2xw    1-2x²-2y²  0
  /// 0            0          0          1
  /// ```
  Matrix4 makeRotationFromQuaternion(Quaternion q) {
    return compose(_zero, q, _one);
  }

  /// Constructs a rotation matrix, looking from eye towards center oriented by the up vector.
  Matrix4 lookAt(Vector3 eye, Vector3 target, Vector3 up) {
    var te = elements;

    _z.subVectors(eye, target);

    if (_z.lengthSq() == 0) {
      // eye and target are in the same position

      _z.z = 1;
    }

    _z.normalize();
    _x.crossVectors(up, _z);

    if (_x.lengthSq() == 0) {
      // up and z are parallel

      if (up.z.abs() == 1) {
        _z.x += 0.0001;
      } else {
        _z.z += 0.0001;
      }

      _z.normalize();
      _x.crossVectors(up, _z);
    }

    _x.normalize();
    _y.crossVectors(_z, _x);

    te[0] = _x.x;
    te[4] = _y.x;
    te[8] = _z.x;
    te[1] = _x.y;
    te[5] = _y.y;
    te[9] = _z.y;
    te[2] = _x.z;
    te[6] = _y.z;
    te[10] = _z.z;

    return this;
  }

  /// Post-multiplies this matrix by m.
  Matrix4 multiply(Matrix4 m, [n]) {
    if (n != null) {
      print('THREE.Matrix4: .multiply() now only accepts one argument. Use .multiplyMatrices( a, b ) instead.');
      return multiplyMatrices(m, n);
    }

    return multiplyMatrices(this, m);
  }

  /// Pre-multiplies this matrix by m.
  Matrix4 premultiply(Matrix4 m) {
    return multiplyMatrices(m, this);
  }

  /// Sets this matrix to a x b.
  Matrix4 multiplyMatrices(Matrix4 a, Matrix4 b) {
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

  /// Multiplies every component of the matrix by a scalar value [s].
  Matrix4 multiplyScalar(double s) {
    var te = elements;

    te[0] *= s;
    te[4] *= s;
    te[8] *= s;
    te[12] *= s;
    te[1] *= s;
    te[5] *= s;
    te[9] *= s;
    te[13] *= s;
    te[2] *= s;
    te[6] *= s;
    te[10] *= s;
    te[14] *= s;
    te[3] *= s;
    te[7] *= s;
    te[11] *= s;
    te[15] *= s;

    return this;
  }

  /// Computes and returns the determinant of this matrix
  double determinant() {
    var te = elements;

    var n11 = te[0], n12 = te[4], n13 = te[8], n14 = te[12];
    var n21 = te[1], n22 = te[5], n23 = te[9], n24 = te[13];
    var n31 = te[2], n32 = te[6], n33 = te[10], n34 = te[14];
    var n41 = te[3], n42 = te[7], n43 = te[11], n44 = te[15];

    // TODO: make this more efficient
    //( based on http://www.euclideanspace.com/maths/algebra/matrix/functions/inverse/fourD/index.htm )

    return (n41 *
            (n14 * n23 * n32 -
                n13 * n24 * n32 -
                n14 * n22 * n33 +
                n12 * n24 * n33 +
                n13 * n22 * n34 -
                n12 * n23 * n34) +
        n42 *
            (n11 * n23 * n34 -
                n11 * n24 * n33 +
                n14 * n21 * n33 -
                n13 * n21 * n34 +
                n13 * n24 * n31 -
                n14 * n23 * n31) +
        n43 *
            (n11 * n24 * n32 -
                n11 * n22 * n34 -
                n14 * n21 * n32 +
                n12 * n21 * n34 +
                n14 * n22 * n31 -
                n12 * n24 * n31) +
        n44 *
            (-n13 * n22 * n31 -
                n11 * n23 * n32 +
                n11 * n22 * n33 +
                n13 * n21 * n32 -
                n12 * n21 * n33 +
                n12 * n23 * n31));
  }

  /// Transposes this matrix.
  Matrix4 transpose() {
    var te = elements;
    dynamic tmp;

    tmp = te[1];
    te[1] = te[4];
    te[4] = tmp;
    tmp = te[2];
    te[2] = te[8];
    te[8] = tmp;
    tmp = te[6];
    te[6] = te[9];
    te[9] = tmp;

    tmp = te[3];
    te[3] = te[12];
    te[12] = tmp;
    tmp = te[7];
    te[7] = te[13];
    te[13] = tmp;
    tmp = te[11];
    te[11] = te[14];
    te[14] = tmp;

    return this;
  }

  /// Sets the position component for this matrix from vector v,
  /// without affecting the rest of the matrix - i.e. if the matrix is currently:
  ///
  /// - .setPosition ( v : Vector3 ) : this
  /// - .setPosition ( x : double, y : double, z : double ) : this // optional API
  ///
  /// ```
  /// a, b, c, d,
  /// e, f, g, h,
  /// i, j, k, l,
  /// m, n, o, p
  /// ```
  ///
  /// This becomes:
  ///
  /// ```
  /// a, b, c, v.x,
  /// e, f, g, v.y,
  /// i, j, k, v.z,
  /// m, n, o, p
  /// ```
  Matrix4 setPosition(dynamic x, [y, z]) {
    var te = elements;

    if (x.isVector3) {
      te[12] = x.x;
      te[13] = x.y;
      te[14] = x.z;
    } else {
      te[12] = x;
      te[13] = y;
      te[14] = z;
    }

    return this;
  }

  /// Inverts this matrix, using the analytic method.
  /// You can not invert with a determinant of zero.
  /// If you attempt this, the method produces a zero matrix instead.
  Matrix4 invert() {
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

  /// Multiplies the columns of this matrix by vector v.
  Matrix4 scale(Vector3 v) {
    var te = elements;
    var x = v.x, y = v.y, z = v.z;

    te[0] *= x;
    te[4] *= y;
    te[8] *= z;
    te[1] *= x;
    te[5] *= y;
    te[9] *= z;
    te[2] *= x;
    te[6] *= y;
    te[10] *= z;
    te[3] *= x;
    te[7] *= y;
    te[11] *= z;

    return this;
  }

  /// Gets the maximum scale value of the 3 axes.
  double getMaxScaleOnAxis() {
    var te = elements;

    var scaleXSq = te[0] * te[0] + te[1] * te[1] + te[2] * te[2];
    var scaleYSq = te[4] * te[4] + te[5] * te[5] + te[6] * te[6];
    var scaleZSq = te[8] * te[8] + te[9] * te[9] + te[10] * te[10];

    return math.sqrt(math.max(math.max(scaleXSq, scaleYSq), scaleZSq));
  }

  /// Sets this matrix as a translation transform:
  ///
  /// - [x] the amount to translate in the X axis.
  /// - [y] the amount to translate in the Y axis.
  /// - [z] the amount to translate in the Z axis.
  /// ```
  /// 1, 0, 0, x,
  /// 0, 1, 0, y,
  /// 0, 0, 1, z,
  /// 0, 0, 0, 1
  /// ```
  Matrix4 makeTranslation(double x, double y, double z) {
    set(
      1, 0, 0, x, //
      0, 1, 0, y, //
      0, 0, 1, z, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as a rotational transformation around the X axis
  /// by theta (θ) radians. The resulting matrix will be:
  ///
  /// - [theta] — Rotation angle in radians.
  ///
  /// ```
  /// 1 0      0        0
  /// 0 cos(θ) -sin(θ)  0
  /// 0 sin(θ) cos(θ)   0
  /// 0 0      0        1
  /// ```
  Matrix4 makeRotationX(double theta) {
    var c = math.cos(theta), s = math.sin(theta);

    set(
      1, 0, 0, 0, //
      0, c, -s, 0, //
      0, s, c, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as a rotational transformation around the Y axis
  /// by theta (θ) radians. The resulting matrix will be:
  ///
  /// - [theta] — Rotation angle in radians.
  ///
  /// ```
  /// cos(θ)  0 sin(θ) 0
  /// 0       1 0      0
  /// -sin(θ) 0 cos(θ) 0
  /// 0       0 0      1
  /// ```
  Matrix4 makeRotationY(double theta) {
    var c = math.cos(theta);
    var s = math.sin(theta);

    set(
      c, 0, s, 0, //
      0, 1, 0, 0, //
      -s, 0, c, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as a rotational transformation around the Z axis
  /// by theta (θ) radians. The resulting matrix will be:
  ///
  /// - [theta] — Rotation angle in radians.
  ///
  /// ```
  /// cos(θ) -sin(θ) 0 0
  /// sin(θ) cos(θ)  0 0
  /// 0      0       1 0
  /// 0      0       0 1
  /// ```
  Matrix4 makeRotationZ(double theta) {
    var c = math.cos(theta);
    var s = math.sin(theta);

    set(
      c, -s, 0, 0, //
      s, c, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as rotation transform around axis by theta radians.
  /// This is a somewhat controversial but mathematically sound alternative to
  /// rotating via Quaternions. See the discussion here.
  ///
  /// - [axis] — Rotation axis, should be normalized.
  /// - [theta] — Rotation angle in radians.
  Matrix4 makeRotationAxis(Vector3 axis, double angle) {
    // Based on http://www.gamedev.net/reference/articles/article1199.asp

    var c = math.cos(angle);
    var s = math.sin(angle);
    var t = 1 - c;
    var x = axis.x, y = axis.y, z = axis.z;
    var tx = t * x, ty = t * y;

    set(
      tx * x + c, tx * y - s * z, tx * z + s * y, 0, //
      tx * y + s * z, ty * y + c, ty * z - s * x, 0, //
      tx * z - s * y, ty * z + s * x, t * z * z + c, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as scale transform:
  ///
  /// - [x] - the amount to scale in the X axis.
  /// - [y] - the amount to scale in the Y axis.
  /// - [z] - the amount to scale in the Z axis.
  ///
  /// ```
  /// x, 0, 0, 0,
  /// 0, y, 0, 0,
  /// 0, 0, z, 0,
  /// 0, 0, 0, 1
  /// ```
  Matrix4 makeScale(double x, double y, double z) {
    set(
      x, 0, 0, 0, //
      0, y, 0, 0, //
      0, 0, z, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix as a shear transform:
  ///
  /// - [xy] - the amount to shear X by Y.
  /// - [xz] - the amount to shear X by Z.
  /// - [yx] - the amount to shear Y by X.
  /// - [yz] - the amount to shear Y by Z.
  /// - [zx] - the amount to shear Z by X.
  /// - [zy] - the amount to shear Z by Y.
  ///
  /// ```
  /// 1,   yx,  zx,  0,
  /// xy,   1,  zy,  0,
  /// xz,  yz,   1,  0,
  /// 0,    0,   0,  1
  /// ```
  Matrix4 makeShear(double xy, double xz, double yx, double yz, double zx, double zy) {
    set(
      1, yx, zx, 0, //
      xy, 1, zy, 0, //
      xz, yz, 1, 0, //
      0, 0, 0, 1, //
    );

    return this;
  }

  /// Sets this matrix to the transformation composed of position, quaternion and scale.
  Matrix4 compose(Vector3 position, Quaternion quaternion, Vector3 scale) {
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

    var sx = scale.x;
    var sy = scale.y;
    var sz = scale.z;

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

  /// Decomposes this matrix into its position, quaternion and scale components.
  ///
  /// Note: Not all matrices are decomposable in this way. For example,
  /// if an object has a non-uniformly scaled parent, then the object's
  /// world matrix may not be decomposable, and this method may not be
  /// appropriate.
  ///
  /// returns null
  decompose(Vector3 position, Quaternion quaternion, Vector3 scale) {
    var te = elements;

    var sx = _v1.set(te[0], te[1], te[2]).length();
    var sy = _v1.set(te[4], te[5], te[6]).length();
    var sz = _v1.set(te[8], te[9], te[10]).length();

    // if determine is negative, we need to invert one scale
    var det = determinant();
    if (det < 0) sx = -sx;

    position.x = te[12];
    position.y = te[13];
    position.z = te[14];

    // scale the rotation part
    _m1.copy(this);

    var invSX = 1 / sx;
    var invSY = 1 / sy;
    var invSZ = 1 / sz;

    _m1.elements[0] *= invSX;
    _m1.elements[1] *= invSX;
    _m1.elements[2] *= invSX;

    _m1.elements[4] *= invSY;
    _m1.elements[5] *= invSY;
    _m1.elements[6] *= invSY;

    _m1.elements[8] *= invSZ;
    _m1.elements[9] *= invSZ;
    _m1.elements[10] *= invSZ;

    quaternion.setFromRotationMatrix(_m1);

    scale.x = sx;
    scale.y = sy;
    scale.z = sz;

    return this;
  }

  /// Creates a perspective projection matrix.
  /// This is used internally by PerspectiveCamera.updateProjectionMatrix()
  Matrix4 makePerspective(double left, double right, double top, double bottom, double near, double far) {
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

  /// Creates an orthographic projection matrix.
  /// This is used internally by OrthographicCamera.updateProjectionMatrix().
  Matrix4 makeOrthographic(double left, double right, double top, double bottom, double near, double far) {
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

  /// Return true if this matrix and m are equal.
  bool equals(Matrix4 matrix) {
    final te = elements;
    final me = matrix.elements;

    for (var i = 0; i < 16; i++) {
      if (te[i] != me[i]) return false;
    }

    return true;
  }

  /// Sets the elements of this matrix based on an array in column-major format.
  ///
  /// - [array] - the array to read the elements from.
  /// - [offset] - ( optional ) offset into the array. Default is 0.
  Matrix4 fromArray(array, [offset = 0]) {
    for (var i = 0; i < 16; i++) {
      elements[i] = array[i + offset];
    }

    return this;
  }

  /// Writes the elements of this matrix to an array in column-major format.
  ///
  /// - [array] - (optional) array to store the resulting vector in.
  /// - [offset] - (optional) offset in the array at which to put the result.
  List<double> toArray([array = List, offset = 0]) {
    final te = elements;

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

  // static List<num> lookAt(Vector3 cameraPosition, Vector3 target, Vector3 up) {
  //   Vector3 zAxis = normalize(subtractVectors(cameraPosition, target));
  //   Vector3 xAxis = normalize(cross(up, zAxis));
  //   Vector3 yAxis = normalize(cross(zAxis, xAxis));

  //   return [
  //     xAxis.x, xAxis.y, xAxis.z, 0, //
  //     yAxis.x, yAxis.y, yAxis.z, 0, //
  //     zAxis.x, zAxis.y, zAxis.z, 0, //
  //     cameraPosition.x, cameraPosition.y, cameraPosition.z, 1, //
  //   ];
  // }

  // static Vector3 normalize(Vector3 v) {
  //   var length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  //   // make sure we don't divide by 0.
  //   if (length > 0.00001) {
  //     return Vector3(v.x / length, v.y / length, v.z / length);
  //   } else {
  //     return Vector3(0, 0, 0);
  //   }
  // }

  // static Vector3 subtractVectors(Vector3 a, Vector3 b) {
  //   return Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
  // }

  // static Vector3 cross(Vector3 a, Vector3 b) {
  //   return Vector3(
  //     a.y * b.z - a.z * b.y,
  //     a.z * b.x - a.x * b.z,
  //     a.x * b.y - a.y * b.x,
  //   );
  // }

}
