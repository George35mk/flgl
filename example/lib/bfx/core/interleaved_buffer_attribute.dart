import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector3.dart';

import 'buffer_attribute.dart';
import 'interleaved_buffer.dart';

final _vector = Vector3();

class InterleavedBufferAttribute {
  bool isInterleavedBufferAttribute = true;

  String name = '';
  InterleavedBuffer data;
  dynamic itemSize;
  int offset;
  bool normalized = false;

  InterleavedBufferAttribute(this.data, this.itemSize, this.offset, [normalized = false]) {
    this.normalized = normalized == true;
  }

  get count {
    return data.count;
  }

  get array {
    return data.array;
  }

  set needsUpdate(value) {
    data.needsUpdate = value;
  }

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

  applyNormalMatrix(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = this.getX(i);
      _vector.y = this.getY(i);
      _vector.z = this.getZ(i);

      _vector.applyNormalMatrix(m);

      this.setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  transformDirection(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = this.getX(i);
      _vector.y = this.getY(i);
      _vector.z = this.getZ(i);

      _vector.transformDirection(m);

      this.setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  setX(index, x) {
    data.array[index * data.stride + offset] = x;

    return this;
  }

  setY(index, y) {
    data.array[index * data.stride + offset + 1] = y;

    return this;
  }

  setZ(index, z) {
    data.array[index * data.stride + offset + 2] = z;

    return this;
  }

  setW(index, w) {
    data.array[index * data.stride + offset + 3] = w;

    return this;
  }

  getX(index) {
    return data.array[index * data.stride + offset];
  }

  getY(index) {
    return data.array[index * data.stride + offset + 1];
  }

  getZ(index) {
    return data.array[index * data.stride + offset + 2];
  }

  getW(index) {
    return data.array[index * data.stride + offset + 3];
  }

  setXY(index, x, y) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;

    return this;
  }

  setXYZ(index, x, y, z) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;
    data.array[index + 2] = z;

    return this;
  }

  setXYZW(index, x, y, z, w) {
    index = index * data.stride + offset;

    data.array[index + 0] = x;
    data.array[index + 1] = y;
    data.array[index + 2] = z;
    data.array[index + 3] = w;

    return this;
  }

  clone(data) {
    if (data == null) {
      print(
          'THREE.InterleavedBufferAttribute.clone(): Cloning an interlaved buffer attribute will deinterleave buffer data.');

      const array = [];

      for (var i = 0; i < count; i++) {
        final index = i * this.data.stride + offset;

        for (var j = 0; j < itemSize; j++) {
          array.add(this.data.array[index + j]);
        }
      }

      return BufferAttribute(this.array.constructor(array), itemSize, normalized);
    } else {
      data.interleavedBuffers ??= {};

      if (data.interleavedBuffers[this.data.uuid] == null) {
        data.interleavedBuffers[this.data.uuid] = this.data.clone(data);
      }

      return InterleavedBufferAttribute(data.interleavedBuffers[this.data.uuid], itemSize, offset, normalized);
    }
  }

  toJSON(data) {}
}
