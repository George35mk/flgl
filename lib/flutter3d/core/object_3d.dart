import 'dart:typed_data';

import 'package:flgl/flutter3d/geometries/plane_geometry.dart';
import 'package:flgl/flutter3d/geometries/shaders/plane_fragment_shader.dart';
import 'package:flgl/flutter3d/geometries/shaders/plane_vertex_shader.dart';
import 'package:flgl/flutter3d/geometries/triangle_geometry.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../flutter3d.dart';
import 'buffer_geometry.dart';

class Object3D {
  // some uniforms
  // dynamic program;
  ProgramInfo? programInfo;
  OpenGLContextES gl;
  BufferGeometry geometry;
  dynamic vao; // is int

  Map<String, dynamic> uniforms = {};

  Object3D(this.gl, this.geometry) {
    if (geometry is PlaneGeometry) {
      setupPlane();
    } else if (geometry is TriangleGeometry) {
      setupTriangle(geometry);
    } else {
      print('Unkown geometry');
    }
  }

  setupTriangle(BufferGeometry geometry) {
    String vertexShader = """
      #version 300 es
      
      // an attribute is an input (in) to a vertex shader.
      // It will receive data from a buffer
      in vec4 a_position;
      
      // all shaders have a main function
      void main() {
      
        // gl_Position is a special variable a vertex shader
        // is responsible for setting
        gl_Position = a_position;
      }
    """;

    String fragmentShader = """
      #version 300 es
      
      // fragment shaders don't have a default precision so we need
      // to pick one. highp is a good default. It means "high precision"
      precision highp float;
      
      // we need to declare an output for the fragment shader
      out vec4 outColor;
      
      void main() {
        // Just set the output to a constant reddish-purple
        outColor = vec4(1, 0, 0.5, 1);
      }
    """;

    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(gl, vertexShader, fragmentShader);

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  setupPlane() {
    // init program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(gl, planeVertexShaderSource, planeFragmentShaderSource);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);

    // make a 8x8 checkerboard texture
    int checkerboardTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, checkerboardTexture);
    gl.texImage2D(
        gl.TEXTURE_2D,
        0, // mip level
        gl.LUMINANCE, // internal format
        8, // width
        8, // height
        0, // border
        gl.LUMINANCE, // format
        gl.UNSIGNED_BYTE, // type
        Uint8List.fromList([
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
        ]));
    gl.generateMipmap(gl.TEXTURE_2D);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    uniforms['u_texture'] = checkerboardTexture;
  }
}

class OpenGLTexture {
  OpenGLTexture();
}
