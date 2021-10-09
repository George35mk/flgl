import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/core/layers.dart';
import 'package:flgl_example/bfx/math/euler.dart';
import 'package:flgl_example/bfx/math/matrix3.dart';
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

/// The default up direction for objects, also used as the default position for DirectionalLight,
/// HemisphereLight and Spotlight (which creates lights shining from the top down).
/// Set to ( 0, 1, 0 ) by default.
var defaultUp = Vector3(0, 1, 0);

class Object3D {
  /// UUID of this object instance. This gets automatically assigned, so this shouldn't be edited.
  String uuid = '';

  /// readonly – Unique number for this object instance.
  int id = _object3DId++;

  /// Optional name of the object (doesn't need to be unique). Default is an empty string.
  String name = '';
  String type = 'Object3D';

  /// Object's parent in the scene graph. An object can have at most one parent.
  ///
  /// the type is Object3D
  dynamic parent; // null

  /// A list of Object3D children
  List<Object3D> children = [];

  /// This is used by the lookAt method, for example, to determine the orientation of the result.
  /// Default is Object3D.DefaultUp - that is, ( 0, 1, 0 ).
  Vector3 up = defaultUp.clone();

  /// A Vector3 representing the object's local position. Default is (0, 0, 0).
  Vector3 position = Vector3();

  /// Object's local rotation (see Euler angles), in radians.
  Euler rotation = Euler(0, 0, 0);

  /// Object's local rotation as a Quaternion.
  Quaternion quaternion = Quaternion();

  /// The object's local scale. Default is Vector3( 1, 1, 1 ).
  Vector3 scale = Vector3(1, 1, 1);

  /// The local transform matrix.
  Matrix4 matrix = Matrix4();

  /// When this is set, it calculates the matrix of position,
  /// (rotation or quaternion) and scale every frame and also recalculates
  /// the matrixWorld property. Default is Object3D.DefaultMatrixAutoUpdate (true).
  bool matrixAutoUpdate = true;

  /// The global transform of the object. If the Object3D has no parent,
  /// then it's identical to the local transform .matrix.
  Matrix4 matrixWorld = Matrix4();

  /// When this is set, it calculates the matrixWorld in that frame and
  /// resets this property to false. Default is false.
  bool matrixWorldNeedsUpdate = false;

  /// This is passed to the shader and used to calculate the position of the object.
  Matrix4 modelViewMatrix = Matrix4();

  /// This is passed to the shader and used to calculate lighting for the object.
  /// It is the transpose of the inverse of the upper left 3x3 sub-matrix of
  /// this object's modelViewMatrix.
  ///
  /// The reason for this special matrix is that simply using the modelViewMatrix
  /// could result in a non-unit length of normals (on scaling) or in a non-perpendicular
  /// direction (on non-uniform scaling).
  ///
  /// On the other hand the translation part of the modelViewMatrix is not relevant
  /// for the calculation of normals. Thus a Matrix3 is sufficient.
  Matrix3 normalMatrix = Matrix3();

  /// The layer membership of the object. The object is only visible if it
  /// has at least one layer in common with the Camera in use.
  /// This property can also be used to filter out unwanted objects in
  /// ray-intersection tests when using Raycaster.
  Layers layers = Layers();

  /// Object gets rendered if true. Default is true.
  bool visible = true;

  /// Whether the object gets rendered into shadow map. Default is false.
  bool castShadow = false;

  /// Whether the material receives shadows. Default is false.
  bool receiveShadow = false;

  /// When this is set, it checks every frame if the object is in the frustum
  /// of the camera before rendering the object. If set to `false` the object
  /// gets rendered every frame even if it is not in the frustum of the camera.
  /// Default is `true`.
  bool frustumCulled = true;

  /// This value allows the default rendering order of scene graph objects to
  /// be overridden although opaque and transparent objects remain sorted independently.
  ///
  /// When this property is set for an instance of Group, all descendants objects
  /// will be sorted and rendered together. Sorting is from lowest to highest renderOrder.
  /// Default value is 0.
  int renderOrder = 0;

  /// Array with object's animation clips.
  List animations = [];

  /// An object that can be used to store custom data about the Object3D.
  /// It should not hold references to functions as these will not be cloned.
  Map userData = {};

  dynamic isImmediateRenderObject;

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

  onBeforeRender(/* renderer, scene, camera, geometry, material, group */) {}

  onAfterRender(/* renderer, scene, camera, geometry, material, group */) {}

  /// Applies the matrix transform to the object and updates the object's position, rotation and scale.
  applyMatrix4(Matrix4 matrix) {
    if (matrixAutoUpdate) updateMatrix();
    this.matrix.premultiply(matrix);
    this.matrix.decompose(position, quaternion, scale);
  }

  /// Applies the rotation represented by the quaternion to the object.
  applyQuaternion(Quaternion q) {
    quaternion.premultiply(q);
    return this;
  }

  /// Calls setFromAxisAngle( axis, angle ) on the .quaternion.
  ///
  /// - [axis] -- A normalized vector in object space.
  /// - [angle] -- angle in radians
  void setRotationFromAxisAngle(Vector3 axis, double angle) {
    // assumes axis is normalized
    quaternion.setFromAxisAngle(axis, angle);
  }

