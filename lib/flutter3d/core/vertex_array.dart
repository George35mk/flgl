import 'dart:typed_data';

import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'vertex_buffer.dart';

class VertexBufferElement {
  int type;
  int count; // position 2 or 3, for normal is 3, for uv is 2.
  bool normalized; // most of the time is false.

  VertexBufferElement(
    this.type,
    this.count,
    this.normalized,
  );

  static int getSizeOfType(int type) {
    switch (type) {
      case GL_FLOAT:
        return 4;
      case GL_UNSIGNED_INT:
        return 4;
      case GL_UNSIGNED_BYTE:
        return 1;
      default:
        print('You should not be here');
        return 0;
    }
  }
}

class VertexBufferLayout {
  final List<VertexBufferElement> m_Elements = [];
  int m_Stride = 0;

  VertexBufferLayout();

  // push position or color or uv data.
  void pushFloat(int count) {
    m_Elements.add(VertexBufferElement(GL_FLOAT, count, false));
    m_Stride += count * VertexBufferElement.getSizeOfType(GL_FLOAT);
  }

  void pushInt(int count) {
    m_Elements.add(VertexBufferElement(GL_UNSIGNED_INT, count, false));
    m_Stride += count * VertexBufferElement.getSizeOfType(GL_UNSIGNED_INT);
  }

  void pushByte(int count) {
    m_Elements.add(VertexBufferElement(GL_BYTE, count, false));
    m_Stride += count * VertexBufferElement.getSizeOfType(GL_BYTE);
  }

  int getStride() {
    return m_Stride;
  }

  List<VertexBufferElement> getElements() {
    return m_Elements;
  }
}

class VertexArray {
  OpenGLContextES gl;
  int m_RendererID = 0; // the vao id. later this will change when we create a vao.

  VertexArray(this.gl) {
    m_RendererID = gl.createVertexArray(); // vao
    gl.bindVertexArray(m_RendererID);
  }

  bind() {
    gl.bindVertexArray(m_RendererID);
  }

  unBind() {
    gl.bindVertexArray(0);
  }

  void addBuffer(VertexBuffer vb, VertexBufferLayout layout) {
    bind();
    vb.bind();
    var elements = layout.getElements(); // has the postions, uvs etc.
    int offset = 0;
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      var stride = layout.getStride(); // or use 0 for inspection
      gl.enableVertexAttribArray(i);
      gl.vertexAttribPointer(i, element.count, element.type, element.normalized, stride, offset);
      offset += element.count * VertexBufferElement.getSizeOfType(element.type);

      // other examples from older code.
      // gl.vertexAttribPointer(index, b.numComponents, b.type, b.normalize, b.stride, b.offset);
      // _gl.vertexAttribPointer(programAttributes.position.location, 3, _gl.FLOAT, false, 0, 0);
    }
  }

  dispose() {
    gl.deleteVertexArray(m_RendererID);
  }
}
