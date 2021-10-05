import 'package:flgl_example/bfx/matrix4.dart';

import 'object_3d.dart';
import 'vector_3.dart';

class Camera extends Object3D {
  /// The camera position
  // Vector3 position = Vector3(0, 0, 0);

  /// The camera target
  Vector3 target = Vector3(0, 0, 0);

  /// The camera up direction.
  Vector3 up = Vector3(0, 1, 0);

  /// The camera matrix
  late List<num> cameraMatrix;

  Matrix4 matrixWorldInverse = Matrix4();
  Matrix4 projectionMatrix = Matrix4();
  Matrix4 projectionMatrixInverse = Matrix4();

  Camera() {
    // cameraMatrix = Matrix4.lookAt(position, target, up);
    name = 'camera';
  }

  setPosition(Vector3 newPosition) {
    position.x = newPosition.x;
    position.y = newPosition.y;
    position.z = newPosition.z;
    // maybe you need to update the camera matrix or you can
    // do this from the projections cameras.
  }

  setTarget(Vector3 newTarget) {
    target.x = newTarget.x;
    target.y = newTarget.y;
    target.z = newTarget.z;
    // maybe you need to update the camera matrix or you can
    // do this from the projections cameras.
  }

  setUp(Vector3 newUp) {
    up.x = newUp.x;
    up.y = newUp.y;
    up.z = newUp.z;
    // maybe you need to update the camera matrix or you can
    // do this from the projections cameras.
  }

  @override
  updateMatrixWorld([force]) {
    super.updateMatrixWorld(force);
    matrixWorldInverse.copy(matrixWorld).invert();
  }

  @override
  updateWorldMatrix(updateParents, updateChildren) {
    super.updateWorldMatrix(updateParents, updateChildren);
    matrixWorldInverse.copy(matrixWorld).invert();
  }
}
