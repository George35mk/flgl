import '../math/m4.dart';

class Camera {
  /// The camera position vector.
  List<double> position = [2.75, 5, 7];

  /// The camera target vector.
  List<double> target = [0, 0, 0];

  /// The camera up vector.
  List<double> up = [0, 1, 0];

  /// the camera matrix.
  List<double> cameraMatrix = M4.identity();

  /// the inverce matrix4 of cameraMatrix.
  List<double> viewMatrix = M4.identity();

  /// The camera projection matrix.
  List<double> projectionMatrix = M4.identity();

  Camera() {
    cameraMatrix = M4.lookAt(position, target, up);
    viewMatrix = M4.inverse(cameraMatrix);
  }
}
