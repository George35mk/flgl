import 'dart:math';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/math/m4.dart';
import 'package:flgl_example/examples/math/math_utils.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../controls/gl_controls.dart';
import '../gl_utils.dart';

class Example22 extends StatefulWidget {
  const Example22({Key? key}) : super(key: key);

  @override
  _Example22State createState() => _Example22State();
}

class _Example22State extends State<Example22> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic colorLocation;
  dynamic matrixLocation;
  dynamic fudgeLocation;
  dynamic positionBuffer;
  dynamic colorBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  late int width = 1333;
  late int height = 752 - 80 - 48;

  List<double> translation = [0, 0, 0];
  List<double> rotation = [0, 0, 0];
  List<double> scale = [1, 1, 1];
  List<double> color = [Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1];
  double fudgeFactor = 2.0;

  TransformControlsManager? controlsManager;

  @override
  void initState() {
    super.initState();

    // init control manager.
    // ! add more controls for scale and rotation.
    controlsManager = TransformControlsManager({});

    controlsManager!.add(TransformControl(name: 'tx', min: -200, max: 1000, value: translation[0]));
    controlsManager!.add(TransformControl(name: 'ty', min: -200, max: 1000, value: translation[1]));
    controlsManager!.add(TransformControl(name: 'tz', min: -200, max: 1000, value: translation[2]));

    controlsManager!.add(TransformControl(name: 'rx', min: 0, max: 360, value: rotation[0]));
    controlsManager!.add(TransformControl(name: 'ry', min: 0, max: 360, value: rotation[1]));
    controlsManager!.add(TransformControl(name: 'rz', min: 0, max: 360, value: rotation[2]));

    controlsManager!.add(TransformControl(name: 'sx', min: 1.0, max: 5.0, value: scale[0]));
    controlsManager!.add(TransformControl(name: 'sy', min: 1.0, max: 5.0, value: scale[1]));
    controlsManager!.add(TransformControl(name: 'sz', min: 1.0, max: 5.0, value: scale[2]));

    controlsManager!.add(TransformControl(name: 'fudgeFactor', min: 0.0, max: 2.0, value: fudgeFactor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example 22 (3D Perspective 2)"),
      ),
      body: Column(
        children: [
          Stack(
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
                },
              ),
              Positioned(
                width: 390,
                // height: 150,
                top: 10,
                right: 10,
                child: GLControls(
                  transformControlsManager: controlsManager,
                  onChange: (TransformControl control) {
                    setState(() {
                      switch (control.name) {
                        case 'tx':
                          translation[0] = control.value;
                          break;
                        case 'ty':
                          translation[1] = control.value;
                          break;
                        case 'tz':
                          translation[2] = control.value;
                          break;
                        case 'rx':
                          rotation[0] = MathUtils.degToRad(control.value);
                          break;
                        case 'ry':
                          rotation[1] = MathUtils.degToRad(control.value);
                          break;
                        case 'rz':
                          rotation[2] = MathUtils.degToRad(control.value);
                          break;
                        case 'sx':
                          scale[0] = control.value;
                          break;
                        case 'sy':
                          scale[1] = control.value;
                          break;
                        case 'sz':
                          scale[2] = control.value;
                          break;
                        case 'fudgeFactor':
                          fudgeFactor = control.value;
                          break;
                        default:
                      }
                      draw();
                    });
                  },
                ),
              )

              // GLControls(),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  color = [Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1];
                  draw();
                },
                child: const Text("Render"),
              )
            ],
          )
        ],
      ),
    );
  }

  String vertexShaderSource = """
    attribute vec4 a_position;
    attribute vec4 a_color;

    uniform mat4 u_matrix;
    uniform float u_fudgeFactor;

    varying vec4 v_color;

    void main() {
      // Multiply the position by the matrix.
      vec4 position = u_matrix * a_position;

      // Adjust the z to divide by
      float zToDivideBy = 1.0 + position.z * u_fudgeFactor;

      // Divide x and y by z.
      gl_Position = vec4(position.xyz, zToDivideBy);

      // Pass the color to the fragment shader.
      v_color = a_color;
    }
  """;

  String fragmentShaderSource = """
    precision mediump float;

    // Passed in from the vertex shader.
    varying vec4 v_color;

    void main() {
      gl_FragColor = v_color;
    }
  """;

  initGl() {
    int vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    int fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

    // look up where the vertex data needs to go.
    positionLocation = gl.getAttribLocation(program, "a_position");
    colorLocation = gl.getAttribLocation(program, "a_color");

    // lookup uniforms
    matrixLocation = gl.getUniformLocation(program, "u_matrix");
    fudgeLocation = gl.getUniformLocation(program, "u_fudgeFactor");

    // Create a buffer for the positions.
    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Put geometry data into buffer
    setGeometry(gl);

    // Create a buffer to put colors in
    colorBuffer = gl.createBuffer();

    // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = colorBuffer)
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);

    // Put geometry data into buffer
    setColors(gl);
  }

  draw() {
    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * flgl.dpr).toInt(), (height * flgl.dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 1);

    // Clear the canvas.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // Turn on culling. By default backfacing triangles will be culled.
    gl.enable(gl.CULL_FACE);

    // Enable the depth buffer
    gl.enable(gl.DEPTH_TEST);

    // print('CULL_FACE Enabled: ${gl.getParameter(gl.CULL_FACE)}');
    // print('DEPTH_TEST Enabled: ${gl.getParameter(gl.DEPTH_TEST)}');

    // Tell it to use our program (pair of shaders)
    gl.useProgram(program);

    // Turn on the attribute
    gl.enableVertexAttribArray(positionLocation);

    // Bind the position buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    var size = 3; // 3 components per iteration
    var type = gl.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0;
    var offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(positionLocation, size, type, normalize, stride, offset);

    // ------------------------ Colors setup------------------------

    // Turn on the color attribute
    gl.enableVertexAttribArray(colorLocation);

    // Bind the color buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);

    // Tell the attribute how to get data out of colorBuffer (ARRAY_BUFFER)
    var _size = 3; // 3 components per iteration
    var _type = gl.UNSIGNED_BYTE; // the data is 8bit unsigned values
    var _normalize = true; // normalize the data (convert from 0-255 to 0-1)
    var _stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    var _offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(colorLocation, _size, _type, _normalize, _stride, _offset);

    // ----------------------- Matrix setup-----------------------

    // Compute the matrices
    int depth = 1500;
    var matrix = M4.projection(width, height, depth);
    matrix = M4.translate(matrix, translation[0], translation[1], translation[2]);
    matrix = M4.xRotate(matrix, rotation[0]);
    matrix = M4.yRotate(matrix, rotation[1]);
    matrix = M4.zRotate(matrix, rotation[2]);
    matrix = M4.scale(matrix, scale[0], scale[1], scale[2]);

    // Set the matrix.
    gl.uniformMatrix4fv(matrixLocation, false, matrix);

    // Set the fudgeFactor
    gl.uniform1f(fudgeLocation, fudgeFactor);

    // Draw the rectangle.
    var primitiveType = gl.TRIANGLES;
    var offset_ = 0;
    var count = 16 * 6;
    gl.drawArrays(primitiveType, offset_, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }

  // Fill the buffer with the values that define a letter 'F'.
  setGeometry(gl) {
    List<double> vertices = [
      // left column front
      0, 0, 0,
      0, 150, 0,
      30, 0, 0,
      0, 150, 0,
      30, 150, 0,
      30, 0, 0,

      // top rung front
      30, 0, 0,
      30, 30, 0,
      100, 0, 0,
      30, 30, 0,
      100, 30, 0,
      100, 0, 0,

      // middle rung front
      30, 60, 0,
      30, 90, 0,
      67, 60, 0,
      30, 90, 0,
      67, 90, 0,
      67, 60, 0,

      // left column back
      0, 0, 30,
      30, 0, 30,
      0, 150, 30,
      0, 150, 30,
      30, 0, 30,
      30, 150, 30,

      // top rung back
      30, 0, 30,
      100, 0, 30,
      30, 30, 30,
      30, 30, 30,
      100, 0, 30,
      100, 30, 30,

      // middle rung back
      30, 60, 30,
      67, 60, 30,
      30, 90, 30,
      30, 90, 30,
      67, 60, 30,
      67, 90, 30,

      // top
      0, 0, 0,
      100, 0, 0,
      100, 0, 30,
      0, 0, 0,
      100, 0, 30,
      0, 0, 30,

      // top rung right
      100, 0, 0,
      100, 30, 0,
      100, 30, 30,
      100, 0, 0,
      100, 30, 30,
      100, 0, 30,

      // under top rung
      30, 30, 0,
      30, 30, 30,
      100, 30, 30,
      30, 30, 0,
      100, 30, 30,
      100, 30, 0,

      // between top rung and middle
      30, 30, 0,
      30, 60, 30,
      30, 30, 30,
      30, 30, 0,
      30, 60, 0,
      30, 60, 30,

      // top of middle rung
      30, 60, 0,
      67, 60, 30,
      30, 60, 30,
      30, 60, 0,
      67, 60, 0,
      67, 60, 30,

      // right of middle rung
      67, 60, 0,
      67, 90, 30,
      67, 60, 30,
      67, 60, 0,
      67, 90, 0,
      67, 90, 30,

      // bottom of middle rung.
      30, 90, 0,
      30, 90, 30,
      67, 90, 30,
      30, 90, 0,
      67, 90, 30,
      67, 90, 0,

      // right of bottom
      30, 90, 0,
      30, 150, 30,
      30, 90, 30,
      30, 90, 0,
      30, 150, 0,
      30, 150, 30,

      // bottom
      0, 150, 0,
      0, 150, 30,
      30, 150, 30,
      0, 150, 0,
      30, 150, 30,
      30, 150, 0,

      // left side
      0, 0, 0,
      0, 0, 30,
      0, 150, 30,
      0, 0, 0,
      0, 150, 30,
      0, 150, 0
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(vertices), gl.STATIC_DRAW);
  }

  setColors(gl) {
    List<int> colors = [
      // left column front
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,

      // top rung front
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,

      // middle rung front
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,
      200, 70, 120,

      // left column back
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,

      // top rung back
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,

      // middle rung back
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,
      80, 70, 200,

      // top
      70, 200, 210,
      70, 200, 210,
      70, 200, 210,
      70, 200, 210,
      70, 200, 210,
      70, 200, 210,

      // top rung right
      200, 200, 70,
      200, 200, 70,
      200, 200, 70,
      200, 200, 70,
      200, 200, 70,
      200, 200, 70,

      // under top rung
      210, 100, 70,
      210, 100, 70,
      210, 100, 70,
      210, 100, 70,
      210, 100, 70,
      210, 100, 70,

      // between top rung and middle
      210, 160, 70,
      210, 160, 70,
      210, 160, 70,
      210, 160, 70,
      210, 160, 70,
      210, 160, 70,

      // top of middle rung
      70, 180, 210,
      70, 180, 210,
      70, 180, 210,
      70, 180, 210,
      70, 180, 210,
      70, 180, 210,

      // right of middle rung
      100, 70, 210,
      100, 70, 210,
      100, 70, 210,
      100, 70, 210,
      100, 70, 210,
      100, 70, 210,

      // bottom of middle rung.
      76, 210, 100,
      76, 210, 100,
      76, 210, 100,
      76, 210, 100,
      76, 210, 100,
      76, 210, 100,

      // right of bottom
      140, 210, 80,
      140, 210, 80,
      140, 210, 80,
      140, 210, 80,
      140, 210, 80,
      140, 210, 80,

      // bottom
      90, 130, 110,
      90, 130, 110,
      90, 130, 110,
      90, 130, 110,
      90, 130, 110,
      90, 130, 110,

      // left side
      160, 160, 220,
      160, 160, 220,
      160, 160, 220,
      160, 160, 220,
      160, 160, 220,
      160, 160, 220
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Uint8List.fromList(colors), gl.STATIC_DRAW);
  }
}