  /// Calls setRotationFromEuler( euler) on the .quaternion.
  /// - [euler] -- Euler angle specifying rotation amount.
  void setRotationFromEuler(Euler euler) {
    quaternion.setFromEuler(euler, true);
  }

  /// Calls setFromRotationMatrix( m) on the .quaternion.
  ///
  /// Note that this assumes that the upper 3x3 of m is a pure rotation matrix (i.e, unscaled).
  ///
  /// - [m] -- rotate the quaternion by the rotation component of the matrix.
  void setRotationFromMatrix(Matrix4 m) {
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
    quaternion.setFromRotationMatrix(m);
  }

  /// Copy the given quaternion into .quaternion.
  ///
  /// - [q] -- normalized Quaternion.
  setRotationFromQuaternion(Quaternion q) {
    // assumes q is normalized
    quaternion.copy(q);
  }

  /// Rotate an object along an axis in object space. The axis is assumed to be normalized.
  ///
  /// - [axis] -- A normalized vector in object space.
  /// - [angle] -- The angle in radians.
  Object3D rotateOnAxis(Vector3 axis, double angle) {
    // rotate object on axis in object space
    // axis is assumed to be normalized
    _q1.setFromAxisAngle(axis, angle);
    quaternion.multiply(_q1);
    return this;
  }

  /// Rotate an object along an axis in world space. The axis is assumed to be normalized.
  /// Method Assumes no rotated parent.
  ///
  /// - [axis] -- A normalized vector in world space.
  /// - [angle] -- The angle in radians.
  Object3D rotateOnWorldAxis(Vector3 axis, double angle) {
    // rotate object on axis in world space
    // axis is assumed to be normalized
    // method assumes no rotated parent

    _q1.setFromAxisAngle(axis, angle);
    quaternion.premultiply(_q1);

    return this;
  }

  /// Rotates the object around x axis in local space.
  /// - [angle] - the angle to rotate in radians.
  Object3D rotateX(double angle) {
    return rotateOnAxis(_xAxis, angle);
  }

  /// Rotates the object around y axis in local space.
  /// - [angle] - the angle to rotate in radians.
  Object3D rotateY(double angle) {
    return rotateOnAxis(_yAxis, angle);
  }

  /// Rotates the object around z axis in local space.
  /// - [angle] - the angle to rotate in radians.
  Object3D rotateZ(double angle) {
    return rotateOnAxis(_zAxis, angle);
  }

  /// Translate an object by distance along an axis in object space.
  /// The axis is assumed to be normalized.
  ///
  /// - [axis] -- A normalized vector in object space.
  /// - [distance] -- The distance to translate.
  Object3D translateOnAxis(Vector3 axis, double distance) {
    // translate object by distance along axis in object space
    // axis is assumed to be normalized
    _v1.copy(axis).applyQuaternion(quaternion);
    position.add(_v1.multiplyScalar(distance));
    return this;
  }

  /// Translates object along x axis in object space by distance units.
  Object3D translateX(double distance) {
    return translateOnAxis(_xAxis, distance);
  }

  /// Translates object along y axis in object space by distance units.
  Object3D translateY(double distance) {
    return translateOnAxis(_yAxis, distance);
  }

  /// Translates object along z axis in object space by distance units.
  Object3D translateZ(double distance) {
    return translateOnAxis(_zAxis, distance);
  }

  /// Converts the vector from this object's local space to world space.
  ///
  /// - [vector] - A vector representing a position in this object's local space.
  Vector3 localToWorld(Vector3 vector) {
    return vector.applyMatrix4(matrixWorld);
  }

  /// Converts the vector from world space to this object's local space.
  ///
  /// - [vector] - A vector representing a position in world space.
  Vector3 worldToLocal(Vector3 vector) {
    return vector.applyMatrix4(_m1.copy(matrixWorld).invert());
  }

