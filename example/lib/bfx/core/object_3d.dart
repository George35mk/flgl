import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/math/euler.dart';
import 'package:flgl_example/bfx/math/quaternion.dart';

import '../math/matrix4.dart';
import '../math/vector3.dart';

var _object3DId = 0;

final _v1 = Vector3();
final _q1 = Quaternion();
final _m1 = Matrix4();
final _target = Vector3();

final _position = Vector3();
final _scale = Vector3();
final _quaternion = Quaternion();

final _xAxis = Vector3(1, 0, 0);
final _yAxis = Vector3(0, 1, 0);
final _zAxis = Vector3(0, 0, 1);

var DefaultUp = Vector3(0, 1, 0);

class Object3D {
  /// the object uniqu hash id. c24f3sd2
  int uuid = 0;

  /// The object name
  String name = '';
  String type = 'Object3D';

  /// the parent of this object.
  late Object3D parent; // null

  /// A list of Object3D children
  List<Object3D> children = [];

  Vector3 up = DefaultUp.clone();

  /// The translation vector
  Vector3 position = Vector3();

  /// The rotation vector in radians.
  Euler rotation = Euler(0, 0, 0);

  Quaternion quaternion = Quaternion();

  /// The scale vector
  Vector3 scale = Vector3(1, 1, 1);

  /// The local matrix
  Matrix4 matrix = Matrix4();

  /// The worldMatrix
  Matrix4 matrixWorld = Matrix4();

  bool matrixAutoUpdate = true;
  bool matrixWorldNeedsUpdate = false;

  bool visible = true;
  bool castShadow = false;
  bool receiveShadow = false;
  bool frustumCulled = true;
  int renderOrder = 0;
  List animations = [];
  var userData = {};

  Object3D() {
    rotation.onChange(onRotationChange);
    quaternion.onChange(onQuaternionChange);
  }

  onRotationChange() {
    quaternion.setFromEuler(rotation, false);
  }

  onQuaternionChange() {
    rotation.setFromQuaternion(quaternion, null, false);
  }

  applyMatrix4(Matrix4 matrix) {
    if (matrixAutoUpdate) updateMatrix();
    this.matrix.premultiply(matrix);
    this.matrix.decompose(position, quaternion, scale);
  }

  applyQuaternion(q) {
    quaternion.premultiply(q);
    return this;
  }

  setRotationFromAxisAngle(Vector3 axis, double angle) {
    // assumes axis is normalized
    quaternion.setFromAxisAngle(axis, angle);
  }

  setRotationFromEuler(euler) {
    quaternion.setFromEuler(euler, true);
  }

  setRotationFromMatrix(m) {
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
    quaternion.setFromRotationMatrix(m);
  }

  setRotationFromQuaternion(Quaternion q) {
    // assumes q is normalized
    quaternion.copy(q);
  }

  rotateOnAxis(Vector3 axis, double angle) {
    // rotate object on axis in object space
    // axis is assumed to be normalized
    _q1.setFromAxisAngle(axis, angle);
    quaternion.multiply(_q1);
    return this;
  }

  rotateOnWorldAxis(Vector3 axis, double angle) {
    // rotate object on axis in world space
    // axis is assumed to be normalized
    // method assumes no rotated parent

    _q1.setFromAxisAngle(axis, angle);
    quaternion.premultiply(_q1);

    return this;
  }

  rotateX(double angle) {
    return rotateOnAxis(_xAxis, angle);
  }

  rotateY(double angle) {
    return rotateOnAxis(_yAxis, angle);
  }

  rotateZ(double angle) {
    return rotateOnAxis(_zAxis, angle);
  }

  translateOnAxis(axis, distance) {
    // translate object by distance along axis in object space
    // axis is assumed to be normalized
    _v1.copy(axis).applyQuaternion(quaternion);
    position.add(_v1.multiplyScalar(distance));
    return this;
  }

  translateX(distance) {
    return translateOnAxis(_xAxis, distance);
  }

  translateY(distance) {
    return translateOnAxis(_yAxis, distance);
  }

  translateZ(distance) {
    return translateOnAxis(_zAxis, distance);
  }

  localToWorld(Vector3 vector) {
    return vector.applyMatrix4(matrixWorld);
  }

  worldToLocal(vector) {
    return vector.applyMatrix4(_m1.copy(matrixWorld).invert());
  }

