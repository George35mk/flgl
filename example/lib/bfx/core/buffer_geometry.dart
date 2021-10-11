import 'dart:typed_data';

import 'package:flgl_example/bfx/core/gl_byffer_attribute.dart';
import 'package:flgl_example/bfx/math/box3.dart';
import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/quaternion.dart';
import 'package:flgl_example/bfx/math/sphere.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import 'buffer_attribute.dart';
import 'interleaved_buffer_attribute.dart';
import 'object_3d.dart';
import 'dart:math' as math;

final _m1 = Matrix4();
final _obj = Object3D();
final _offset = Vector3();
final _box = Box3();
final _boxMorphTargets = Box3();
final _vector = Vector3();

var _id = 0;

class BufferGeometry {
  int id = _id++;
  String name = '';
  String type = 'BufferGeometry';

  // List<num> positions = [];
  // List<num> normals = [];
  // List<num> texcoords = [];
  // List<num> indices = [];

  late BufferAttribute index;
  Map<String, BufferAttribute> attributes = {};

  Map<String, BufferAttribute> morphAttributes = {};
  bool morphTargetsRelative = false;

  List<Map<dynamic, dynamic>> groups = [];

  late Box3 boundingBox;
  late Sphere boundingSphere;

  Map<String, dynamic> drawRange = {'start': 0, 'count': double.infinity};

  /// the user data.
  Map<dynamic, dynamic> userData = {};

  BufferGeometry();

  /// Return the maximum number in the array.
  num getMax(List<int> array) {
    var max = array.reduce((value, element) => value > element ? value : element);
    return max;
  }

  /// Return the .index buffer.
  BufferAttribute getIndex() {
    return index;
  }

  /// Set the .index buffer.
  /// - index can be an a normal list or a BufferAttribute;
  BufferGeometry setIndex(dynamic index) {
    if (index is BufferAttribute) {
      this.index = index;
    } else {
      this.index = getMax(index) > 65535 ? Uint32BufferAttribute(index, 1) : Uint16BufferAttribute(index, 1);
    }
    return this;
  }

  /// Returns the attribute with the specified name.
  BufferAttribute getAttribute(String name) {
    // a possible fix is to remove the retyrn type of this method.
    return attributes[name]!; // problem
  }

  /// Sets an attribute to this geometry. Use this rather than the attributes property,
  /// because an internal hashmap of .attributes is maintained to speed up iterating
  /// over attributes.
  BufferGeometry setAttribute(String name, BufferAttribute attribute) {
    attributes[name] = attribute;
    return this;
  }

  /// Deletes the attribute with the specified name.
  deleteAttribute(String name) {
    attributes.remove(name);

    return this;
  }

  /// Returns true if the attribute with the specified name exists.
  bool hasAttribute(String name) {
    return attributes[name] != null;
  }

  /// Adds a group to this geometry; see the groups property for details.
  void addGroup(int start, int count, [int materialIndex = 0]) {
    groups.add({
      'start': start,
      'count': count,
      'materialIndex': materialIndex,
    });
  }

  /// Clears all groups.
  void clearGroups() {
    groups.clear();
  }

  /// Set the .drawRange property. For non-indexed BufferGeometry, count is
  /// the number of vertices to render. For indexed BufferGeometry, count is
  /// the number of indices to render.
  void setDrawRange(int start, int count) {
    drawRange['start'] = start;
    drawRange['count'] = count;
  }

