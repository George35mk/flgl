import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../cameras/camera.dart';
import '../flutter3d.dart';
import '../math/m4.dart';
import '../math/math_utils.dart';
import '../scene.dart';

class Renderer {
  /// The flgl instance.
  Flgl flgl;

  /// The OpenGLES context instance.
  OpenGLContextES gl;

  /// The viewport width.
  double width = 0;

  /// The viewport height.
  double height = 0;

  /// The viewport aspect ratio.
  double dpr = 1.0;

  /// The scene background color.
  final List<double> _backgroundColor = [0, 0, 0, 1];

  Renderer(this.gl, this.flgl);

  void setWidth(double width) {
    this.width = width;
  }

  void setHeight(double height) {
    this.height = height;
  }

  void setDPR(double dpr) {
    this.dpr = dpr;
  }

  /// Set's the scene background color.
  /// - r: the red value. 0 - 1
  /// - g: the green value. 0 - 1
  /// - b: the blue value. 0 - 1
  /// - a: the alpha value. 0 - 1.
  void setBackgroundColor(double r, double g, double b, double a) {
    _backgroundColor[0] = r;
    _backgroundColor[1] = g;
    _backgroundColor[2] = b;
    _backgroundColor[3] = a;
  }

  void render(Scene scene, Camera camera) {
    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * dpr).toInt() + 1, (height * dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    // gl.clearColor(0, 0, 0, 1);
    gl.clearColor(_backgroundColor[0], _backgroundColor[1], _backgroundColor[2], _backgroundColor[3]);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    for (var object in scene.children) {
      // Tell it to use our program (pair of shaders)
      // rememeber !!! for each model - object3d in the scene, some times is better
      // to use a seperate programe.
      gl.useProgram(object.programInfo!.program);

      // Setup all the needed attributes.
      gl.bindVertexArray(object.vao);

      // Set the camera related uniforms. camera.uniforms
      // object.uniforms['u_projection'] = camera.projectionMatrix;
      // object.uniforms['u_view'] = camera.viewMatrix;

      // Update the camera uniforms.
      Flutter3D.setUniforms(object.programInfo!, camera.uniforms);

      // Set the uniforms unique to the plane
      Flutter3D.setUniforms(object.programInfo!, object.uniforms);

      // calls gl.drawArrays or gl.drawElements
      Flutter3D.drawBufferInfo(gl, object.geometry.bufferInfo);

      // !super important.
      gl.finish();
      flgl.updateTexture();
    }
  }

  void render2() {
    var vertexShaderSource = '''
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
    ''';

    var fragmentShaderSource = '''
      #version 300 es

      // fragment shaders don't have a default precision so we need
      // to pick one. highp is a good default. It means "high precision"
      precision highp float;

      // we need to declare an output for the fragment shader
      out vec4 outColor;

      void main() {
        // Just set the output to a constant redish-purple
        outColor = vec4(1, 0, 0.5, 1);
      }
    ''';

    /// Create the vertex shader.
    int vertexShader = Flutter3D.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);

    /// Create the fragment shader.
    int fragmentShader = Flutter3D.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    /// Create the shader program from vertex and fragment shader.
    int program = Flutter3D.createProgram(gl, vertexShader, fragmentShader);

    int positionLocation = gl.getAttribLocation(program, "a_position");

    /// Create a position buffer.
    Buffer positionBuffer = gl.createBuffer();

    /// bind the buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // The triangle positions list.
    List<double> positions = [
      0, 0, 0, //
      0, 0.5, 0, //
      0.5, 0, 0, //
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(positions), gl.STATIC_DRAW);

    // Create a vertex array object (attribute state)
    var vao = gl.createVertexArray();

    // and make it the one we're currently working with
    gl.bindVertexArray(vao);

    // Turn on the attribute
    gl.enableVertexAttribArray(positionLocation);

    // Bind the position buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    var size = 3; // 2 components per iteration
    var type = gl.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0;
    var offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(positionLocation, size, type, normalize, stride, offset);

    // create the index buffer
    var indices = [0, 2, 1]; // first triangle
    var indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, Uint16List.fromList(indices), gl.STATIC_DRAW);

    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * flgl.dpr).toInt() + 1, (height * flgl.dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 1);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    // Tell it to use our program (pair of shaders)
    gl.useProgram(program);

    // Bind the attribute/buffer set we want.
    gl.bindVertexArray(vao);

    // Draw the rectangle.
    var primitiveType = gl.TRIANGLES;
    var _offset = 0;
    var count = 3;
    var indexType = gl.UNSIGNED_SHORT;
    gl.drawElements(primitiveType, count, indexType, _offset);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }
}
