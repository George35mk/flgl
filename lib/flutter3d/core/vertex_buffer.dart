import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class VertexBuffer {
  OpenGLContextES gl;
  int mRenderedId = 0; // this is the vertex buffer id basically.
  Float32List data; // the buffer data: []. maybe is better to use Float32List
  int size; // the buffer size: int.

  VertexBuffer(this.gl, this.data, this.size) {
    mRenderedId = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, mRenderedId);
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
  }

  bind() {
    gl.bindBuffer(gl.ARRAY_BUFFER, mRenderedId);
  }

  unBind() {
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
  }

  dispose() {
    gl.deleteBuffer(mRenderedId);
  }
}
