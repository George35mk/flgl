import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import 'buffer_attribute.dart';
import 'interleaved_buffer.dart';

final _vector = Vector3();

class InterleavedBufferAttribute {
  bool isInterleavedBufferAttribute = true;

  /// Optional name for this attribute instance. Default is an empty string.
  String name = '';

  /// The InterleavedBuffer instance passed in the constructor.
  InterleavedBuffer data;

  /// How many values make up each item.
  int itemSize;

  /// The offset in the underlying array buffer where an item starts.
  int offset;

  /// Default is false.
  bool normalized = false;

  InterleavedBufferAttribute(this.data, this.itemSize, this.offset, [normalized = false]) {
    this.normalized = normalized == true;
  }

  /// The value of data.count. If the buffer is storing a 3-component item (such as a position,
  /// normal, or color), then this will count the number of such items stored.
  int get count {
    return data.count;
  }

  /// The value of data.array.
  get array {
    return data.array;
  }

  /// Default is false. Setting this to true will send the entire interleaved buffer (not just
  /// the specific attribute data) to the GPU again.
  set needsUpdate(bool value) {
    data.needsUpdate = value;
  }

  /// Applies matrix m to every Vector3 element of this InterleavedBufferAttribute.
  applyMatrix4(Matrix4 m) {
    for (var i = 0, l = data.count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyMatrix4(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  /// Applies normal matrix m to every Vector3 element of this InterleavedBufferAttribute.
  applyNormalMatrix(Matrix3 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  /// Applies matrix m to every Vector3 element of this InterleavedBufferAttribute, interpreting
  /// the elements as a direction vectors.
  transformDirection(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  /// Sets the x component of the item at the given index.
  setX(int index, double x) {
    data.array[index * data.stride + offset] = x;

    return this;
  }

  /// Sets the y component of the item at the given index.
  setY(int index, double y) {
    data.array[index * data.stride + offset + 1] = y;

    return this;
  }

  /// Sets the z component of the item at the given index.
  setZ(int index, double z) {
    data.array[index * data.stride + offset + 2] = z;

    return this;
  }

  /// Sets the w component of the item at the given index.
  setW(int index, double w) {
    data.array[index * data.stride + offset + 3] = w;

    return this;
  }

  /// Returns the x component of the item at the given index.
  getX(int index) {
    return data.array[index * data.stride + offset];
  }

  /// Returns the y component of the item at the given index.
  getY(int index) {
    return data.array[index * data.stride + offset + 1];
  }

  /// Returns the z component of the item at the given index.
  getZ(int index) {
    return data.array[index * data.stride + offset + 2];
  }

  /// Returns the w component of the item at the given index.
  getW(int index) {
    return data.array[index * data.stride + offset + 3];
  }

  /// Sets the x and y components of the item at the given index.
  setXY(int index, double x, double y) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;

    return this;
  }

  /// Sets the x, y and z components of the item at the given index.
  setXYZ(int index, double x, double y, double z) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;
    data.array[index + 2] = z;

    return this;
  }

  /// Sets the x, y, z and w components of the item at the given index.
  setXYZW(int index, double x, double y, double z, double w) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;
    data.array[index + 2] = z;
    data.array[index + 3] = w;

    return this;
  }

  clone(data) {
    // if (data == null) {
    //   print(
    //       'THREE.InterleavedBufferAttribute.clone(): Cloning an interlaved buffer attribute will deinterleave buffer data.');

    //   const array = [];

    //   for (var i = 0; i < count; i++) {
    //     final index = i * this.data.stride + offset;

    //     for (var j = 0; j < itemSize; j++) {
    //       array.add(this.data.array[index + j]);
    //     }
    //   }

    //   return BufferAttribute(this.array.constructor(array), itemSize, normalized);
    // } else {
    //   data.interleavedBuffers ??= {};

    //   if (data.interleavedBuffers[this.data.uuid] == null) {
    //     data.interleavedBuffers[this.data.uuid] = this.data.clone(data);
    //   }

    //   return InterleavedBufferAttribute(data.interleavedBuffers[this.data.uuid], itemSize, offset, normalized);
    // }
  }

  toJSON(data) {}
}
