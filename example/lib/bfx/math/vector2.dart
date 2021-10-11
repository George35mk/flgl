import 'package:flgl_example/bfx/core/buffer_attribute.dart';

import 'matrix3.dart';
import 'dart:math' as math;

class Vector2 {
  bool isVector2 = true;
  double x;
  double y;

  Vector2([this.x = 0, this.y = 0]);

  double get width {
    return x;
  }

  set width(double value) {
    x = value;
  }

  double get height {
    return y;
  }

  set height(double value) {
    y = value;
  }

  Vector2 set(double x, double y) {
    this.x = x;
    this.y = y;

    return this;
  }

  Vector2 setScalar(double scalar) {
    x = scalar;
    y = scalar;

    return this;
  }

  Vector2 setX(x) {
    this.x = x;

    return this;
  }

  Vector2 setY(y) {
    this.y = y;

    return this;
  }

  Vector2 setComponent(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
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
      default:
        throw ('index is out of range: $index');
    }
  }

  Vector2 clone() {
    return Vector2(x, y);
  }

  Vector2 copy(Vector2 v) {
    x = v.x;
    y = v.y;

    return this;
  }

  Vector2 add(Vector2 v, [w]) {
    if (w != null) {
      print('THREE.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead.');
      return addVectors(v, w);
    }

    x += v.x;
    y += v.y;

    return this;
  }

  Vector2 addScalar(double s) {
    x += s;
    y += s;

    return this;
  }

  Vector2 addVectors(Vector2 a, Vector2 b) {
    x = a.x + b.x;
    y = a.y + b.y;

    return this;
  }

  Vector2 addScaledVector(Vector2 v, double s) {
    x += v.x * s;
    y += v.y * s;

    return this;
  }

  Vector2 sub(Vector2 v, [w]) {
    if (w != null) {
      print('THREE.Vector2: .sub() now only accepts one argument. Use .subVectors( a, b ) instead.');
      return subVectors(v, w);
    }

    x -= v.x;
    y -= v.y;

    return this;
  }

  Vector2 subScalar(double s) {
    x -= s;
    y -= s;

    return this;
  }

  Vector2 subVectors(Vector2 a, Vector2 b) {
    x = a.x - b.x;
    y = a.y - b.y;

    return this;
  }

  Vector2 multiply(Vector2 v) {
    x *= v.x;
    y *= v.y;

    return this;
  }

  Vector2 multiplyScalar(double scalar) {
    x *= scalar;
    y *= scalar;

    return this;
  }

  Vector2 divide(Vector2 v) {
    x /= v.x;
    y /= v.y;

    return this;
  }

  Vector2 divideScalar(double scalar) {
    return multiplyScalar(1 / scalar);
  }

  Vector2 applyMatrix3(Matrix3 m) {
    var x = this.x;
    var y = this.y;
    var e = m.elements;

    this.x = e[0] * x + e[3] * y + e[6];
    this.y = e[1] * x + e[4] * y + e[7];

    return this;
  }

  Vector2 min(Vector2 v) {
    x = math.min(x, v.x);
    y = math.min(y, v.y);

    return this;
  }

  Vector2 max(Vector2 v) {
    x = math.max(x, v.x);
    y = math.max(y, v.y);

    return this;
  }

  Vector2 clamp(Vector2 min, Vector2 max) {
    // assumes min < max, componentwise

    x = math.max(min.x, math.min(max.x, x));
    y = math.max(min.y, math.min(max.y, y));

    return this;
  }

  Vector2 clampScalar(minVal, maxVal) {
    x = math.max(minVal, math.min(maxVal, x));
    y = math.max(minVal, math.min(maxVal, y));

    return this;
  }

  clampLength(min, max) {
    var _length = length();

    return divideScalar(_length ?? 1).multiplyScalar(math.max(min, math.min(max, _length)));
  }

  Vector2 floor() {
    x = x.floor().toDouble();
    y = y.floor().toDouble();

    return this;
  }

  Vector2 ceil() {
    x = x.ceil().toDouble();
    y = y.ceil().toDouble();

    return this;
  }

  Vector2 round() {
    x = x.round().toDouble();
    y = y.round().toDouble();

    return this;
  }

  Vector2 roundToZero() {
    x = (x < 0) ? x.ceil().toDouble() : x.floor().toDouble();
    y = (y < 0) ? y.ceil().toDouble() : y.floor().toDouble();

    return this;
  }

  Vector2 negate() {
    x = -x;
    y = -y;

    return this;
  }

  dot(Vector2 v) {
    return x * v.x + y * v.y;
  }

  cross(Vector2 v) {
    return x * v.y - y * v.x;
  }

  lengthSq() {
    return x * x + y * y;
  }

  length() {
    return math.sqrt(x * x + y * y);
  }

  manhattanLength() {
    return x.abs() + y.abs();
  }

  Vector2 normalize() {
    return divideScalar(length() ?? 1);
  }

  angle() {
    // computes the angle in radians with respect to the positive x-axis

    var angle = math.atan2(-y, -x) + math.pi;

    return angle;
  }

  distanceTo(Vector2 v) {
    return math.sqrt(distanceToSquared(v));
  }

  distanceToSquared(Vector2 v) {
    var dx = x - v.x;
    var dy = y - v.y;
    return dx * dx + dy * dy;
  }

  manhattanDistanceTo(Vector2 v) {
    return (x - v.x).abs() + (y - v.y).abs();
  }

  setLength(length) {
    return normalize().multiplyScalar(length);
  }

  Vector2 lerp(Vector2 v, alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;

    return this;
  }

  Vector2 lerpVectors(Vector2 v1, Vector2 v2, alpha) {
    x = v1.x + (v2.x - v1.x) * alpha;
    y = v1.y + (v2.y - v1.y) * alpha;

    return this;
  }

  equals(Vector2 v) {
    return ((v.x == x) && (v.y == y));
  }

  Vector2 fromArray(array, [int offset = 0]) {
    x = array[offset];
    y = array[offset + 1];

    return this;
  }

  List<double> toArray([List<double> array = const [], int offset = 0]) {
    array[offset] = x;
    array[offset + 1] = y;

    return array;
  }

  Vector2 fromBufferAttribute(BufferAttribute attribute, int index, [offset]) {
    if (offset != null) {
      print('THREE.Vector2: offset has been removed from .fromBufferAttribute().');
    }

    x = attribute.getX(index);
    y = attribute.getY(index);

    return this;
  }

  rotateAround(center, angle) {
    var c = math.cos(angle), s = math.sin(angle);

    var x = this.x - center.x;
    var y = this.y - center.y;

    this.x = x * c - y * s + center.x;
    this.y = x * s + y * c + center.y;

    return this;
  }

  random() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();

    return this;
  }
}
