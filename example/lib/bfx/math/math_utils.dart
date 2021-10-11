import 'dart:math' as math;
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class MathUtils {
  static clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }

  /// Generates a v1 time based id.
  static String generateUUID() {
    return uuid.v1();
  }

  static lerp(x, y, t) {
    return (1 - t) * x + t * y;
  }

  static euclideanModulo(n, m) {
    return ((n % m) + m) % m;
  }
}
