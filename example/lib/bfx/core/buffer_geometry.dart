import 'dart:typed_data';

import 'buffer_attribute.dart';

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
