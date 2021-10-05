import 'dart:typed_data';

class BufferGeometry {
  String type = 'BufferGeometry';

  List<num> positions = [];
  List<num> normals = [];
  List<num> texcoords = [];
  List<num> indices = [];

  Map<String, BufferAttribute> attributes = {};
  List<Map<dynamic, dynamic>> groups = [];

  BufferGeometry();

  late BufferAttribute index;

  /// Return the maximum number in the array.
  num getMax(List<int> array) {
    var max = array.reduce((value, element) => value > element ? value : element);
    // var largestGeekValue = geekList.reduce((current, next) => current > next ? current : next);
    return max;
  }

  setIndex(List<int> index) {
    this.index = getMax(index) > 65535 ? Uint32BufferAttribute(index, 1) : Uint16BufferAttribute(index, 1);
  }

  getAttribute(String name) {
    return attributes[name];
  }

  setAttribute(String name, Float32BufferAttribute attribute) {
    attributes[name] = attribute;
    // return this;
  }

  addGroup(int start, int count, [materialIndex = 0]) {
    groups.add({
      'start': start,
      'count': count,
      'materialIndex': materialIndex,
    });
  }
}

class BufferAttribute {
  List array;
  int itemSize;
  bool normalized;
  late int count;
  late int usage;

  BufferAttribute(this.array, this.itemSize, [this.normalized = false]) {
    count = array.length ~/ itemSize;
    usage = 35044; // gl.STATIC_DRAW
  }
}

/// inside this class you need to store
/// the Float32List data ex (72)[0.5, 0.5, -0.5, ...]
/// the count ex 24
/// the item size. ex 3
/// looks like the arrayBuffer.
class Float32BufferAttribute extends BufferAttribute {
  Float32BufferAttribute(array, itemSize, [normalized = false])
      : super(Float32List.fromList(array), itemSize, normalized);
}

class Uint32BufferAttribute extends BufferAttribute {
  Uint32BufferAttribute(array, itemSize, [normalized = false])
      : super(Uint32List.fromList(array), itemSize, normalized);
}

class Uint16BufferAttribute extends BufferAttribute {
  Uint16BufferAttribute(array, itemSize, [normalized = false])
      : super(Uint16List.fromList(array), itemSize, normalized);
}
