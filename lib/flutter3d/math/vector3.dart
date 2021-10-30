class Vector3 {
  double x;
  double y;
  double z;

  Vector3([this.x = 0, this.y = 0, this.z = 0]);

  /// Sets the x, y and z components of this vector.
  Vector3 set(double _x, double _y, double _z) {
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
  Vector3 setX(double x) {
    this.x = x;
    return this;
  }

  /// Replace this vector's y value with y.
  Vector3 setY(double y) {
    this.y = y;
    return this;
  }

  /// Replace this vector's z value with z.
  Vector3 setZ(double z) {
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
}
