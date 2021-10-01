import 'dart:async';
import 'dart:math';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/bfx.dart';
import 'package:flgl_example/bfx/primitives.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/math/m4.dart';
import 'package:flgl_example/examples/math/math_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controls/gl_controls.dart';

class DrawingMultipleThings1 extends StatefulWidget {
  const DrawingMultipleThings1({Key? key}) : super(key: key);

  @override
  _DrawingMultipleThings1State createState() => _DrawingMultipleThings1State();
}

class _DrawingMultipleThings1State extends State<DrawingMultipleThings1> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic normalLocation;
  dynamic worldViewProjectionLocation;
  dynamic worldInverseTransposeLocation;
  dynamic worldLocation;
  dynamic colorLocation;
  dynamic shininessLocation;
  dynamic lightDirectionLocation;
  dynamic innerLimitLocation;
  dynamic outerLimitLocation;
  dynamic lightWorldPositionLocation;
  dynamic viewWorldPositionLocation;
  dynamic positionBuffer;
  dynamic normalBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  /// The viewport width
  late int width = 1333;

  /// The viewport height
  late int height = 752 - 80 - 48;

  // double fieldOfViewRadians = 60.0;
  double fRotationRadians = 0.0;
  double shininess = 150.0;
  double lightRotationX = 0.0;
  double lightRotationY = 0.0;
  List<double> lightDirection = [0.0, 0.0, 1.0]; // this is computed in updateScene
  double innerLimit = 10.0;
  double outerLimit = 20.0;

  double time = 0;
  double cameraAngleRadians = 0;
  double fieldOfViewRadians = 60;
  double cameraHeight = 50;

  // Uniforms for each object.
  var sphereUniforms = {
    'u_colorMult': [0.5, 1, 0.5, 1],
    'u_matrix': M4.identity(),
  };
  var cubeUniforms = {
    'u_colorMult': [1, 0.5, 0.5, 1],
    'u_matrix': M4.identity(),
  };
  var coneUniforms = {
    'u_colorMult': [0.5, 0.5, 1, 1],
    'u_matrix': M4.identity(),
  };
  var sphereTranslation = [0, 0, 0];
  var cubeTranslation = [-40, 0, 0];
  var coneTranslation = [40, 0, 0];

  computeMatrix(viewProjectionMatrix, translation, xRotation, yRotation) {
    var matrix = M4.translate(viewProjectionMatrix, translation[0], translation[1], translation[2]);
    matrix = M4.xRotate(matrix, xRotation);
    return M4.yRotate(matrix, yRotation);
  }

  dynamic sphereBufferInfo;
  dynamic cubeBufferInfo;
  dynamic coneBufferInfo;
  dynamic programInfo;

  TransformControlsManager? controlsManager;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // init control manager.
    // ! add more controls for scale and rotation.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'fRotation', min: -360, max: 360, value: 0.0));
    // controlsManager!.add(TransformControl(name: 'lightRotationX', min: -2, max: 2, value: lightRotationX));
    // controlsManager!.add(TransformControl(name: 'lightRotationy', min: -2, max: 2, value: lightRotationY));
    // controlsManager!.add(TransformControl(name: 'innerLimit', min: 0, max: 180, value: innerLimit));
    // controlsManager!.add(TransformControl(name: 'outerLimit', min: 0, max: 180, value: outerLimit));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Drawing Multiple Things 1"),
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
                    timer = Timer.periodic(Duration(milliseconds: 20), (Timer t) => {draw()});
                  });
                },
              ),
              Positioned(
                width: 420,
                // height: 150,
                top: 10,
                right: 10,
                child: GLControls(
                  transformControlsManager: controlsManager,
                  onChange: (TransformControl control) {
                    setState(() {
                      switch (control.name) {
                        case 'fRotation':
                          fRotationRadians = MathUtils.degToRad(control.value);
                          break;
                        case 'lightRotationX':
                          lightRotationX = control.value;
                          break;
                        case 'lightRotationy':
                          lightRotationY = control.value;
                          break;
                        case 'innerLimit':
                          innerLimit = control.value;
                          break;
                        case 'outerLimit':
                          outerLimit = control.value;
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

  initGl() {
    // BFX bfx = BFX();

    sphereBufferInfo = Primitives.createSphereWithVertexColorsBufferInfo(gl, 10, 12, 6);
    cubeBufferInfo = Primitives.createCubeWithVertexColorsBufferInfo(gl, 20);
    coneBufferInfo = Primitives.createTruncatedConeWithVertexColorsBufferInfo(gl, 10, 0, 20, 12, 1, true, false);

    programInfo = BFX.createProgramInfo(gl, [vertexShaderSource, fragmentShaderSource]);
  }

  draw() {
    time += 0.05;

    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * flgl.dpr).toInt(), (height * flgl.dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 0);

    // Clear the canvas.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // Turn on culling. By default backfacing triangles will be culled.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    // Tell it to use our program (pair of shaders)
    // gl.useProgram(program);

    // ----------------------- Matrix setup-----------------------

    // Compute the projection matrix
    double fov = MathUtils.degToRad(fieldOfViewRadians);
    double aspect = (width * flgl.dpr) / (height * flgl.dpr);
    double zNear = 1;
    double zFar = 2000;
    var projectionMatrix = M4.perspective(fov, aspect, zNear, zFar);

    // Compute the camera's matrix
    var camera = [0, 0, 100];
    var target = [0, 0, 0];
    var up = [0, 1, 0];
    var cameraMatrix = M4.lookAt(camera, target, up);

    // Make a view matrix from the camera matrix.
    var viewMatrix = M4.inverse(cameraMatrix);

    // Compute a view projection matrix
    var viewProjectionMatrix = M4.multiply(projectionMatrix, viewMatrix);
    var sphereXRotation = time;
    var sphereYRotation = time;
    var cubeXRotation = -time;
    var cubeYRotation = time;
    var coneXRotation = time;
    var coneYRotation = -time;

    gl.useProgram(programInfo['program']);

    // ------ Draw the sphere --------

    // Setup all the needed attributes.
    BFX.setBuffersAndAttributes(gl, programInfo, sphereBufferInfo);

    sphereUniforms['u_matrix'] = computeMatrix(
      viewProjectionMatrix,
      sphereTranslation,
      sphereXRotation,
      sphereYRotation,
    );

    // Set the uniforms we just computed
    BFX.setUniforms(programInfo, sphereUniforms);

    gl.drawArrays(gl.TRIANGLES, 0, sphereBufferInfo['numElements']);

    // ------ Draw the cube --------

    // Setup all the needed attributes.
    BFX.setBuffersAndAttributes(gl, programInfo, cubeBufferInfo);

    cubeUniforms['u_matrix'] = computeMatrix(
      viewProjectionMatrix,
      cubeTranslation,
      cubeXRotation,
      cubeYRotation,
    );

    // Set the uniforms we just computed
    BFX.setUniforms(programInfo, cubeUniforms);

    gl.drawArrays(gl.TRIANGLES, 0, cubeBufferInfo['numElements']);

    // ------ Draw the cone --------

    // Setup all the needed attributes.
    BFX.setBuffersAndAttributes(gl, programInfo, coneBufferInfo);

    coneUniforms['u_matrix'] = computeMatrix(
      viewProjectionMatrix,
      coneTranslation,
      coneXRotation,
      coneYRotation,
    );

    // Set the uniforms we just computed
    BFX.setUniforms(programInfo, coneUniforms);

    gl.drawArrays(gl.TRIANGLES, 0, coneBufferInfo['numElements']);

    // // Draw the geometry.
    // var primitiveType = gl.TRIANGLES;
    // var offset_ = 0;
    // var count = 16 * 6;
    // gl.drawArrays(primitiveType, offset_, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }

  String vertexShaderSource = """
    attribute vec4 a_position;
    attribute vec4 a_color;

    uniform mat4 u_matrix;

    varying vec4 v_color;

    void main() {
      // Multiply the position by the matrix.
      gl_Position = u_matrix * a_position;

      // Pass the color to the fragment shader.
      v_color = a_color;
    }
  """;

  String fragmentShaderSource = """
    precision mediump float;

    // Passed in from the vertex shader.
    varying vec4 v_color;

    uniform vec4 u_colorMult;

    void main() {
      gl_FragColor = v_color * u_colorMult;
    }
  """;
}
