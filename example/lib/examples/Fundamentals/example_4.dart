import 'dart:math';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../gl_utils.dart';

class Example4 extends StatefulWidget {
  const Example4({Key? key}) : super(key: key);

  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic resolutionUniformLocation;
  dynamic colorUniformLocation;
  dynamic positionBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  late int width = 1333;
  late int height = 752 - 80 - 48;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example 4"),
      ),
      body: Column(
        children: [
          FLGLViewport(
              width: width,
              height: height,
              onInit: (Flgl _flgl) {
                setState(() {
                  initialized = true;
                  flgl = _flgl;
                  gl = flgl.gl;

                  initGl();
                  draw();
                });
              }),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  render();
                },
                child: const Text("Render"),
              )
            ],
          )
        ],
      ),
    );
  }

  render() {
    draw();
  }

  String vertexShaderSource = """
    attribute vec4 a_position;

    uniform vec2 u_resolution;

    void main() {
      // convert the position from pixels to 0.0 to 1.0
      vec2 zeroToOne = a_position.xy / u_resolution;

      // convert from 0->1 to 0->2
      vec2 zeroToTwo = zeroToOne * 2.0;

      // convert from 0->2 to -1->+1 (clipspace)
      vec2 clipSpace = zeroToTwo - 1.0;

      gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
    }
  """;

  String fragmentShaderSource = """
    precision mediump float;
 
    uniform vec4 u_color;
  
    void main() {
      gl_FragColor = u_color;
    }
  """;

  initGl() {
    var vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    var fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

    // look up where the vertex data needs to go.
    positionLocation = gl.getAttribLocation(program, "a_position");

    // look up uniform locations
    resolutionUniformLocation = gl.getUniformLocation(program, "u_resolution");
    colorUniformLocation = gl.getUniformLocation(program, "u_color");

    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // three 2d points
    List<double> positions = [
      10, 20, //
      80, 20, //
      10, 30, //
      10, 30, //
      80, 20, //
      80, 30, //
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(positions), gl.STATIC_DRAW);
  }

  draw() {
    // Tell WebGL how to convert from clip space to pixels
    // gl.viewport(0, 0, width, height);

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Tell it to use our program (pair of shaders)
    gl.useProgram(program);

    // Turn on the attribute
    gl.enableVertexAttribArray(positionLocation);

    // Bind the position buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    var size = 2; // 2 components per iteration
    var type = gl.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0;
    var offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(positionLocation, size, type, normalize, stride, offset);

    // set the resolution
    gl.uniform2f(resolutionUniformLocation, width, height);

    // draw 50 random rectangles in random colors
    for (var ii = 0; ii < 50; ++ii) {
      // Setup a random rectangle
      // This will write to positionBuffer because
      // its the last thing we bound on the ARRAY_BUFFER
      // bind point
      setRectangle(
        gl,
        Random().nextInt(300).toDouble(),
        Random().nextInt(300).toDouble(),
        Random().nextInt(300).toDouble(),
        Random().nextInt(300).toDouble(),
      );

      // Set a random color.
      gl.uniform4f(
        colorUniformLocation,
        Random().nextDouble(),
        Random().nextDouble(),
        Random().nextDouble(),
        1,
      );

      // Draw the rectangle.
      var primitiveType = gl.TRIANGLES;
      var offset = 0;
      var count = 6;
      gl.drawArrays(primitiveType, offset, count);
    }

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }

  // Fill the buffer with the values that define a rectangle.
  setRectangle(OpenGLContextES gl, double x, double y, double width, double height) {
    var x1 = x;
    var x2 = x + width;
    var y1 = y;
    var y2 = y + height;
    gl.bufferData(
        gl.ARRAY_BUFFER,
        Float32List.fromList([
          x1, y1, //
          x2, y1, //
          x1, y2, //
          x1, y2, //
          x2, y1, //
          x2, y2, //
        ]),
        gl.STATIC_DRAW);
  }
}
