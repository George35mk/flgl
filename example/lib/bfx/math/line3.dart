import 'math_utils.dart';
import 'vector3.dart';

final _startP = Vector3();
final _startEnd = Vector3();

/// A geometric line segment represented by a start and end point.
class Line3 {
  Vector3 start = Vector3();
  Vector3 end = Vector3();

  Line3([Vector3? start, Vector3? end]) {
    this.start = start ?? Vector3();
    this.end = end ?? Vector3();
  }

  Line3 set(Vector3 start, Vector3 end) {
    this.start.copy(start);
    this.end.copy(end);

    return this;
  }

  Line3 copy(Line3 line) {
    start.copy(line.start);
    end.copy(line.end);

    return this;
  }

  getCenter(target) {
    return target.addVectors(start, end).multiplyScalar(0.5);
  }

  delta(target) {
    return target.subVectors(end, start);
  }

  distanceSq() {
    return start.distanceToSquared(end);
  }

  distance() {
    return start.distanceTo(end);
  }

  at(t, target) {
    return delta(target).multiplyScalar(t).add(start);
  }

  closestPointToPointParameter(point, clampToLine) {
    _startP.subVectors(point, start);
    _startEnd.subVectors(end, start);

    final startEnd2 = _startEnd.dot(_startEnd);
    final startEnd_startP = _startEnd.dot(_startP);

    var t = startEnd_startP / startEnd2;

    if (clampToLine) {
      t = MathUtils.clamp(t, 0, 1);
    }

    return t;
  }

  closestPointToPoint(point, clampToLine, target) {
    final t = closestPointToPointParameter(point, clampToLine);

    return delta(target).multiplyScalar(t).add(start);
  }

  applyMatrix4(matrix) {
    start.applyMatrix4(matrix);
    end.applyMatrix4(matrix);

    return this;
  }

  equals(line) {
    return line.start.equals(start) && line.end.equals(end);
  }

  clone() {
    return Line3().copy(this);
  }
}
