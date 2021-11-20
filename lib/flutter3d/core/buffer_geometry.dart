// ignore_for_file: non_constant_identifier_names

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
  /// The BufferGeometry index.
  BufferAttribute? index;

  /// The BufferGeometry attributes.
  Map<String, BufferAttribute> attributes = {};

  /// The buffer info.
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

  /// Returns the named attribute from the attributes Map.
  BufferAttribute getAttribute(String name) {
    return attributes[name]!;
  }

  /// Checks the BufferAttribute and returns the corresponding gl array type.
  int getGLTypeForTypedArray(BufferAttribute bufferAttribute) {
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
      throw "This array type are not supported.";
    }
  }

  /// The [drawType] can be:
  /// - ARRAY_BUFFER
  /// - gl.ELEMENT_ARRAY_BUFFER
  ///
  /// ### Info about the buffer
  /// Basicaly a buffer is an array.
  ///
  // int createBufferFromBufferAttribute(OpenGLContextES gl, BufferAttribute bufferAttribute, int drawType) {
  //   int buffer = gl.createBuffer();
  //   gl.bindBuffer(drawType, buffer);
  //   gl.bufferData(drawType, bufferAttribute.array, gl.STATIC_DRAW);
  //   return buffer;
  // }

  /// Creates an attribute buffer.
  int createAttributeBuffer(OpenGLContextES gl, BufferAttribute bufferAttribute) {
    int buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, bufferAttribute.array, gl.STATIC_DRAW);
    return buffer;
  }

  /// Creates an index buffer.
  int createIndexBuffer(OpenGLContextES gl, BufferAttribute bufferAttribute) {
    int ibo = gl.createBuffer(); // ibo stands for Index Buffer Object.
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, bufferAttribute.array, gl.STATIC_DRAW);
    return ibo;
  }

  void computeBufferInfo(OpenGLContextES gl) {
    var attributes = ['position', 'normal', 'uv']; // also the color...
    for (int i = 0; i < attributes.length; i++) {
      String attributeName = attributes[i];
      BufferAttribute attribute = getAttribute(attributeName);

      bufferInfo.attribs[attributeName] = AttributeBufferInfo(
        buffer: createAttributeBuffer(gl, attribute),
        numComponents: attribute.itemSize,
        // mmm we now that the attrute buffer - vertex buffer most of the times is Float32List, so we can set FLOAT
        type: getGLTypeForTypedArray(attribute),
        normalize: attribute.normalized,
        stride: 0,
        offset: 0,
        drawType: attribute.usage,
      );
    }

    if (index != null) {
      bufferInfo.indices = createIndexBuffer(gl, index!);
      bufferInfo.numElements = index!.getLength();
      bufferInfo.elementType = getGLTypeForTypedArray(index!);
    } else {
      bufferInfo.numElements = getAttribute('position').count; // length / numComponents;
    }
  }
}

// you can renamed to BufferGeometryInfo.
class BufferInfo {
  Map<String, AttributeBufferInfo> attribs = {};
  int? indices;
  late int numElements;
  late int elementType;
  BufferInfo();
}

/// The attribut Buffer Info.
/// - 0 : buffer -> Buffer
/// - 1 : numComponents -> 3
/// - 2 : type -> 5126
/// - 3 : normalize -> false
/// - 4 : stride -> 0
/// - 5 : offset -> 0
/// - 6 : drawType -> 35044
class AttributeBufferInfo {
  /// The buffer position or Buffer instance.
  /// var buffer = gl.createBuffer();
  int buffer;

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

  AttributeBufferInfo({
    required this.buffer,
    required this.numComponents,
    required this.type,
    required this.normalize,
    required this.stride,
    required this.offset,
    required this.drawType,
  });
}
