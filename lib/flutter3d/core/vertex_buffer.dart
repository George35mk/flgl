import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class VertexBuffer {
  
  OpenGLContextES gl;

  /// The buffer id.
  int mRenderedId = 0; // this is the vertex buffer id basically.
  /// The buffer data.
  Float32List data; // the buffer data: []. maybe is better to use Float32List
  
  /// The buffer size. e.g array.length
  int size; // the buffer size: int.

  VertexBuffer(this.gl, this.data, this.size) {
    mRenderedId = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, mRenderedId);
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
  }

  /// Binds the buffer.
  bind() {
    gl.bindBuffer(gl.ARRAY_BUFFER, mRenderedId);
  }

  /// Unbinds the buffer.
  unBind() {
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
  }

  /// Dispose the buffer.
  dispose() {
    gl.deleteBuffer(mRenderedId);
  }
}
