import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/quaternion.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import 'buffer_attribute.dart';
import 'object_3d.dart';

final _m1 = Matrix4();
final _obj = Object3D();
final _offset = Vector3();
final _box = Box3();
final _boxMorphTargets = Box3();
final _vector = Vector3();

class Box3 {
  Box3();
}

class BufferGeometry {
  String type = 'BufferGeometry';

  // List<num> positions = [];
  // List<num> normals = [];
  // List<num> texcoords = [];
  // List<num> indices = [];

  Map<String, BufferAttribute> attributes = {};
  List<Map<dynamic, dynamic>> groups = [];
  Map<String, dynamic> drawRange = {'start': 0, 'count': double.infinity};
  dynamic boundingBox;
  dynamic boundingSphere;

  BufferGeometry();

  late BufferAttribute index;

  /// Return the maximum number in the array.
  num getMax(List<int> array) {
    var max = array.reduce((value, element) => value > element ? value : element);
    return max;
  }

  getIndex() {
    return index;
  }

  setIndex(List<int> index) {
    this.index = getMax(index) > 65535 ? Uint32BufferAttribute(index, 1) : Uint16BufferAttribute(index, 1);
  }

  getAttribute(String name) {
    return attributes[name];
  }

  setAttribute(String name, Float32BufferAttribute attribute) {
    attributes[name] = attribute;
    return this;
  }

  deleteAttribute(String name) {
    attributes.remove(name);

    return this;
  }

  hasAttribute(String name) {
    return attributes[name] != null;
  }

  addGroup(int start, int count, [materialIndex = 0]) {
    groups.add({
      'start': start,
      'count': count,
      'materialIndex': materialIndex,
    });
  }

  clearGroups() {
    groups.clear();
  }

  setDrawRange(start, count) {
    drawRange['start'] = start;
    drawRange['count'] = count;
  }

  applyMatrix4(Matrix4 matrix) {
    var position = attributes['position'];

    if (position != null) {
      position.applyMatrix4(matrix);

      position.needsUpdate = true;
    }

    var normal = attributes['normal'];

    if (normal != null) {
      var normalMatrix = Matrix3().getNormalMatrix(matrix);

      normal.applyNormalMatrix(normalMatrix);

      normal.needsUpdate = true;
    }

    var tangent = attributes['tangent'];

    if (tangent != null) {
      tangent.transformDirection(matrix);

      tangent.needsUpdate = true;
    }

    if (boundingBox != null) {
      computeBoundingBox();
    }

    if (boundingSphere != null) {
      computeBoundingSphere();
    }

    return this;
  }

  applyQuaternion(Quaternion q) {
    _m1.makeRotationFromQuaternion(q);

    applyMatrix4(_m1);

    return this;
  }

  rotateX(angle) {
    // rotate geometry around world x-axis

    _m1.makeRotationX(angle);

    applyMatrix4(_m1);

    return this;
  }

  rotateY(angle) {
    // rotate geometry around world y-axis

    _m1.makeRotationY(angle);

    applyMatrix4(_m1);

    return this;
  }

  rotateZ(angle) {
    // rotate geometry around world z-axis

    _m1.makeRotationZ(angle);

    applyMatrix4(_m1);

    return this;
  }

  translate(x, y, z) {
    // translate geometry

    _m1.makeTranslation(x, y, z);

    applyMatrix4(_m1);

    return this;
  }

  scale(x, y, z) {
    // scale geometry

    _m1.makeScale(x, y, z);

    applyMatrix4(_m1);

    return this;
  }

  lookAt(vector) {
    _obj.lookAt(vector);

    _obj.updateMatrix();

    applyMatrix4(_obj.matrix);

    return this;
  }

  center() {
    computeBoundingBox();

    boundingBox.getCenter(_offset).negate();

    translate(_offset.x, _offset.y, _offset.z);

    return this;
  }

  setFromPoints(List points) {
    const position = [];

    for (var i = 0, l = points.length; i < l; i++) {
      final point = points[i];
      // position.push(point.x, point.y, point.z || 0);
      position.add(point.x);
      position.add(point.y);
      position.add(point.z ?? 0);
    }

    setAttribute('position', Float32BufferAttribute(position, 3));

    return this;
  }
}
