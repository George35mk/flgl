import 'math_utils.dart';
import 'matrix4.dart';
import 'vector3.dart';

final _startP = Vector3();
final _startEnd = Vector3();

/// A geometric line segment represented by a start and end point.
class Line3 {
  Vector3 start = Vector3();
  Vector3 end = Vector3();

  /// - start - Start of the line segment. Default is (0, 0, 0).
  /// - end - End of the line segment. Default is (0, 0, 0).
  Line3([Vector3? start, Vector3? end]) {
    this.start = start ?? Vector3();
    this.end = end ?? Vector3();
  }

  /// Sets the start and end values by copying the provided vectors.
  ///
  /// - [start] - set the start point of the line.
  /// - [end] - set the end point of the line.
  Line3 set(Vector3 start, Vector3 end) {
    this.start.copy(start);
    this.end.copy(end);

    return this;
  }

  /// Copies the passed line's start and end vectors to this line.
  Line3 copy(Line3 line) {
    start.copy(line.start);
    end.copy(line.end);

    return this;
  }

  /// Returns the center of the line segment.
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 getCenter(Vector3 target) {
    return target.addVectors(start, end).multiplyScalar(0.5);
  }

  /// Returns the delta vector of the line segment ( end vector minus the start vector).
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 delta(Vector3 target) {
    return target.subVectors(end, start);
  }

  /// Returns the square of the Euclidean distance (straight-line distance)
  /// between the line's start and end vectors.
  double distanceSq() {
    return start.distanceToSquared(end);
  }

  /// Returns the Euclidean distance (straight-line distance) between the line's start and end points.
  double distance() {
    return start.distanceTo(end);
  }

  /// Returns a vector at a certain position along the line. When t = 0, it returns the start
  /// vector, and when t = 1 it returns the end vector.
  ///
  /// - [t] - Use values 0-1 to return a position along the line segment.
  /// - [target] — the result will be copied into this Vector3.
  Vector3 at(double t, Vector3 target) {
    return delta(target).multiplyScalar(t).add(start);
  }

  /// Returns a point parameter based on the closest point as projected on the line segement.
  /// If clampToLine is true, then the returned value will be between 0 and 1.
  ///
  /// - [point] - the point for which to return a point parameter.
  /// - [clampToLine] - Whether to clamp the result to the range [0, 1].
  double closestPointToPointParameter(Vector3 point, bool clampToLine) {
    _startP.subVectors(point, start);
    _startEnd.subVectors(end, start);

    final startEnd2 = _startEnd.dot(_startEnd);
    final startEndStartP = _startEnd.dot(_startP);

    var t = startEndStartP / startEnd2;

    if (clampToLine) {
      t = MathUtils.clamp(t, 0, 1);
    }

    return t;
  }

  /// Returns the closets point on the line. If clampToLine is true, then the
  /// returned value will be clamped to the line segment.
  ///
  /// - [point] - return the closest point on the line to this point.
  /// - [clampToLine] - whether to clamp the returned value to the line segment.
  /// - [target] — the result will be copied into this Vector3.
  Vector3 closestPointToPoint(Vector3 point, bool clampToLine, Vector3 target) {
    final t = closestPointToPointParameter(point, clampToLine);

    return delta(target).multiplyScalar(t).add(start);
  }

  /// Applies a matrix transform to the line segment.
  Line3 applyMatrix4(Matrix4 matrix) {
    start.applyMatrix4(matrix);
    end.applyMatrix4(matrix);

    return this;
  }

  /// Returns true if both line's start and end points are equal.
  ///
  /// - [line] - Line3 to compare with this one.
  bool equals(Line3 line) {
    return line.start.equals(start) && line.end.equals(end);
  }

  /// Returns a new Line3 with the same start and end vectors as this one.
  Line3 clone() {
    return Line3().copy(this);
  }
}
