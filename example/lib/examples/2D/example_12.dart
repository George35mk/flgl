import 'dart:math';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/math/math_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../controls/gl_controls.dart';
import '../gl_utils.dart';
import '../math/m3.dart';

class Example12 extends StatefulWidget {
  const Example12({Key? key}) : super(key: key);

  @override
  _Example12State createState() => _Example12State();
}

class _Example12State extends State<Example12> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic colorLocation;
  dynamic matrixLocation;
  dynamic resolutionLocation;
  dynamic positionBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  late int width = 1333;
  late int height = 752 - 80 - 48;

  List<double> translation = [0.0, 0.0];
  List<double> scale = [1, 1];
  List<double> color = [Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1];
  double angleInRadians = 0.0;

  TransformControlsManager? controlsManager;

  @override
  void initState() {
    super.initState();

    // init control manager.
    // ! add more controls for scale and rotation.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'tx', min: 0, max: 1000, value: 250));
    controlsManager!.add(TransformControl(name: 'ty', min: 0, max: 1000, value: 250));
    controlsManager!.add(TransformControl(name: 'angle', min: 0, max: 360, value: 0));
    controlsManager!.add(TransformControl(name: 'sx', min: 1.0, max: 5.0, value: 1.0));
    controlsManager!.add(TransformControl(name: 'sy', min: 1.0, max: 5.0, value: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example 12 (2D Matrices)"),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              FLGLViewport(
                width: width,
                height: height,
                onChange: (Flgl _flgl) {
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
                width: 350,
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
                        case 'angle':
                          angleInRadians = MathUtils.degToRad(control.value);
                          break;
                        case 'sx':
                          scale[0] = control.value;
                          break;
                        case 'sy':
                          scale[1] = control.value;
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
    attribute vec2 a_position;

    uniform vec2 u_resolution;
    uniform mat3 u_matrix;

    void main() {
      // Multiply the position by the matrix.
      vec2 position = (u_matrix * vec3(a_position, 1)).xy;

      // convert the position from pixels to 0.0 to 1.0
      vec2 zeroToOne = position / u_resolution;

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

  // Fill the buffer with the values that define a letter 'F'.
  setGeometry(gl) {
    List<double> vertices = [
      // left column
      0, 0,
      30, 0,
      0, 150,
      0, 150,
      30, 0,
      30, 150,

      // top rung
      30, 0,
      100, 0,
      30, 30,
      30, 30,
      100, 0,
      100, 30,

      // middle rung
      30, 60,
      67, 60,
      30, 90,
      30, 90,
      67, 60,
      67, 90,
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(vertices), gl.STATIC_DRAW);
  }

  initGl() {
    var vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    var fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

    // look up where the vertex data needs to go.
    positionLocation = gl.getAttribLocation(program, "a_position");

    // lookup uniforms
    resolutionLocation = gl.getUniformLocation(program, "u_resolution");
    colorLocation = gl.getUniformLocation(program, "u_color");
    matrixLocation = gl.getUniformLocation(program, "u_matrix");

    // Create a buffer for the positions.
    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Put geometry data into buffer
    setGeometry(gl);
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
    gl.uniform2f(resolutionLocation, width, height);

    // set the color
    gl.uniform4fv(colorLocation, color);

    // Compute the matrices
    var translationMatrix = M3.translation(translation[0], translation[1]);
    var rotationMatrix = M3.rotation(angleInRadians);
    var scaleMatrix = M3.scaling(scale[0], scale[1]);

    // Multiply the matrices.
    var matrix = M3.multiply(translationMatrix, rotationMatrix);
    matrix = M3.multiply(matrix, scaleMatrix);

    // Set the matrix.
    gl.uniformMatrix3fv(matrixLocation, false, matrix);

    // Draw the rectangle.
    var primitiveType = gl.TRIANGLES;
    var offset_ = 0;
    var count = 18;
    gl.drawArrays(primitiveType, offset_, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }
}
