import 'dart:math';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/math/m3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../controls/gl_controls.dart';
import '../gl_utils.dart';
import '../math/math_utils.dart';

class Example7 extends StatefulWidget {
  const Example7({Key? key}) : super(key: key);

  @override
  _Example7State createState() => _Example7State();
}

class _Example7State extends State<Example7> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic colorLocation;
  dynamic matrixLocation;
  dynamic positionBuffer;
  dynamic colorBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  late int width = 1333;
  late int height = 752 - 80 - 48;

  List<double> translation = [200.0, 200.0];
  double angleInRadians = 0.0;
  List<double> scale = [1.0, 1.0];

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
    controlsManager!.add(TransformControl(name: 'sx', min: 1, max: 10, value: 1));
    controlsManager!.add(TransformControl(name: 'sy', min: 1, max: 10, value: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example 7"),
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
    attribute vec4 a_color;

    uniform mat3 u_matrix;

    varying vec4 v_color;

    void main() {
      // Multiply the position by the matrix.
      gl_Position = vec4((u_matrix * vec3(a_position, 1)).xy, 0, 1);

      // Copy the color from the attribute to the varying.
      v_color = a_color;
    }
  """;

  String fragmentShaderSource = """
    precision mediump float;

    varying vec4 v_color;

    void main() {
      gl_FragColor = v_color;
    }
  """;

  // Fill the buffer with the values that define a triangle.
  // Note, will put the values in whatever buffer is currently
  // bound to the ARRAY_BUFFER bind point
  setGeometry(OpenGLContextES gl) {
    gl.bufferData(
        gl.ARRAY_BUFFER,
        Float32List.fromList([
          -150, -100, //
          150, -100, //
          -150, 100, //
          150, -100, //
          -150, 100, //
          150, 100 //
        ]),
        gl.STATIC_DRAW);
  }

  // Fill the buffer with colors for the 2 triangles
  // that make the rectangle.
  // Note, will put the values in whatever buffer is currently
  // bound to the ARRAY_BUFFER bind point
  setColors(gl) {
    gl.bufferData(
      gl.ARRAY_BUFFER,
      Float32List.fromList([
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
        Random().nextDouble(), Random().nextDouble(), Random().nextDouble(), 1, //
      ]),
      gl.STATIC_DRAW,
    );
  }

  initGl() {
    var vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    var fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

    // look up where the vertex data needs to go.
    positionLocation = gl.getAttribLocation(program, "a_position");
    colorLocation = gl.getAttribLocation(program, "a_color");

    // lookup uniforms
    matrixLocation = gl.getUniformLocation(program, "u_matrix");

    // Create a buffer for the positions.
    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Set Geometry.
    setGeometry(gl);

    // Create a buffer for the colors.
    colorBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);

    // Set the colors.
    setColors(gl);
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

    // Turn on the color attribute
    gl.enableVertexAttribArray(colorLocation);

    // Bind the color buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);

    // Tell the color attribute how to get data out of colorBuffer (ARRAY_BUFFER)
    size = 4; // 4 components per iteration
    type = gl.FLOAT; // the data is 32bit floats
    normalize = false; // don't normalize the data
    stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(colorLocation, size, type, normalize, stride, offset);

    // Compute the matrix
    var matrix = M3.projection(width, height);
    matrix = M3.translate(matrix, translation[0].toDouble(), translation[1].toDouble());
    matrix = M3.rotate(matrix, angleInRadians);
    matrix = M3.scale(matrix, scale[0].toDouble(), scale[1].toDouble());

    // Set the matrix.
    gl.uniformMatrix3fv(matrixLocation, false, matrix);

    // Draw the geometry.
    var primitiveType = gl.TRIANGLES;
    var offset_ = 0;
    var count = 6;
    gl.drawArrays(primitiveType, offset_, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }
}
