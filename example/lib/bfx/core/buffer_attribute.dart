import 'dart:typed_data';

import 'package:flgl_example/bfx/constants.dart';
import 'package:flgl_example/bfx/math/color.dart';
import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/math/vector4.dart';

final _vector = Vector3();
final _vector2 = Vector2();
const staticDrawUsage = 35044;

class BufferAttribute {
  bool isBufferAttribute = true;
  String name = '';

  /// this array is typed array
  // Float32List array;
  dynamic array;
  int itemSize;
  int count = 0;
  bool normalized;
  int usage = StaticDrawUsage;
  Map<String, dynamic> updateRange = {'offset': 0, 'count': -1};
  int version = 0;

  BufferAttribute(this.array, this.itemSize, [this.normalized = false]) {
    count = array.length ~/ itemSize;
    usage = 35044; // gl.STATIC_DRAW
  }

  /// Flag to indicate that this attribute has changed and should be re-sent to the GPU.
  /// Set this to true when you modify the value of the array.
  ///
  /// Setting this to true also increments the version.
  set needsUpdate(bool value) {
    if (value == true) version++;
  }

  /// Set usage to value. See usage constants for all possible input values.
  BufferAttribute setUsage(value) {
    usage = value;

    return this;
  }

  BufferAttribute copy(BufferAttribute source) {
    name = source.name;
    // this.array = new source.array.constructor( source.array );
    if (source.array is Float32List) {
      array = Float32List.fromList(source.array);
    }
    itemSize = source.itemSize;
    count = source.count;
    normalized = source.normalized;

    usage = source.usage;

    return this;
  }

  /// Copy a vector from bufferAttribute[index2] to array[index1].
  BufferAttribute copyAt(int index1, BufferAttribute attribute, int index2) {
    index1 *= itemSize;
    index2 *= attribute.itemSize;

    for (var i = 0, l = itemSize; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  /// Copy the array given here (which can be a normal array or TypedArray) into array.
  BufferAttribute copyArray(array) {
    /// problem here
    array.set(array);

    return this;
  }

  /// Copy an array representing RGB color values into array.
  BufferAttribute copyColorsArray(List colors) {
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

  /// Copy an array representing Vector2s into array.
  BufferAttribute copyVector2sArray(List<Vector2> vectors) {
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

  /// Copy an array representing Vector3s into array.
  BufferAttribute copyVector3sArray(List<Vector3> vectors) {
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

  /// Copy an array representing Vector4s into array.
  BufferAttribute copyVector4sArray(List<Vector4> vectors) {
    final array = this.array;
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

  /// Applies matrix m to every Vector3 element of this BufferAttribute.
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

  /// Applies matrix m to every Vector3 element of this BufferAttribute.
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

  /// Applies normal matrix m to every Vector3 element of this BufferAttribute.
  BufferAttribute applyNormalMatrix(Matrix3 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.applyNormalMatrix(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  /// Applies matrix m to every Vector3 element of this BufferAttribute,
  /// interpreting the elements as a direction vectors.
  BufferAttribute transformDirection(Matrix4 m) {
    for (var i = 0, l = count; i < l; i++) {
      _vector.x = getX(i);
      _vector.y = getY(i);
      _vector.z = getZ(i);

      _vector.transformDirection(m);

      setXYZ(i, _vector.x, _vector.y, _vector.z);
    }

    return this;
  }

  /// Calls TypedArray.set( value, offset ) on the array.
  /// In particular, see that page for requirements on value being a TypedArray.
  ///
  /// - [value] -- an Array or TypedArray from which to copy values.
  /// - [offset] -- (optional) index of the array at which to start copying.
  /// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray/set
  set(List value, [int offset = 0]) {
    // array.set(value, offset); // problem here

    return this;
  }

  /// Returns the x component of the vector at the given index.
  getX(int index) {
    return array[index * itemSize];
  }

  /// Sets the x component of the vector at the given index.
  BufferAttribute setX(int index, double x) {
    array[index * itemSize] = x;

    return this;
  }

  /// Returns the y component of the vector at the given index.
  getY(int index) {
    return array[index * itemSize + 1];
  }

  /// Sets the y component of the vector at the given index.
  BufferAttribute setY(int index, double y) {
    array[index * itemSize + 1] = y;

    return this;
  }

  /// Returns the z component of the vector at the given index
  getZ(int index) {
    return array[index * itemSize + 2];
  }

  /// Sets the z component of the vector at the given index.
  BufferAttribute setZ(int index, double z) {
    array[index * itemSize + 2] = z;

    return this;
  }

  /// Returns the w component of the vector at the given index.
  getW(int index) {
    return array[index * itemSize + 3];
  }

  /// Sets the w component of the vector at the given index.
  BufferAttribute setW(int index, double w) {
    array[index * itemSize + 3] = w;

    return this;
  }

  /// Sets the x and y components of the vector at the given index.
  BufferAttribute setXY(int index, double x, double y) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;

    return this;
  }

  /// Sets the x, y and z components of the vector at the given index.
  BufferAttribute setXYZ(int index, double x, double y, double z) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;
    array[index + 2] = z;

    return this;
  }

  /// Sets the x, y, z and w components of the vector at the given index.
  BufferAttribute setXYZW(int index, double x, double y, double z, double w) {
    index *= itemSize;

    array[index + 0] = x;
    array[index + 1] = y;
    array[index + 2] = z;
    array[index + 3] = w;

    return this;
  }

  onUploadCallback() {}

  /// Sets the value of the onUploadCallback property.
  /// In the WebGL / Buffergeometry this is used to free memory after the buffer has been transferred to the GPU.
  onUpload(Function callback) {
    // onUploadCallback = callback;

    return this;
  }

  /// Return a copy of this bufferAttribute.
  BufferAttribute clone() {
    return BufferAttribute(array, itemSize).copy(this);
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
