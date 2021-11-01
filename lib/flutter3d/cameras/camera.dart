import 'package:flgl/flutter3d/math/vector3.dart';

import '../math/m4.dart';

class Camera {
  /// The camera position vector.
  Vector3 position = Vector3(2.75, 5, 7);

  /// The camera target vector.
  Vector3 target = Vector3(0, 0, 0);

  /// The camera up vector.
  Vector3 up = Vector3(0, 1, 0);

  /// the camera matrix.
  List<double> cameraMatrix = M4.identity();

  /// the inverce matrix4 of cameraMatrix.
  List<double> viewMatrix = M4.identity();

  /// The camera projection matrix.
  List<double> projectionMatrix = M4.identity();

  Camera() {
    cameraMatrix = M4.lookAt(
      [position.x, position.y, position.z],
      [target.x, target.y, target.z],
      [up.x, up.y, up.z],
    );
    viewMatrix = M4.inverse(cameraMatrix);
  }
}
