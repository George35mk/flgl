import 'dart:math';

class M3 {
  /// Takes two Matrix3s, a and b, and computes the product in the order
  ///
  /// that pre-composes b with a.  In other words, the matrix returned will
  ///
  /// @param {module:webgl-2d-math.Matrix3} a A matrix.
  ///
  /// @param {module:webgl-2d-math.Matrix3} b A matrix.
  ///
  /// @return {module:webgl-2d-math.Matrix3} the result.
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> multiply(a, b) {
    var a00 = a[0 * 3 + 0]; //
    var a01 = a[0 * 3 + 1]; //
    var a02 = a[0 * 3 + 2]; //
    var a10 = a[1 * 3 + 0]; //
    var a11 = a[1 * 3 + 1]; //
    var a12 = a[1 * 3 + 2]; //
    var a20 = a[2 * 3 + 0]; //
    var a21 = a[2 * 3 + 1]; //
    var a22 = a[2 * 3 + 2]; //
    var b00 = b[0 * 3 + 0]; //
    var b01 = b[0 * 3 + 1]; //
    var b02 = b[0 * 3 + 2]; //
    var b10 = b[1 * 3 + 0]; //
    var b11 = b[1 * 3 + 1]; //
    var b12 = b[1 * 3 + 2]; //
    var b20 = b[2 * 3 + 0]; //
    var b21 = b[2 * 3 + 1]; //
    var b22 = b[2 * 3 + 2]; //

    return [
      b00 * a00 + b01 * a10 + b02 * a20, //
      b00 * a01 + b01 * a11 + b02 * a21, //
      b00 * a02 + b01 * a12 + b02 * a22, //
      b10 * a00 + b11 * a10 + b12 * a20, //
      b10 * a01 + b11 * a11 + b12 * a21, //
      b10 * a02 + b11 * a12 + b12 * a22, //
      b20 * a00 + b21 * a10 + b22 * a20, //
      b20 * a01 + b21 * a11 + b22 * a21, //
      b20 * a02 + b21 * a12 + b22 * a22, //
    ];
  }

  /// Creates a 3x3 identity matrix
  ///
  /// @return {module:webgl2-2d-math.Matrix3} an identity matrix
  static List<double> identity() {
    return [
      1, 0, 0, //
      0, 1, 0, //
      0, 0, 1, //
    ];
  }

  /// Creates a 2D projection matrix
  ///
  /// @param {number} width width in pixels
  ///
  /// @param {number} height height in pixels
  ///
  /// @return {module:webgl-2d-math.Matrix3} a projection matrix that converts from pixels to clipspace with Y = 0 at the top.
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> projection(width, height) {
    // Note: This matrix flips the Y axis so 0 is at the top.
    return [
      2 / width, 0, 0, //
      0, -2 / height, 0, //
      -1, 1, 1, //
    ];
  }

  /// Multiplies by a 2D projection matrix
  ///
  /// @param {module:webgl-2d-math.Matrix3} the matrix to be multiplied
  ///
  /// @param {number} width width in pixels
  ///
  /// @param {number} height height in pixels
  ///
  /// @return {module:webgl-2d-math.Matrix3} the result
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> project(m, width, height) {
    return multiply(m, projection(width, height));
  }

  /// Creates a 2D translation matrix
  ///
  /// @param {number} tx amount to translate in x
  ///
  /// @param {number} ty amount to translate in y
  ///
  /// @return {module:webgl-2d-math.Matrix3} a translation matrix that translates by tx and ty.
  ///
  /// @memberOf module:webgl-2d-math
  static translation(double tx, double ty) {
    return [
      1, 0, 0, //
      0, 1, 0, //
      tx, ty, 1, //
    ];
  }

  /// Multiplies by a 2D translation matrix
  ///
  /// @param {module:webgl-2d-math.Matrix3} the matrix to be multiplied
  ///
  /// @param {number} tx amount to translate in x
  ///
  /// @param {number} ty amount to translate in y
  ///
  /// @return {module:webgl-2d-math.Matrix3} the result
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> translate(m, double tx, double ty) {
    return multiply(m, translation(tx, ty));
  }

  /// Creates a 2D rotation matrix
  ///
  /// @param {number} angleInRadians amount to rotate in radians
  ///
  /// @return {module:webgl-2d-math.Matrix3} a rotation matrix that rotates by angleInRadians
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> rotation(double angleInRadians) {
    var c = cos(angleInRadians);
    var s = sin(angleInRadians);
    return [
      c, -s, 0, //
      s, c, 0, //
      0, 0, 1, //
    ];
  }

