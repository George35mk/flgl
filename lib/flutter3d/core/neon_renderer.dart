import 'package:flgl/flgl.dart';
import 'package:flgl/flutter3d/core/shader.dart';
import 'package:flgl/flutter3d/core/index_buffer.dart';
import 'package:flgl/flutter3d/core/vertex_array.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class NeonRenderer {
  /// The flgl instance.
  Flgl flgl;

  /// The OpenGL ES context.
  OpenGLContextES gl;

  NeonRenderer(this.flgl, this.gl);

  /// Clear the canvas AND the depth buffer.
  clear() {
    // gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.clear(gl.COLOR_BUFFER_BIT);
  }

  draw(VertexArray va, IndexBuffer ib, Shader shader) {
    shader.bind();

    // This is the best place to set uniforms just before you bind the VAO object.
    // shader.setUniform4f('u_Color', r, 0, 1, 1); // you need to bind the shader before you set any uniform.

    va.bind();
    ib.bind();

    /// index buffer elements count.
    int count = ib.getCount();

    gl.drawElements(GL_TRIANGLES, count, GL_UNSIGNED_SHORT, 0);
  }
}
