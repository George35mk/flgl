import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class IndexBuffer {
  OpenGLContextES gl;
  int m_RenderedID = 0; // this is the vertex buffer id basically.
  Uint16List data; // the buffer data: []. if indeices more than 65535 use Uint32List
  int count; // how many indices the buffer has. example array.length

  IndexBuffer(this.gl, this.data, this.count) {
    m_RenderedID = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, m_RenderedID);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, data, gl.STATIC_DRAW);
  }

  // int get count => data.length;

  int getCount() {
    return data.length;
  }

  bind() {
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, m_RenderedID);
  }

  unBind() {
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
  }

  dispose() {
    gl.deleteBuffer(m_RenderedID);
  }
}
