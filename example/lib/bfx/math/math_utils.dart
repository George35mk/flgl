import 'dart:math' as math;

class MathUtils {
  static clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }
}