  /// Multiplies by a 2D rotation matrix
  ///
  /// @param {module:webgl-2d-math.Matrix3} the matrix to be multiplied
  ///
  /// @param {number} angleInRadians amount to rotate in radians
  ///
  /// @return {module:webgl-2d-math.Matrix3} the result
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> rotate(m, double angleInRadians) {
    return multiply(m, rotation(angleInRadians));
  }

  /// Creates a 2D scaling matrix
  ///
  /// @param {number} sx amount to scale in x
  ///
  /// @param {number} sy amount to scale in y
  ///
  /// @return {module:webgl-2d-math.Matrix3} a scale matrix that scales by sx and sy.
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> scaling(double sx, double sy) {
    return [
      sx, 0, 0, //
      0, sy, 0, //
      0, 0, 1, //
    ];
  }

  /// Multiplies by a 2D scaling matrix
  ///
  /// @param {module:webgl-2d-math.Matrix3} the matrix to be multiplied
  ///
  /// @param {number} sx amount to scale in x
  ///
  /// @param {number} sy amount to scale in y
  ///
  /// @return {module:webgl-2d-math.Matrix3} the result
  ///
  /// @memberOf module:webgl-2d-math
  static List<double> scale(m, double sx, double sy) {
    return multiply(m, scaling(sx, sy));
  }

  static dot(x1, y1, x2, y2) {
    return x1 * x2 + y1 * y2;
  }

  static distance(x1, y1, x2, y2) {
    var dx = x1 - x2;
    var dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }

  static normalize(x, y) {
    var l = distance(0, 0, x, y);
    if (l > 0.00001) {
      return [x / l, y / l];
    } else {
      return [0, 0];
    }
  }

  // i = incident
  // n = normal
  static List<double> reflect(ix, iy, nx, ny) {
    // I - 2.0 * dot(N, I) * N.
    var d = dot(nx, ny, ix, iy);
    return [
      ix - 2 * d * nx, //
      iy - 2 * d * ny, //
    ];
  }

  static radToDeg(double r) {
    return r * 180 / pi;
  }

  static degToRad(double d) {
    return d * pi / 180;
  }

  static List<double> transformPoint(List<double> m, List<double> v) {
    var v0 = v[0];
    var v1 = v[1];
    var d = v0 * m[0 * 3 + 2] + v1 * m[1 * 3 + 2] + m[2 * 3 + 2];
    return [
      (v0 * m[0 * 3 + 0] + v1 * m[1 * 3 + 0] + m[2 * 3 + 0]) / d, //
      (v0 * m[0 * 3 + 1] + v1 * m[1 * 3 + 1] + m[2 * 3 + 1]) / d, //
    ];
  }

  static List<double> inverse(List<double> m) {
    var t00 = m[1 * 3 + 1] * m[2 * 3 + 2] - m[1 * 3 + 2] * m[2 * 3 + 1];
    var t10 = m[0 * 3 + 1] * m[2 * 3 + 2] - m[0 * 3 + 2] * m[2 * 3 + 1];
    var t20 = m[0 * 3 + 1] * m[1 * 3 + 2] - m[0 * 3 + 2] * m[1 * 3 + 1];
    var d = 1.0 / (m[0 * 3 + 0] * t00 - m[1 * 3 + 0] * t10 + m[2 * 3 + 0] * t20);
    return [
      d * t00, -d * t10, d * t20, //
      -d * (m[1 * 3 + 0] * m[2 * 3 + 2] - m[1 * 3 + 2] * m[2 * 3 + 0]), //
      d * (m[0 * 3 + 0] * m[2 * 3 + 2] - m[0 * 3 + 2] * m[2 * 3 + 0]), //
      -d * (m[0 * 3 + 0] * m[1 * 3 + 2] - m[0 * 3 + 2] * m[1 * 3 + 0]), //
      d * (m[1 * 3 + 0] * m[2 * 3 + 1] - m[1 * 3 + 1] * m[2 * 3 + 0]), //
      -d * (m[0 * 3 + 0] * m[2 * 3 + 1] - m[0 * 3 + 1] * m[2 * 3 + 0]), //
      d * (m[0 * 3 + 0] * m[1 * 3 + 1] - m[0 * 3 + 1] * m[1 * 3 + 0]), //
    ];
  }
}
