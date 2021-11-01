import 'dart:typed_data';

// Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
// var size = 2;          // 2 components per iteration
// var type = gl.FLOAT;   // the data is 32bit floats
// var normalize = false; // don't normalize the data
// var stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
// var offset = 0;        // start at the beginning of the buffer
// gl.vertexAttribPointer(positionAttributeLocation, size, type, normalize, stride, offset);

class BufferAttribute {
  /// The array  is typed array it can be :
  /// - Float64List
  /// - Float32List
  /// - Int32List
  /// - Uint32List
  /// - Int16List
  /// - Uint16List
  /// - Uint8ClampedList
  /// - Uint8List
  /// - Int8List
  ///
  /// and can be the object positions, colors, normals or uvs or indices
  TypedData array;

  /// 1,2 or 3 components per iteration
  int itemSize;
  bool normalized;

  /// the number of elements in the array.
  /// how is computed: array.length / numbe of components.
  int count = 0;

  /// gl.STATIC_DRAW
  int usage = 35044;

  BufferAttribute(this.array, this.itemSize, [this.normalized = false]) {
    // count = array.length ~/ itemSize;
    count = (array.lengthInBytes / array.elementSizeInBytes) ~/ itemSize;
    usage = 35044; // gl.STATIC_DRAW
  }
}

class Int8BufferAttribute extends BufferAttribute {
  Int8BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Int8List.fromList(array), itemSize, normalized);
}

class Uint8BufferAttribute extends BufferAttribute {
  Uint8BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Uint8List.fromList(array), itemSize, normalized);
}

class Uint8ClampedBufferAttribute extends BufferAttribute {
  Uint8ClampedBufferAttribute(array, itemSize, [bool normalized = false])
      : super(Uint8ClampedList.fromList(array), itemSize, normalized);
}

class Int16BufferAttribute extends BufferAttribute {
  Int16BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Int16List.fromList(array), itemSize, normalized);
}

class Uint16BufferAttribute extends BufferAttribute {
  Uint16BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Uint16List.fromList(array), itemSize, normalized);
}

class Int32BufferAttribute extends BufferAttribute {
  Int32BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Int32List.fromList(array), itemSize, normalized);
}

class Uint32BufferAttribute extends BufferAttribute {
  Uint32BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Uint32List.fromList(array), itemSize, normalized);
}

class Float16BufferAttribute extends BufferAttribute {
  Float16BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Uint16List.fromList(array), itemSize, normalized); // problem
}

class Float32BufferAttribute extends BufferAttribute {
  Float32BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Float32List.fromList(array), itemSize, normalized);
}

class Float64BufferAttribute extends BufferAttribute {
  Float64BufferAttribute(array, itemSize, [bool normalized = false])
      : super(Float64List.fromList(array), itemSize, normalized);
}
