import 'dart:typed_data';

import 'package:flgl_example/bfx/math/color.dart';
import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/math/vector4.dart';

final _vector = Vector3();
final _vector2 = Vector2();
const StaticDrawUsage = 35044;

class BufferAttribute {
  bool isBufferAttribute = true;
  String name = '';
  List array;
  int itemSize;
  bool normalized;
  late int count;
  late int usage;
  Map<String, dynamic> updateRange = {'offset': 0, 'count': -1};
  int version = 0;

  BufferAttribute(this.array, this.itemSize, [this.normalized = false]) {
    count = array.length ~/ itemSize;
    usage = 35044; // gl.STATIC_DRAW

    // name = '';
    // updateRange = {'offset': 0, 'count': -1};
    // version = 0;
  }

  set needsUpdate(value) {
    if (value == true) version++;
  }

  BufferAttribute setUsage(value) {
    usage = value;

    return this;
  }

  BufferAttribute copy(BufferAttribute source) {
    name = source.name;
    // this.array = new source.array.constructor( source.array );
    itemSize = source.itemSize;
    count = source.count;
    normalized = source.normalized;

    usage = source.usage;

    return this;
  }

  BufferAttribute copyAt(index1, attribute, index2) {
    index1 *= itemSize;
    index2 *= attribute.itemSize;

    for (var i = 0, l = itemSize; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  BufferAttribute copyArray(array) {
    /// problem here
    array.set(array);

    return this;
  }

  BufferAttribute copyColorsArray(colors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = colors.length; i < l; i++) {
      var color = colors[i];

      if (color == null) {
        print('THREE.BufferAttribute.copyColorsArray(): color is undefined $i');
        color = Color();
      }

      array[offset++] = color.r;
      array[offset++] = color.g;
      array[offset++] = color.b;
    }

    return this;
  }

  BufferAttribute copyVector2sArray(vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];

      if (vector == null) {
        print('THREE.BufferAttribute.copyVector2sArray(): vector is undefined $i');
        vector = Vector2();
      }

      array[offset++] = vector.x;
      array[offset++] = vector.y;
    }

    return this;
  }

  BufferAttribute copyVector3sArray(vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];

      if (vector == null) {
        print('THREE.BufferAttribute.copyVector3sArray(): vector is undefined $i');
        vector = Vector3();
      }

      array[offset++] = vector.x;
      array[offset++] = vector.y;
      array[offset++] = vector.z;
    }

    return this;
  }

  BufferAttribute copyVector4sArray(vectors) {
    var array = this.array;
    var offset = 0;

    for (var i = 0, l = vectors.length; i < l; i++) {
      var vector = vectors[i];

      if (vector == null) {
        print('THREE.BufferAttribute.copyVector4sArray(): vector is undefined $i');
        vector = Vector4();
      }

      array[offset++] = vector.x;
      array[offset++] = vector.y;
      array[offset++] = vector.z;
      array[offset++] = vector.w;
    }

    return this;
  }

  BufferAttribute applyMatrix3(Matrix3 m) {
    if (itemSize == 2) {
      for (var i = 0, l = count; i < l; i++) {
        _vector2.fromBufferAttribute(this, i);
        _vector2.applyMatrix3(m);

        setXY(i, _vector2.x, _vector2.y);
      }
    } else if (itemSize == 3) {
      for (var i = 0, l = count; i < l; i++) {
        _vector.fromBufferAttribute(this, i);
        _vector.applyMatrix3(m);

        setXYZ(i, _vector.x, _vector.y, _vector.z);
      }
    }

    return this;
  }

  BufferAttribute applyMatrix4(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyMatrix4(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  BufferAttribute applyNormalMatrix(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  transformDirection(m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  set(value, [offset = 0]) {
    // array.set(value, offset);

    return this;
  }

  getX(index) {
    return array[index * itemSize];
  }

  setX(index, x) {
    array[index * itemSize] = x;

    return this;
  }

  getY(index) {
    return array[index * itemSize + 1];
  }

  setY(index, y) {
    array[index * itemSize + 1] = y;

    return this;
  }

  getZ(index) {
    return array[index * itemSize + 2];
  }

  setZ(index, z) {
    array[index * itemSize + 2] = z;

    return this;
  }

  getW(index) {
    return array[index * itemSize + 3];
  }

  setW(index, w) {
    array[index * itemSize + 3] = w;

    return this;
  }

  setXY(index, x, y) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;

    return this;
  }

  setXYZ(index, x, y, z) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;
    array[index + 2] = z;

    return this;
  }

  setXYZW(index, x, y, z, w) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;
    array[index + 2] = z;
    array[index + 3] = w;

    return this;
  }

  // onUploadCallback() {}

  onUpload(callback) {
    // onUploadCallback = callback;

    return this;
  }

  clone() {
    // return new this.constructor( this.array, this.itemSize ).copy( this );
  }

  toJSON() {
    // var data = {
    // 	'itemSize': this.itemSize,
    // 	'type': this.array.constructor.name,
    // 	'array': Array.prototype.slice.call( this.array ),
    // 	'normalized': this.normalized
    // };

    // if ( this.name != '' ) data['name'] = this.name;
    // if ( this.usage != StaticDrawUsage ) data['usage'] = this.usage;
    // if ( this.updateRange['offset'] != 0 || this.updateRange['count'] != - 1 ) data['updateRange'] = this.updateRange;

    // return data;
  }
}

/// inside this class you need to store
/// the Float32List data ex (72)[0.5, 0.5, -0.5, ...]
/// the count ex 24
/// the item size. ex 3
/// looks like the arrayBuffer.

class Int8BufferAttribute extends BufferAttribute {
  Int8BufferAttribute(array, itemSize, [normalized = false]) : super(Int8List.fromList(array), itemSize, normalized);
}

class Uint8BufferAttribute extends BufferAttribute {
  Uint8BufferAttribute(array, itemSize, [normalized = false]) : super(Uint8List.fromList(array), itemSize, normalized);
}

class Uint8ClampedBufferAttribute extends BufferAttribute {
  Uint8ClampedBufferAttribute(array, itemSize, [normalized = false])
      : super(Uint8ClampedList.fromList(array), itemSize, normalized);
}

class Int16BufferAttribute extends BufferAttribute {
  Int16BufferAttribute(array, itemSize, [normalized = false]) : super(Int16List.fromList(array), itemSize, normalized);
}

class Uint16BufferAttribute extends BufferAttribute {
  Uint16BufferAttribute(array, itemSize, [normalized = false])
      : super(Uint16List.fromList(array), itemSize, normalized);
}

class Int32BufferAttribute extends BufferAttribute {
  Int32BufferAttribute(array, itemSize, [normalized = false]) : super(Int32List.fromList(array), itemSize, normalized);
}

class Uint32BufferAttribute extends BufferAttribute {
  Uint32BufferAttribute(array, itemSize, [normalized = false])
      : super(Uint32List.fromList(array), itemSize, normalized);
}

class Float16BufferAttribute extends BufferAttribute {
  Float16BufferAttribute(array, itemSize, [normalized = false])
      : super(Uint16List.fromList(array), itemSize, normalized); // problem
}

class Float32BufferAttribute extends BufferAttribute {
  Float32BufferAttribute(array, itemSize, [normalized = false])
      : super(Float32List.fromList(array), itemSize, normalized);
}

class Float64BufferAttribute extends BufferAttribute {
  Float64BufferAttribute(array, itemSize, [normalized = false])
      : super(Float64List.fromList(array), itemSize, normalized);
}
