import 'dart:math' as math;

class MathUtils {
  static double radToDeg(double r) {
    return r * 180 / math.pi;
  }

  static double degToRad(double d) {
    return d * math.pi / 180;
  }

  static clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }

  static lerp(x, y, t) {
    return (1 - t) * x + t * y;
  }

  static euclideanModulo(n, m) {
    return ((n % m) + m) % m;
  }
}
