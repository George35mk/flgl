import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'buffer_attribute.dart';

/* DataType */
var BYTE = 0x1400;
var UNSIGNED_BYTE = 0x1401;
var SHORT = 0x1402;
var UNSIGNED_SHORT = 0x1403;
var INT = 0x1404;
var UNSIGNED_INT = 0x1405;
var FLOAT = 0x1406;
var UNSIGNED_SHORT_4_4_4_4 = 0x8033;
var UNSIGNED_SHORT_5_5_5_1 = 0x8034;
var UNSIGNED_SHORT_5_6_5 = 0x8363;
var HALF_FLOAT = 0x140B;
var UNSIGNED_INT_2_10_10_10_REV = 0x8368;
var UNSIGNED_INT_10F_11F_11F_REV = 0x8C3B;
var UNSIGNED_INT_5_9_9_9_REV = 0x8C3E;
var FLOAT_32_UNSIGNED_INT_24_8_REV = 0x8DAD;
var UNSIGNED_INT_24_8 = 0x84FA;

class BufferGeometry {
  BufferAttribute? index;
  Map<String, BufferAttribute> attributes = {};

  // new
  BufferInfo bufferInfo = BufferInfo();

  BufferGeometry();

  /// Return the maximum number in the array.
  int getMax(List<int> array) {
    var max = array.reduce((value, element) => value > element ? value : element);
    return max;
  }

  /// Sets the index list, the list can be a List<int> or a BufferAttribute.
  BufferGeometry setIndex(dynamic index) {
    if (index is BufferAttribute) {
      this.index = index;
    } else {
      this.index = getMax(index) > 65535 ? Uint32BufferAttribute(index, 1) : Uint16BufferAttribute(index, 1);
    }
    return this;
  }

  /// Sets an attribute to this geometry. Use this rather than the attributes property,
  /// because an internal hashmap of .attributes is maintained to speed up iterating
  /// over attributes.
  ///
  /// - [name] of the attribute.
  /// - [attribute] the atribute data.
  BufferGeometry setAttribute(String name, BufferAttribute attribute) {
    attributes[name] = attribute;
    return this;
  }

  BufferAttribute getAttribute(String name) {
    return attributes[name]!;
  }

  getGLTypeForTypedArray(BufferAttribute bufferAttribute) {
    var _array = bufferAttribute.array;
    if (_array is Int8List) {
      return BYTE;
    } else if (_array is Uint8List) {
      return UNSIGNED_BYTE;
    } else if (_array is Uint8ClampedList) {
      return UNSIGNED_BYTE;
    } else if (_array is Int16List) {
      return SHORT;
    } else if (_array is Uint16List) {
      return UNSIGNED_SHORT; // 5123
    } else if (_array is Int32List) {
      return INT;
    } else if (_array is Uint32List) {
      return UNSIGNED_INT;
    } else if (_array is Float32List) {
      return FLOAT;
    } else {
      throw "unsupported typed array type";
    }
  }

  /// The [drawType] can be:
  /// - ARRAY_BUFFER
  /// - gl.ELEMENT_ARRAY_BUFFER
  ///
  createBufferFromBufferAttribute(OpenGLContextES gl, BufferAttribute bufferAttribute, int drawType) {
    var buffer = gl.createBuffer();
    gl.bindBuffer(drawType, buffer);
    gl.bufferData(drawType, bufferAttribute.array, gl.STATIC_DRAW);
    return buffer;
  }

  computeBufferInfo(OpenGLContextES gl) {
    var attributes = ['position', 'normal', 'uv']; // also the color...
    for (var i = 0; i < attributes.length; i++) {
      var attributeName = attributes[i];
      var attribute = getAttribute(attributeName);
      // bufferInfo.attribs[attributeName] = {
      //   'buffer': createBufferFromBufferAttribute(gl, getAttribute(attributeName), gl.ARRAY_BUFFER),
      //   'numComponents': getAttribute(attributeName).itemSize,
      //   'type': getGLTypeForTypedArray(getAttribute(attributeName)),
      //   'normalize': getAttribute(attributeName).normalized,
      //   'stride': 0,
      //   'offset': 0,
      //   'drawType': getAttribute(attributeName).usage,
      // };
      bufferInfo.attribs[attributeName] = AttributeBufferInfo(
        buffer: createBufferFromBufferAttribute(gl, attribute, gl.ARRAY_BUFFER),
        numComponents: attribute.itemSize,
        type: getGLTypeForTypedArray(attribute),
        normalize: attribute.normalized,
        stride: 0,
        offset: 0,
        drawType: attribute.usage,
      );
    }

    if (index != null) {
      bufferInfo.indices = createBufferFromBufferAttribute(gl, index!, gl.ELEMENT_ARRAY_BUFFER);
      bufferInfo.numElements = index!.array.length;
      bufferInfo.elementType = getGLTypeForTypedArray(index!);
    } else {
      bufferInfo.numElements = getAttribute('position').count; // length / numComponents;
    }
  }
}

class BufferInfo {
  Map<String, AttributeBufferInfo> attribs = {};
  Buffer? indices;
  late int numElements;
  late int elementType;
  BufferInfo();
}

/// 0:"buffer" -> Buffer
/// 1:"numComponents" -> 3
/// 2:"type" -> 5126
/// 3:"normalize" -> false
/// 4:"stride" -> 0
/// 5:"offset" -> 0
/// 6:"drawType" -> 35044

class AttributeBufferInfo {
  /// The buffer position or Buffer instance.
  /// var buffer = gl.createBuffer();
  Buffer buffer;

  /// components per iteration.
  int numComponents;

  /// The data type. example gl.FLOAT.
  int type;

  /// don't normalize the data
  bool normalize;

  /// 0 = move forward size * sizeof(type) each iteration to get the next position.
  int stride = 0;

  /// start at the beginning of the buffer
  int offset = 0;

  /// example gl.STATIC_DRAW.
  int drawType;

  AttributeBufferInfo(
      {required this.buffer,
      required this.numComponents,
      required this.type,
      required this.normalize,
      required this.stride,
      required this.offset,
      required this.drawType});
}
