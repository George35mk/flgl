import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/core/buffer_attribute.dart';
import 'package:weak_map/weak_map.dart';

class OpenGLAttributes {
  bool isWebGL2 = false;
  OpenGLContextES gl;
  WeakMap buffers = WeakMap<BufferAttribute, Object>(); // maybe memory issues, please check the package on pub.dev

  OpenGLAttributes(this.gl);

  createBuffer(BufferAttribute attribute, bufferType) {
    final array = attribute.array;
    final usage = attribute.usage;

    final buffer = gl.createBuffer();
    gl.bindBuffer(bufferType, buffer);
    gl.bufferData(bufferType, array, usage);

    int type = gl.FLOAT;
    var bytesPerElement;

    /// Now get the correct type
    /// and the bytesPerElement.

    if (array is Float32List) {
      type = gl.FLOAT;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Float64List) {
      print('THREE.WebGLAttributes: Unsupported data buffer format: Float64Array.');
    } else if (array is Uint16List) {
      if (attribute is Float16BufferAttribute) {
        if (isWebGL2) {
          type = gl.HALF_FLOAT;
          bytesPerElement = array.elementSizeInBytes;
        } else {
          print('THREE.WebGLAttributes: Usage of Float16BufferAttribute requires WebGL2.');
        }
      } else {
        type = gl.UNSIGNED_SHORT;
        bytesPerElement = array.elementSizeInBytes;
      }
    } else if (array is Int16List) {
      type = gl.SHORT;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Uint32List) {
      type = gl.UNSIGNED_INT;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Int32List) {
      type = gl.INT;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Int8List) {
      type = gl.BYTE;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Uint8List) {
      type = gl.UNSIGNED_BYTE;
      bytesPerElement = array.elementSizeInBytes;
    } else if (array is Uint8ClampedList) {
      type = gl.UNSIGNED_BYTE;
      bytesPerElement = array.elementSizeInBytes;
    }

    return {
      'buffer': buffer,
      'type': type,
      // 'bytesPerElement': array.BYTES_PER_ELEMENT, // js code
      // 'bytesPerElement': array.elementSizeInBytes,
      'bytesPerElement': bytesPerElement,
      'version': attribute.version,
    };
  }

  updateBuffer(buffer, BufferAttribute attribute, bufferType) {}

  /// Gets the data from the buffers weakMap.
  get(attribute) {
    // if ( attribute.isInterleavedBufferAttribute ) attribute = attribute.data;
    return buffers.get(attribute);
  }

  /// Removes the data from the buffers weakMap.
  remove(BufferAttribute attribute) {
    // if (attribute.isInterleavedBufferAttribute) attribute = attribute.data;
    final data = buffers.get(attribute);

    if (data != null) {
      gl.deleteBuffer(data['buffer']);
      buffers.remove(attribute);
    }
  }

  update(attribute, bufferType) {}
}