  /// Applies the matrix transform to the geometry.
  BufferGeometry applyMatrix4(Matrix4 matrix) {
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

  /// Applies the rotation represented by the quaternion to the geometry.
  BufferGeometry applyQuaternion(Quaternion q) {
    _m1.makeRotationFromQuaternion(q);

    applyMatrix4(_m1);

    return this;
  }

  /// Rotate the geometry about the X axis. This is typically done as a one time
  /// operation, and not during a loop. Use Object3D.rotation for typical
  /// real-time mesh rotation.
  BufferGeometry rotateX(double angle) {
    // rotate geometry around world x-axis

    _m1.makeRotationX(angle);

    applyMatrix4(_m1);

    return this;
  }

  /// Rotate the geometry about the Y axis. This is typically done as a one time
  /// operation, and not during a loop. Use Object3D.rotation for typical
  /// real-time mesh rotation.
  BufferGeometry rotateY(double angle) {
    // rotate geometry around world y-axis

    _m1.makeRotationY(angle);

    applyMatrix4(_m1);

    return this;
  }

  /// Rotate the geometry about the Z axis. This is typically done as a one time
  /// operation, and not during a loop. Use Object3D.rotation for typical
  /// real-time mesh rotation.
  BufferGeometry rotateZ(double angle) {
    // rotate geometry around world z-axis

    _m1.makeRotationZ(angle);

    applyMatrix4(_m1);

    return this;
  }

  BufferGeometry translate(double x, double y, double z) {
    // translate geometry

    _m1.makeTranslation(x, y, z);

    applyMatrix4(_m1);

    return this;
  }

  /// Scale the geometry data. This is typically done as a one time operation,
  /// and not during a loop. Use Object3D.scale for typical real-time mesh scaling.
  BufferGeometry scale(double x, double y, double z) {
    // scale geometry

    _m1.makeScale(x, y, z);

    applyMatrix4(_m1);

    return this;
  }

  /// Rotates the geometry to face a point in space. This is typically done as a one time
  /// operation, and not during a loop. Use Object3D.lookAt for typical real-time mesh usage.
  ///
  /// - [vector] - A world vector to look at.
  BufferGeometry lookAt(Vector3 vector) {
    _obj.lookAt(vector);
    _obj.updateMatrix();
    applyMatrix4(_obj.matrix);

    return this;
  }

  /// Center the geometry based on the bounding box.
  BufferGeometry center() {
    computeBoundingBox();

    boundingBox.getCenter(_offset).negate();

    translate(_offset.x, _offset.y, _offset.z);

    return this;
  }

  /// Sets the attributes for this BufferGeometry from an array of points.
  BufferGeometry setFromPoints(List points) {
    final position = [];

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

  /// Computes bounding box of the geometry, updating .boundingBox attribute.
  /// Bounding boxes aren't computed by default. They need to be explicitly
  /// computed, otherwise they are null.
  void computeBoundingBox() {
    boundingBox ??= Box3();

    final position = attributes['position'];
    // final morphAttributesPosition = morphAttributes['position'];

    if (position != null && position is GLBufferAttribute) {
      print(
        'THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false". $this',
      );

      boundingBox.set(
        Vector3(double.negativeInfinity, double.negativeInfinity, double.negativeInfinity),
        Vector3(double.infinity, double.infinity, double.infinity),
      );

      return;
    }

    if (position != null) {
      boundingBox.setFromBufferAttribute(position);

      // process morph attributes if present

      // if (morphAttributesPosition != null) {
      //   for (var i = 0, il = morphAttributesPosition.length; i < il; i++) {
      //     final morphAttribute = morphAttributesPosition[i];
      //     _box.setFromBufferAttribute(morphAttribute);

      //     if (morphTargetsRelative) {
      //       _vector.addVectors(boundingBox.min, _box.min);
      //       boundingBox.expandByPoint(_vector);

      //       _vector.addVectors(boundingBox.max, _box.max);
      //       boundingBox.expandByPoint(_vector);
      //     } else {
      //       boundingBox.expandByPoint(_box.min);
      //       boundingBox.expandByPoint(_box.max);
      //     }
      //   }
      // }
    } else {
      boundingBox.makeEmpty();
    }

    if (boundingBox.min.x == null || boundingBox.min.y == null || boundingBox.min.z == null) {
      print(
          'THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values. $this');
    }
  }

  computeBoundingSphere() {
    boundingSphere ??= Sphere();

    final position = attributes['position'];
    // final morphAttributesPosition = morphAttributes['position'];

    if (position != null && position is GLBufferAttribute) {
      print(
          'THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere. Alternatively set "mesh.frustumCulled" to "false". $this');

      boundingSphere.set(Vector3(), double.infinity);

      return;
    }

    if (position != null) {
      // first, find the center of the bounding sphere

      final center = boundingSphere.center;

      _box.setFromBufferAttribute(position);

      // process morph attributes if present

      // if (morphAttributesPosition != null) {
      //   for (var i = 0, il = morphAttributesPosition.length; i < il; i++) {
      //     final morphAttribute = morphAttributesPosition[i];
      //     _boxMorphTargets.setFromBufferAttribute(morphAttribute);

      //     if (morphTargetsRelative) {
      //       _vector.addVectors(_box.min, _boxMorphTargets.min);
      //       _box.expandByPoint(_vector);

      //       _vector.addVectors(_box.max, _boxMorphTargets.max);
      //       _box.expandByPoint(_vector);
      //     } else {
      //       _box.expandByPoint(_boxMorphTargets.min);
      //       _box.expandByPoint(_boxMorphTargets.max);
      //     }
      //   }
      // }

      _box.getCenter(center);

      // second, try to find a boundingSphere with a radius smaller than the
      // boundingSphere of the boundingBox: sqrt(3) smaller in the best case

      double maxRadiusSq = 0;

      for (var i = 0, il = position.count; i < il; i++) {
        _vector.fromBufferAttribute(position, i);

        maxRadiusSq = math.max(maxRadiusSq, center.distanceToSquared(_vector));
      }

      // process morph attributes if present

      // if (morphAttributesPosition != null) {
      //   for (var i = 0, il = morphAttributesPosition.length; i < il; i++) {
      //     final morphAttribute = morphAttributesPosition[i];
      //     final morphTargetsRelative = this.morphTargetsRelative;

      //     for (var j = 0, jl = morphAttribute.count; j < jl; j++) {
      //       _vector.fromBufferAttribute(morphAttribute, j);

      //       if (morphTargetsRelative) {
      //         _offset.fromBufferAttribute(position, j);
      //         _vector.add(_offset);
      //       }

      //       maxRadiusSq = math.max(maxRadiusSq, center.distanceToSquared(_vector));
      //     }
      //   }
      // }

      boundingSphere.radius = math.sqrt(maxRadiusSq);

      if (boundingSphere.radius == null) {
        print(
            'THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values. $this');
      }
    }
  }

  computeTangents() {
    final index = this.index;
    final attributes = this.attributes;

    // based on http://www.terathon.com/code/tangent.html
    // (per vertex tangents)

    if (index == null || attributes['position'] == null || attributes['normal'] == null || attributes['uv'] == null) {
      print(
          'THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)');
      return;
    }

    final indices = index.array;
    final positions = attributes['position']!.array as List<double>;
    final normals = attributes['normal']!.array as List<double>;
    final uvs = attributes['uv']!.array;

    final nVertices = positions.length ~/ 3;

    if (attributes['tangent'] == null) {
      setAttribute('tangent', BufferAttribute(Float32List(4 * nVertices), 4));
    }

    final tangents = attributes['tangent']!.array;

    final tan1 = [], tan2 = [];

    for (var i = 0; i < nVertices; i++) {
      tan1[i] = Vector3();
      tan2[i] = Vector3();
    }

    final vA = Vector3();
    final vB = Vector3();
    final vC = Vector3();

    final uvA = Vector2();
    final uvB = Vector2();
    final uvC = Vector2();

    final sdir = Vector3();
    final tdir = Vector3();

    handleTriangle(a, b, c) {
      vA.fromArray(positions, a * 3);
      vB.fromArray(positions, b * 3);
      vC.fromArray(positions, c * 3);

      uvA.fromArray(uvs, a * 2);
      uvB.fromArray(uvs, b * 2);
      uvC.fromArray(uvs, c * 2);

      vB.sub(vA);
      vC.sub(vA);

      uvB.sub(uvA);
      uvC.sub(uvA);

      final r = 1.0 / (uvB.x * uvC.y - uvC.x * uvB.y);

      // silently ignore degenerate uv triangles having coincident or colinear vertices

      if (!r.isFinite) return; // maybe a problem

      sdir.copy(vB).multiplyScalar(uvC.y).addScaledVector(vC, -uvB.y).multiplyScalar(r);
      tdir.copy(vC).multiplyScalar(uvB.x).addScaledVector(vB, -uvC.x).multiplyScalar(r);

      tan1[a].add(sdir);
      tan1[b].add(sdir);
      tan1[c].add(sdir);

      tan2[a].add(tdir);
      tan2[b].add(tdir);
      tan2[c].add(tdir);
    }

    var groups = this.groups;

    if (groups.isEmpty) {
      groups = [
        {'start': 0, 'count': indices.length}
      ];
    }

    for (var i = 0, il = groups.length; i < il; ++i) {
      final group = groups[i];

      final start = group['start'];
      final count = group['count'];

      for (var j = start, jl = start + count; j < jl; j += 3) {
        handleTriangle(indices[j + 0], indices[j + 1], indices[j + 2]);
      }
    }

    final tmp = Vector3(), tmp2 = Vector3();
    final n = Vector3(), n2 = Vector3();

    handleVertex(v) {
      n.fromArray(normals, v * 3);
      n2.copy(n);

      final t = tan1[v];

      // Gram-Schmidt orthogonalize

      tmp.copy(t);
      tmp.sub(n.multiplyScalar(n.dot(t))).normalize();

      // Calculate handedness

      tmp2.crossVectors(n2, t);
      final test = tmp2.dot(tan2[v]);
      final w = (test < 0.0) ? -1.0 : 1.0;

      tangents[v * 4] = tmp.x;
      tangents[v * 4 + 1] = tmp.y;
      tangents[v * 4 + 2] = tmp.z;
      tangents[v * 4 + 3] = w;
    }

    for (var i = 0, il = groups.length; i < il; ++i) {
      final group = groups[i];

      final start = group['start'];
      final count = group['count'];

      for (var j = start, jl = start + count; j < jl; j += 3) {
        handleVertex(indices[j + 0]);
        handleVertex(indices[j + 1]);
        handleVertex(indices[j + 2]);
      }
    }
  }

  computeVertexNormals() {
    final index = this.index;
    final positionAttribute = getAttribute('position');

    if (positionAttribute != null) {
      var normalAttribute = getAttribute('normal');

      if (normalAttribute == null) {
        normalAttribute = BufferAttribute(Float32List(positionAttribute.count * 3), 3);
        setAttribute('normal', normalAttribute);
      } else {
        // reset existing normals to zero

        for (var i = 0, il = normalAttribute.count; i < il; i++) {
          normalAttribute.setXYZ(i, 0, 0, 0);
        }
      }

      final pA = Vector3(), pB = Vector3(), pC = Vector3();
      final nA = Vector3(), nB = Vector3(), nC = Vector3();
      final cb = Vector3(), ab = Vector3();

      // indexed elements

      if (index != null) {
        for (var i = 0, il = index.count; i < il; i += 3) {
          final vA = index.getX(i + 0);
          final vB = index.getX(i + 1);
          final vC = index.getX(i + 2);

          pA.fromBufferAttribute(positionAttribute, vA);
          pB.fromBufferAttribute(positionAttribute, vB);
          pC.fromBufferAttribute(positionAttribute, vC);

          cb.subVectors(pC, pB);
          ab.subVectors(pA, pB);
          cb.cross(ab);

          nA.fromBufferAttribute(normalAttribute, vA);
          nB.fromBufferAttribute(normalAttribute, vB);
          nC.fromBufferAttribute(normalAttribute, vC);

          nA.add(cb);
          nB.add(cb);
          nC.add(cb);

          normalAttribute.setXYZ(vA, nA.x, nA.y, nA.z);
          normalAttribute.setXYZ(vB, nB.x, nB.y, nB.z);
          normalAttribute.setXYZ(vC, nC.x, nC.y, nC.z);
        }
      } else {
        // non-indexed elements (unconnected triangle soup)

        for (var i = 0, il = positionAttribute.count; i < il; i += 3) {
          pA.fromBufferAttribute(positionAttribute, i + 0);
          pB.fromBufferAttribute(positionAttribute, i + 1);
          pC.fromBufferAttribute(positionAttribute, i + 2);

          cb.subVectors(pC, pB);
          ab.subVectors(pA, pB);
          cb.cross(ab);

          normalAttribute.setXYZ(i + 0, cb.x, cb.y, cb.z);
          normalAttribute.setXYZ(i + 1, cb.x, cb.y, cb.z);
          normalAttribute.setXYZ(i + 2, cb.x, cb.y, cb.z);
        }
      }

      normalizeNormals();

      normalAttribute.needsUpdate = true;
    }
  }

  merge(BufferGeometry geometry, [int offset = 0]) {
    if (geometry is! BufferGeometry) {
      print('THREE.BufferGeometry.merge(): geometry not an instance of THREE.BufferGeometry. $geometry');
      return;
    }

    if (offset == null) {
      offset = 0;

      print('THREE.BufferGeometry.merge(): Overwriting original geometry, starting at offset=0. ' +
          'Use BufferGeometryUtils.mergeBufferGeometries() for lossless merge.');
    }

    final attributes = this.attributes;

    attributes.forEach((key, value) {
      if (geometry.attributes[key] == null) ;

      final attribute1 = attributes[key];
      final attributeArray1 = attribute1!.array;

      final attribute2 = geometry.attributes[key];
      final attributeArray2 = attribute2!.array;

      final int attributeOffset = attribute2.itemSize * offset;
      final int length = math.min(attributeArray2.length, attributeArray1.length - attributeOffset);

      for (var i = 0, j = attributeOffset; i < length; i++, j++) {
        attributeArray1[j] = attributeArray2[i];
      }
    });

    return this;
  }

  normalizeNormals() {
    final normals = attributes['normal'];

    for (var i = 0, il = normals!.count; i < il; i++) {
      _vector.fromBufferAttribute(normals, i);

      _vector.normalize();

      normals.setXYZ(i, _vector.x, _vector.y, _vector.z);
    }
  }

  // toNonIndexed() {
  //   convertBufferAttribute(BufferAttribute attribute, List<dynamic> indices) {
  //     final array = attribute.array;
  //     final itemSize = attribute.itemSize;
  //     final normalized = attribute.normalized;

  //     // find what array is and assign
  //     final array2 = array.constructor(indices.length * itemSize);

  //     var index = 0, index2 = 0;

  //     for (var i = 0, l = indices.length; i < l; i++) {
  //       if (attribute is InterleavedBufferAttribute) {
  //         index = indices[i] * attribute.data.stride + attribute.offset;
  //       } else {
  //         index = indices[i] * itemSize;
  //       }

  //       for (var j = 0; j < itemSize; j++) {
  //         array2[index2++] = array[index++];
  //       }
  //     }

  //     return BufferAttribute(array2, itemSize, normalized);
  //   }

  //   //

  //   if (index == null) {
  //     print('THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed.');
  //     return this;
  //   }

  //   final geometry2 = BufferGeometry();

  //   final indices = index.array;
  //   final attributes = this.attributes;

  //   // attributes
  //   attributes.forEach((name, attribute) {
  //     final newAttribute = convertBufferAttribute(attribute, indices);
  //     geometry2.setAttribute(name, newAttribute);
  //   });

  //   // morph attributes

  //   // final morphAttributes = this.morphAttributes;

  //   // morphAttributes.forEach((name, value) {
  //   //   final morphArray = [];
  //   //   final morphAttribute = morphAttributes[name]; // morphAttribute: array of Float32BufferAttributes

  //   //   for (var i = 0, il = morphAttribute.length; i < il; i++) {
  //   //     final attribute = morphAttribute[i];

  //   //     final newAttribute = convertBufferAttribute(attribute, indices);

  //   //     morphArray.add(newAttribute);
  //   //   }

  //   //   geometry2.morphAttributes[name] = morphArray;
  //   // });

  //   geometry2.morphTargetsRelative = morphTargetsRelative;

  //   // groups
  //   final groups = this.groups;

  //   for (var i = 0, l = groups.length; i < l; i++) {
  //     final group = groups[i];
  //     geometry2.addGroup(group['start'], group['count'], group['materialIndex']);
  //   }

  //   return geometry2;
  // }

  toJSON() {}

  BufferGeometry clone() {
    return BufferGeometry().copy(this);
  }

  BufferGeometry copy(BufferGeometry source) {
    // reset

    this.index = null as dynamic; // problem
    this.attributes = {};
    this.morphAttributes = {};
    this.groups = [];
    this.boundingBox = null as dynamic; // problem
    this.boundingSphere = null as dynamic; // problem

    // used for storing cloned, shared data

    final data = {};

    // name

    name = source.name;

    // index

    final index = source.index;

    if (index != null) {
      // setIndex(index.clone(data));
      setIndex(index.clone());
    }

    // attributes

    final attributes = source.attributes;

    attributes.forEach((name, attribute) {
      // final attribute = attributes[name];
      setAttribute(name, attribute.clone());
    });

    // for (final name in attributes) {
    //   final attribute = attributes[name];
    //   setAttribute(name, attribute!.clone());
    // }

    // morph attributes

    // final morphAttributes = source.morphAttributes;

    // morphAttributes.forEach((name, value) {
    //   final array = [];
    //   final morphAttribute = morphAttributes[name]; // morphAttribute: array of Float32BufferAttributes

    //   for (var i = 0, l = morphAttribute.length; i < l; i++) {
    //     array.add(morphAttribute![i].clone(data));
    //   }

    //   this.morphAttributes[name] = array;
    // });

    morphTargetsRelative = source.morphTargetsRelative;

    // groups

    final groups = source.groups;

    for (var i = 0, l = groups.length; i < l; i++) {
      final group = groups[i];
      addGroup(group['start'], group['count'], group['materialIndex']);
    }

    // bounding box

    final boundingBox = source.boundingBox;

    if (boundingBox != null) {
      this.boundingBox = boundingBox.clone();
    }

    // bounding sphere

    final boundingSphere = source.boundingSphere;

    if (boundingSphere != null) {
      this.boundingSphere = boundingSphere.clone();
    }

    // draw range

    drawRange['start'] = source.drawRange['start'];
    drawRange['count'] = source.drawRange['count'];

    // user data

    userData = source.userData;

    // geometry generator parameters

    // check this line
    // if (source.parameters != null) this.parameters = Object.assign({}, source.parameters);

    return this;
  }

  dispose() {
    // this.dispatchEvent({type: 'dispose'});
  }
}
