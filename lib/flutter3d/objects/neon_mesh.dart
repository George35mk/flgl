import 'dart:typed_data';

import 'package:flgl/flutter3d/core/index_buffer.dart';
import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';
import 'package:flgl/flutter3d/core/neon_object_3d.dart';
import 'package:flgl/flutter3d/core/shader.dart';
import 'package:flgl/flutter3d/core/vertex_array.dart';
import 'package:flgl/flutter3d/core/vertex_buffer.dart';
import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class NeonMesh extends NeonObject3D {

  NeonMesh(OpenGLContextES gl, NeonBufferGeometry geometry, Material material): super(gl, geometry, material) {

    // List<double> positions = [
    //   -0.5, -0.5, 0.0, // 0
    //   0.5, -0.5, 0.0, // 1
    //   0.5, 0.5, 0.0, // 2
    //   -0.5, 0.5, 0.0, // 3
    // ];

    // List<int> indices = [
    //   0, 1, 2, //
    //   2, 3, 0, //
    // ];


    // Init vertex array oblect (VAO).
    vao = VertexArray(gl);

    // Init vertex buffer (VB).
    vb = VertexBuffer(gl, Float32List.fromList(geometry.vertices), 4 * 3);
    
    // Init vertex buffer layout.
    BufferLayout layout = BufferLayout();
    layout.add(BufferElement(GL_FLOAT, 'a_Position', 3, false));
    // layout.add(BufferElement(GL_FLOAT, 'a_Color', 4, false));
    // layout.add(BufferElement(GL_FLOAT, 'a_TexCoord', 2, false));
    // layout.add(BufferElement(GL_FLOAT, 'a_Normal', 3, false));
    vao.addBuffer(vb, layout);

    // init index buffer.
    ib = IndexBuffer(gl, Uint16List.fromList(geometry.indices), 6);

    // init shader.
    shader = Shader(gl, material.shaderSource);
    shader.bind();


    // Set uniforms before you unbind the shader.
    // or to set the uniforms you need to bind the shader.

    vao.unBind();     // VAO
    vb.unBind();      // Vertex Buffer
    ib.unBind();      // Index Buffer
    shader.unBind();  // Shader
  }

  // @override
  // void dispose() {
  //   // ignore: todo
  //   // TODO: implement dispose
  //   super.dispose();
  // }
}

// String vs = """
//   #version 300 es
  
//   layout(location = 0) in vec4 position;

//   void main() {
//     gl_Position = position;
//   }
// """;

// String fs = """
//   #version 300 es
  
//   precision highp float;

//   layout(location = 0) out vec4 color;

//   uniform vec4 u_Color;

//   void main() {
//     color = u_Color;
//   }
// """;

// Map<String, String> exampleShader = {
//   'vertexShader': vs,
//   'fragmentShader': fs,
// };