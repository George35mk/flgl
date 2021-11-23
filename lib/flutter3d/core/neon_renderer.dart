import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flutter3d/cameras/camera.dart';
import 'package:flgl/flutter3d/core/shader.dart';
import 'package:flgl/flutter3d/core/index_buffer.dart';
import 'package:flgl/flutter3d/core/vertex_array.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../neon_scene.dart';
import 'neon_object_3d.dart';

class NeonRenderer {

  double width = 500;
  double height = 500;
  double dpr = 1.0;
  /// The flgl instance.
  Flgl flgl;

  /// The OpenGL ES context.
  OpenGLContextES gl;

  Color clearColor = Color(0, 0, 0, 1);

  NeonRenderer(this.flgl, this.gl);

  setClearColor(Color c) {
    clearColor = c;
  }

  init() {
    gl.blendFunc(GL_SRC1_ALPHA_EXT, GL_ONE_MINUS_SRC_ALPHA); // for transparent textures

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.BLEND); // fixes the png transparent issue.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    gl.viewport(0, 0, (width * dpr).toInt(), (height * dpr).toInt());
    gl.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a); // the renderer background color.
  }

  /// Clear the canvas AND the depth buffer.
  clear() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(NeonScene scene, Camera camera) {

    clear();

    // Draw the objects.
    drawObjects(scene, camera);
    

    // ! super important.
    // ! never put this inside a loop because it takes some time
    // ! to update the texture.
    gl.finish();
    flgl.updateTexture();
  }

  drawObjects(NeonScene scene, Camera camera) {
    for (var obj in scene.children) {
      draw(obj.vao, obj.ib, obj.shader, obj, camera);
    }
  }

  draw(VertexArray va, IndexBuffer ib, Shader shader, NeonObject3D obj, Camera camera) {
    shader.bind();

    // This is the best place to set uniforms just before you bind the VAO object.
    // shader.setUniform4f('u_Color', r, 0, 1, 1); // you need to bind the shader before you set any uniform.
    // var viewMatrix = M4.translate(M4.identity(), 0, 0, 0);
    // viewMatrix = M4.translate(viewMatrix, 1, 1, 1);

    shader.setUniformMat4f('u_Projection', camera.projectionMatrix);
    shader.setUniformMat4f('u_View', camera.viewMatrix);
    shader.setUniformMat4f('u_Model', obj.matrix);

    dynamic material = obj.material;
    if (material is NeonMeshBasicMaterial) {
      shader.setUniform4f('u_Color', material.color!.r, material.color!.g, material.color!.b, material.color!.a);
    }

    va.bind();
    ib.bind();

    /// index buffer elements count.
    int count = ib.getCount();

    gl.drawElements(GL_TRIANGLES, count, GL_UNSIGNED_SHORT, 0);
  }
}
