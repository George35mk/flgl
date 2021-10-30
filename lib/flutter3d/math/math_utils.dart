import 'dart:math';

class MathUtils {
  static radToDeg(double r) {
    return r * 180 / pi;
  }

  static degToRad(double d) {
    return d * pi / 180;
  }
}
