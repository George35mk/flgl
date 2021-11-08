import 'package:flgl/flutter3d/math/vector3.dart';

import '../math/m4.dart';

class Camera {
  /// The camera position vector.
  Vector3 position = Vector3(0, 0, 0);

  /// The camera target vector.
  Vector3 target = Vector3(0, 0, 0);

  /// The camera up vector.
  Vector3 up = Vector3(0, 1, 0);

  /// The camera matrix.
  List<double> cameraMatrix = M4.identity();

  /// The inverce matrix4 of cameraMatrix.
  List<double> viewMatrix = M4.identity();

  /// The camera projection matrix.
  List<double> projectionMatrix = M4.identity();

  /// The camera uniforms.
  Map<String, dynamic> uniforms = {};

  Camera() {
    updateCameraMatrix();
  }

  /// Update the camera matrix and view matrix.
  updateCameraMatrix() {
    cameraMatrix = M4.lookAt(
      [position.x, position.y, position.z],
      [target.x, target.y, target.z],
      [up.x, up.y, up.z],
    );
    viewMatrix = M4.inverse(cameraMatrix);

    // Set the camera related uniforms.
    uniforms['u_projection'] = projectionMatrix;
    uniforms['u_view'] = viewMatrix;
  }

  /// Set's the object position.
  setPosition(Vector3 v) {
    position.copy(v);
    updateCameraMatrix();
  }

  /// Set's the object target.
  setTarget(Vector3 v) {
    target.copy(v);
    updateCameraMatrix();
  }

  /// Set's the object target.
  setUp(Vector3 v) {
    up.copy(v);
    updateCameraMatrix();
  }
}
