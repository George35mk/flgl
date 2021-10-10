import 'dart:typed_data';

import 'package:flgl_example/bfx/math/math_utils.dart';

import '../constants.dart';

class InterleavedBuffer {
  bool isInterleavedBuffer = true;
  Float32List array;
  int stride;
  dynamic count;
  dynamic usage;

  /// Object containing offset and count.
  Map<String, dynamic> updateRange = {'offset': 0, 'count': -1};

  /// A version number, incremented every time the needsUpdate property is set to true.
  dynamic version;

  /// UUID of this instance. This gets automatically assigned, so this shouldn't be edited.
  String uuid = MathUtils.generateUUID();

  /// example
  /// ```dart
  /// const interleavedBuffer = new InterleavedBuffer( Float32List, 5 );
  /// const interleavedBuffer = new InterleavedBuffer();
  /// ```
  InterleavedBuffer(this.array, this.stride) {
    count = array != null ? array.length / stride : 0;
    usage = StaticDrawUsage;
    updateRange = {'offset': 0, 'count': -1};
    version = 0;

    uuid = MathUtils.generateUUID();
  }

  set needsUpdate(bool value) {
    if (value == true) version++;
  }

  InterleavedBuffer setUsage(value) {
    usage = value;
    return this;
  }

  InterleavedBuffer copy(InterleavedBuffer source) {
    // array = source.array.constructor(source.array);
    // array = Float32List.fromList(source.array.toList());
    array = Float32List.fromList(source.array);
    count = source.count;
    stride = source.stride;
    usage = source.usage;
    return this;
  }

  InterleavedBuffer copyAt(index1, attribute, index2) {
    index1 *= stride;
    index2 *= attribute.stride;

    for (var i = 0, l = stride; i < l; i++) {
      array[index1 + i] = attribute.array[index2 + i];
    }

    return this;
  }

  InterleavedBuffer set(Float32List value, [int offset = 0]) {
    array.setAll(offset, value);
    // array.set(value, offset);

    return this;
  }

  // InterleavedBuffer clone(data) {
  //   data.arrayBuffers ??= {};

  //   if (this.array.buffer._uuid == null) {
  //     this.array.buffer._uuid = MathUtils.generateUUID();
  //   }

  //   if (data.arrayBuffers[this.array.buffer._uuid] == null) {
  //     data.arrayBuffers[this.array.buffer._uuid] = this.array.slice(0).buffer;
  //   }

  //   final array = this.array.constructor(data.arrayBuffers[this.array.buffer._uuid]);
  //   final ib = this.constructor(array, this.stride);

  //   ib.setUsage(usage);

  //   return ib;
  // }

  // onUploadCallback() {}

  // InterleavedBuffer onUpload(Function callback) {
  //   onUploadCallback = callback;

  //   return this;
  // }
}
