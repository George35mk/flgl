import 'vector3.dart';

class Matrix4 {
  // by default is the identity matrix.
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

  // /// Constructs a rotation matrix, looking from eye towards center oriented by the up vector.
  // Matrix4 lookAt(Vector3 eye, Vector3 target, Vector3 up) {
  //   var te = elements;

  //   _z.subVectors(eye, target);

  //   if (_z.lengthSq() == 0) {
  //     // eye and target are in the same position

  //     _z.z = 1;
  //   }

  //   _z.normalize();
  //   _x.crossVectors(up, _z);

  //   if (_x.lengthSq() == 0) {
  //     // up and z are parallel

  //     if (up.z.abs() == 1) {
  //       _z.x += 0.0001;
  //     } else {
  //       _z.z += 0.0001;
  //     }

  //     _z.normalize();
  //     _x.crossVectors(up, _z);
  //   }

  //   _x.normalize();
  //   _y.crossVectors(_z, _x);

  //   te[0] = _x.x;
  //   te[4] = _y.x;
  //   te[8] = _z.x;
  //   te[1] = _x.y;
  //   te[5] = _y.y;
  //   te[9] = _z.y;
  //   te[2] = _x.z;
  //   te[6] = _y.z;
  //   te[10] = _z.z;

  //   return this;
  // }

  /// Post-multiplies this matrix by m.
  Matrix4 multiply(Matrix4 m) {
    return multiplyMatrices(this, m);
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

  // operator []=(String i, double value) => {
  //       if (i == 'x')
  //         {x = value}
  //       else if (i == 'y')
  //         {y = value}
  //       else if (i == 'z')
  //         {z = value}
  //       else
  //         {throw 'Unknown operator'}
  //     }; // set
}
