import 'dart:typed_data';

import '../flutter3d.dart';

class WorkingExample {
  dynamic flgl;
  dynamic gl;
  dynamic width;
  dynamic height;
  dynamic dpr;

  WorkingExample();

  // This example code works 100%. use this code as guide for the renderer.
  void render() {
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
    int positionBuffer = gl.createBuffer();

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
    var normalized = false; // don't normalize the data
    var stride = 0;
    var offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(positionLocation, size, type, normalized, stride, offset);

    // create the index buffer
    var indices = [0, 2, 1]; // first triangle
    var indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, Uint16List.fromList(indices), gl.STATIC_DRAW);

    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * dpr).toInt() + 1, (height * dpr).toInt());

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
