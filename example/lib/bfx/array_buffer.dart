import 'dart:typed_data';

class ArrayBuffer {
  /// The number of [components].
  int numComponents = 0;

  /// The number of vertices.
  int numVertices = 0;

  /// The list type
  /// Supported types are:
  /// - Float32
  /// - Uint16
  /// - Uint8
  String type = '';

  /// The Array buffer data list.
  dynamic data;
  int cursor = 0;

  ArrayBuffer(this.numComponents, this.numVertices, this.type) {
    if (type == 'Float32') {
      data = Float32List(numComponents * numVertices);
    } else if (type == 'Uint16') {
      data = Uint16List(numComponents * numVertices);
    } else if (type == 'Uint8') {
      data = Uint8List(numComponents * numVertices);
    } else {
      throw 'Unsupported list type';
    }
  }

  /// Returns the number of elements.
  get numElements {
    return (data.length ~/ numComponents).toInt() | 0;
  }

  push(List<num> args) {
    for (var i = 0; i < args.length; i++) {
      var value = args[i];
      data[cursor++] = value;
    }
  }
}