  /// Optionally, the x, y and z components of the world space position.
  /// Rotates the object to face a point in world space.
  /// This method does not support objects having non-uniformly-scaled parent(s).
  /// - [vector] - A vector representing a position in world space.
  ///
  /// - .lookAt ( vector : Vector3 ) : void
  /// - .lookAt ( x : double, y : double, z : double ) : void
  lookAt(dynamic x, [double? y, double? z]) {
    // This method does not support objects having non-uniformly-scaled parent(s)

    if (x.isVector3) {
      _target.copy(x);
    } else {
      _target.set(x, y!, z!);
    }

    Object3D parent = this.parent;

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

  /// Adds object as child of this object. An arbitrary number of objects may
  /// be added. Any current parent on an object passed in here will be removed,
  /// since an object can have at most one parent.
  ///
  /// See Group for info on manually grouping objects.
  Object3D add(Object3D object) {
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

    if (object != null && object is Object3D) {
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

  /// Removes object as child of this object. An arbitrary number of objects may be removed.
  Object3D remove(Object3D object) {
    // if ( arguments.length > 1 ) {
    // 	for ( let i = 0; i < arguments.length; i ++ ) {
    // 		this.remove( arguments[ i ] );
    // 	}
    // 	return this;
    // }

    int index = children.indexOf(object);

    if (index != -1) {
      object.parent = null;
      // children.splice(index, 1);
      children.removeAt(index);

      // object.dispatchEvent(_removedEvent);
    }

    return this;
  }

  /// Removes this object from its current parent.
  Object3D removeFromParent() {
    var parent = this.parent;

    if (parent != null) {
      parent.remove(this);
    }

    return this;
  }

  /// Removes all child objects.
  Object3D clear() {
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

  /// Adds object as a child of this, while maintaining the object's world transform.
  Object3D attach(Object3D object) {
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

  /// Searches through an object and its children, starting with the object
  /// itself, and returns the first with a matching id.
  ///
  /// Note that ids are assigned in chronological order: 1, 2, 3, ...,
  /// incrementing by one for each new object.
  ///
  /// - [id] -- Unique number of the object instance
  Object3D getObjectById(int id) {
    return getObjectByProperty('id', id);
  }

  /// Searches through an object and its children, starting with the object itself,
  /// and returns the first with a matching name.
  ///
  /// Note that for most objects the name is an empty string by default.
  /// You will have to set it manually to make use of this method.
  ///
  /// - [name] -- String to match to the children's Object3D.name property.
  Object3D getObjectByName(String name) {
    return getObjectByProperty('name', name);
  }

  /// Searches through an object and its children, starting with the object itself,
  /// and returns the first with a property that matches the value given.
  ///
  /// - [name] -- the property name to search for.
  /// - [value] -- value of the given property.
  getObjectByProperty(String name, dynamic value) {
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

  /// Returns a vector representing the position of the object in world space.
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 getWorldPosition(Vector3 target) {
    updateWorldMatrix(true, false);

    return target.setFromMatrixPosition(matrixWorld);
  }

  /// Returns a quaternion representing the rotation of the object in world space.
  ///
  /// - [target] — the result will be copied into this Quaternion.
  Quaternion getWorldQuaternion(Quaternion target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, target, _scale);

    return target;
  }

  /// Returns a vector of the scaling factors applied to the object for each axis in world space.
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 getWorldScale(Vector3 target) {
    updateWorldMatrix(true, false);

    matrixWorld.decompose(_position, _quaternion, target);

    return target;
  }

  /// Returns a vector representing the direction of object's positive z-axis in world space.
  ///
  /// - [target] — the result will be copied into this Vector3.
  Vector3 getWorldDirection(Vector3 target) {
    updateWorldMatrix(true, false);

    final e = matrixWorld.elements;

    return target.set(e[8], e[9], e[10]).normalize();
  }

  /// Abstract (empty) method to get intersections between a casted ray and this object.
  /// Subclasses such as Mesh, Line, and Points implement this method in order to use raycasting.
  raycast() {}

  /// Executes the callback on this object and all descendants.
  /// Note: Modifying the scene graph inside the callback is discouraged.
  ///
  /// - [callback] - A function with as first argument an object3D object.
  void traverse(Function callback) {
    callback(this);

    final children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverse(callback);
    }
  }

  /// Like traverse, but the callback will only be executed for visible objects.
  /// Descendants of invisible objects are not traversed.
  ///
  /// Note: Modifying the scene graph inside the callback is discouraged.
  ///
  /// - [callback] - A function with as first argument an object3D object.
  void traverseVisible(Function callback) {
    if (visible == false) return;

    callback(this);

    final children = this.children;

    for (var i = 0, l = children.length; i < l; i++) {
      children[i].traverseVisible(callback);
    }
  }

  /// Executes the callback on all ancestors.
  /// Note: Modifying the scene graph inside the callback is discouraged.
  ///
  /// - [callback] - A function with as first argument an object3D object.
  void traverseAncestors(Function callback) {
    final parent = this.parent as Object3D;

    if (parent != null) {
      callback(parent);

      parent.traverseAncestors(callback);
    }
  }

  /// Updates the local transform.
  void updateMatrix() {
    matrix.compose(position, quaternion, scale);
    matrixWorldNeedsUpdate = true;
  }

  /// Updates the global transform of the object and its descendants.
  void updateMatrixWorld([bool? force]) {
    if (matrixAutoUpdate) updateMatrix();

    if (matrixWorldNeedsUpdate || force!) {
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

  /// Updates the global transform of the object.
  ///
  /// - [updateParents] - recursively updates global transform of ancestors.
  /// - [updateChildren] - recursively updates global transform of descendants.
  void updateWorldMatrix(bool updateParents, bool updateChildren) {
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

  /// Returns a clone of this object and optionally all descendants.
  ///
  /// - [recursive] -- if true, descendants of the object are also cloned. Default is true.
  Object3D clone([bool? recursive]) {
    return Object3D().copy(this, recursive!);
  }

  /// Copy the given object into this object. Note: event listeners and user-defined callbacks
  /// (.onAfterRender and .onBeforeRender) are not copied.
  ///
  /// - [recursive] -- if true, descendants of the object are also copied. Default is true.
  Object3D copy(Object3D source, [bool recursive = true]) {
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
