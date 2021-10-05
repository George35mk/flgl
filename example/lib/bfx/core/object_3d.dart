import 'package:flgl_example/bfx/quaternion.dart';

import '../math/matrix4.dart';
import '../math/vector_3.dart';

class Object3D {
  /// the object uniqu hash id. c24f3sd2
  int id = 0;

  /// The object name
  String name = '';
  String type = 'Object3D';

  /// The translation vector
  Vector3 position = Vector3(0, 0, 0);

  /// The rotation vector in radians.
  Vector3 rotation = Vector3(0, 0, 0);

  Quaternion quaternion = Quaternion(0, 0, 0, 0);

  /// The scale vector
  Vector3 scale = Vector3(1, 1, 1);

  /// the parent of this object.
  late Object3D parent;

  /// A list of Object3D children
  List<Object3D> children = [];

  /// The local matrix
  Matrix4 matrix = Matrix4();

  /// The worldMatrix
  Matrix4 matrixWorld = Matrix4();

  bool matrixAutoUpdate = true;
  bool matrixWorldNeedsUpdate = false;

  Object3D();

  // Matrix4 getMatrix() {
  //   Matrix4 m = Matrix4().identity();

  //   var t = translation;
  //   var r = rotation;
  //   var s = scale;

  //   m = M4.translate(m, t.x, t.y, t.z);
  //   m = M4.xRotate(m, r.x);
  //   m = M4.yRotate(m, r.y);
  //   m = M4.zRotate(m, r.z);
  //   m = M4.scale(m, s.x, s.y, s.z);

  //   return m;
  // }

  add(Object3D child) {
    children.add(child);
  }

  // updateWorldMatrix([parentWorldMatrix]) {
  //   matrix = getMatrix();

  //   if (parentWorldMatrix != null) {
  //     // a matrix was passed in so do the math
  //     M4.multiply(parentWorldMatrix, matrix, this.matrixWorld);
  //   } else {
  //     // no matrix was passed in so just copy local to world
  //     M4.copy(matrix, this.matrixWorld);
  //   }

  //   // now process all the children
  //   var worldMatrix = this.matrixWorld;
  //   for (var child in children) {
  //     child.updateWorldMatrix(worldMatrix);
  //   }
  // }

  updateMatrix() {
    matrix.compose(position, quaternion, scale);
    matrixWorldNeedsUpdate = true;
  }

  updateMatrixWorld([force]) {
    if (matrixAutoUpdate) updateMatrix();

    if (matrixWorldNeedsUpdate || force) {
      if (parent == null) {
        matrixWorld.copy(matrix);
      } else {
        matrixWorld.multiplyMatrices(parent.matrixWorld, matrix);
      }
      matrixWorldNeedsUpdate = false;
      force = true;
    }

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].updateMatrixWorld(force);
    }
  }

  updateWorldMatrix(updateParents, updateChildren) {
    if (updateParents == true && parent != null) {
      parent.updateWorldMatrix(true, false);
    }

    if (matrixAutoUpdate) updateMatrix();

    if (parent == null) {
      matrixWorld.copy(matrix);
    } else {
      matrixWorld.multiplyMatrices(parent.matrixWorld, matrix);
    } // update children

    if (updateChildren == true) {
      for (var i = 0, l = children.length; i < l; i++) {
        children[i].updateWorldMatrix(false, true);
      }
    }
  }
}