  lookAt(x, y, z) {
    // This method does not support objects having non-uniformly-scaled parent(s)

    if (x.isVector3) {
      _target.copy(x);
    } else {
      _target.set(x, y, z);
    }

    var parent = this.parent;

    updateWorldMatrix(true, false);

    _position.setFromMatrixPosition(matrixWorld);

    if (this is Camera || this is Light) {
      _m1.lookAt(_position, _target, up);
    } else {
      _m1.lookAt(_target, _position, up);
    }

    quaternion.setFromRotationMatrix(_m1);

    if (parent != null) {
      _m1.extractRotation(parent.matrixWorld);
      _q1.setFromRotationMatrix(_m1);
      quaternion.premultiply(_q1.invert());
    }
  }

  Object3D add(object) {
    // if (arguments.length > 1) {
    //   for (var i = 0; i < arguments.length; i++) {
    //     this.add(arguments[i]);
    //   }

    //   return this;
    // }

    if (object == this) {
      print('THREE.Object3D.add: object can\'t be added as a child of itself. $object');
      return this;
    }

    if (object && object is Object3D) {
      if (object.parent != null) {
        object.parent.remove(object);
      }

      object.parent = this;
      children.add(object);

      // object.dispatchEvent(_addedEvent);
    } else {
      print('THREE.Object3D.add: object not an instance of THREE.Object3D. $object');
    }

    return this;
  }

  Object3D remove(object) {
    // if ( arguments.length > 1 ) {

    // 	for ( let i = 0; i < arguments.length; i ++ ) {

    // 		this.remove( arguments[ i ] );

    // 	}

    // 	return this;

    // }

    var index = children.indexOf(object);

    if (index != -1) {
      object.parent = null;
      // children.splice(index, 1);
      children.removeAt(index);

      // object.dispatchEvent(_removedEvent);
    }

    return this;
  }

  Object3D removeFromParent() {
    var parent = this.parent;

    if (parent != null) {
      parent.remove(this);
    }

    return this;
  }

  clear() {
    for (var i = 0; i < children.length; i++) {
      var object = children[i];

      object.parent = null;

      // object.dispatchEvent( _removedEvent );

    }

    children.length = 0;

    // or
    // children.clear();

    return this;
  }

  attach(Object3D object) {
    // adds object as a child of this, while maintaining the object's world transform

    updateWorldMatrix(true, false);

    _m1.copy(matrixWorld).invert();

    if (object.parent != null) {
      object.parent.updateWorldMatrix(true, false);

      _m1.multiply(object.parent.matrixWorld);
    }

    object.applyMatrix4(_m1);

    add(object);

    object.updateWorldMatrix(false, true);

    return this;
  }

  getObjectById(id) {
    return getObjectByProperty('id', id);
  }

  getObjectByName(String name) {
    return getObjectByProperty('name', name);
  }

  getObjectByProperty(name, value) {
    if (this.name == value) return this; // problem

    for (var i = 0, l = children.length; i < l; i++) {
      var child = children[i];
      var object = child.getObjectByProperty(name, value);

      if (object != null) {
        return object;
      }
    }

    return null;
  }

  getWorldPosition(target) {
    updateWorldMatrix(true, false);

    return target.setFromMatrixPosition(matrixWorld);
  }

  getWorldQuaternion(target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, target, _scale);

    return target;
  }

  getWorldScale(target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, _quaternion, target);

    return target;
  }

  getWorldDirection(target) {
    updateWorldMatrix(true, false);

    final e = matrixWorld.elements;

    return target.set(e[8], e[9], e[10]).normalize();
  }

  raycast() {}

  traverse(callback) {
    callback(this);

    final children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverse(callback);
    }
  }

  traverseVisible(callback) {
    if (visible == false) return;

    callback(this);

    final children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverseVisible(callback);
    }
  }

  traverseAncestors(callback) {
    final parent = this.parent;

    if (parent != null) {
      callback(parent);

      parent.traverseAncestors(callback);
    }
  }

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

  Object3D clone([recursive]) {
    return Object3D().copy(this, recursive);
  }

  Object3D copy(Object3D source, [recursive = true]) {
    name = source.name;

    up.copy(source.up);

    position.copy(source.position);
    rotation.order = source.rotation.order;
    quaternion.copy(source.quaternion);
    scale.copy(source.scale);

    matrix.copy(source.matrix);
    matrixWorld.copy(source.matrixWorld);

    matrixAutoUpdate = source.matrixAutoUpdate;
    matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate;

    // layers.mask = source.layers.mask; // create a class
    visible = source.visible;

    castShadow = source.castShadow;
    receiveShadow = source.receiveShadow;

    frustumCulled = source.frustumCulled;
    renderOrder = source.renderOrder;

    // userData = JSON.parse(JSON.stringify(source.userData));

    if (recursive == true) {
      for (var i = 0; i < source.children.length; i++) {
        final child = source.children[i];
        add(child.clone());
      }
    }

    return this;
  }
}

class Light {}
