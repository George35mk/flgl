import 'dart:math' as math;
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class MathUtils {
  static clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }
}
