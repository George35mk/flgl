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

class DirectionalLighting3 extends StatefulWidget {
  const DirectionalLighting3({Key? key}) : super(key: key);

  @override
  _DirectionalLighting3State createState() => _DirectionalLighting3State();
}

class _DirectionalLighting3State extends State<DirectionalLighting3> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic normalLocation;
  dynamic worldViewProjectionLocation;
  dynamic worldInverseTransposeLocation;
  dynamic worldLocation;
  dynamic colorLocation;
  dynamic reverseLightDirectionLocation;
  dynamic positionBuffer;
  dynamic normalBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  /// The viewport width
  late int width = 1333;

  /// The viewport height
  late int height = 752 - 80 - 48;

  double fieldOfViewRadians = 60;
  var fRotationRadians = 0.0;

  TransformControlsManager? controlsManager;

  @override
  void initState() {
    super.initState();

    // init control manager.
    // ! add more controls for scale and rotation.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'fRotation', min: -360, max: 360, value: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Directional Lighting 3"),
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
    int vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    int fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    // create the program
    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

    // look up where the vertex data needs to go.
    positionLocation = gl.getAttribLocation(program, "a_position");
    normalLocation = gl.getAttribLocation(program, "a_normal");

    // lookup uniforms
    worldViewProjectionLocation = gl.getUniformLocation(program, "u_worldViewProjection");
    worldInverseTransposeLocation = gl.getUniformLocation(program, "u_worldInverseTranspose");
    colorLocation = gl.getUniformLocation(program, "u_color");
    reverseLightDirectionLocation = gl.getUniformLocation(program, "u_reverseLightDirection");

    // Create a buffer for the positions.
    positionBuffer = gl.createBuffer();

    // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Put geometry data into buffer
    setGeometry(gl);

    // Create a buffer to put normals in
    normalBuffer = gl.createBuffer();

    // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = normalBuffer)
    gl.bindBuffer(gl.ARRAY_BUFFER, normalBuffer);

    // Put normals data into buffer
    setNormals(gl);
  }

  draw() {
    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * flgl.dpr).toInt(), (height * flgl.dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 0);

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

    // ------------------------ Normals setup------------------------

    // Turn on the normal attribute
    gl.enableVertexAttribArray(normalLocation);

    // Bind the normal buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, normalBuffer);

    // Tell the attribute how to get data out of normalBuffer (ARRAY_BUFFER)
    var _size = 3; // 3 components per iteration
    var _type = gl.FLOAT; // the data is 8bit unsigned values
    var _normalize = true; // normalize the data (convert from 0-255 to 0-1)
    var _stride = 0; // 0 = move forward size * sizeof(type) each iteration to get the next position
    var _offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(normalLocation, _size, _type, _normalize, _stride, _offset);

    // ----------------------- Matrix setup-----------------------

    // Compute the projection matrix
    double fov = MathUtils.degToRad(fieldOfViewRadians);
    double aspect = (width * flgl.dpr) / (height * flgl.dpr);
    double zNear = 1;
    double zFar = 2000;
    var projectionMatrix = M4.perspective(fov, aspect, zNear, zFar);

    // Compute the camera's matrix
    List<double> camera = [100, 150, 200];
    List<double> target = [0, 0, 0];
    List<double> up = [0, 1, 0];
    var cameraMatrix = M4.lookAt(camera, target, up);

    // Make a view matrix from the camera matrix.
    var viewMatrix = M4.inverse(cameraMatrix);

    // Compute a view projection matrix
    var viewProjectionMatrix = M4.multiply(projectionMatrix, viewMatrix);

    // Draw a F at the origin
    var worldMatrix = M4.yRotation(fRotationRadians);

    // Multiply the matrices.
    var worldViewProjectionMatrix = M4.multiply(viewProjectionMatrix, worldMatrix);
    var worldInverseMatrix = M4.inverse(worldMatrix);
    var worldInverseTransposeMatrix = M4.transpose(worldInverseMatrix);

    // Set the matrices
    gl.uniformMatrix4fv(worldViewProjectionLocation, false, worldViewProjectionMatrix);
    gl.uniformMatrix4fv(worldInverseTransposeLocation, false, worldInverseTransposeMatrix);

    // Set the color to use
    gl.uniform4fv(colorLocation, [0.2, 1, 0.2, 1]); // green

    // set the light direction.
    gl.uniform3fv(reverseLightDirectionLocation, M4.normalize([0.5, 0.7, 1]));

    // Draw the geometry.
    var primitiveType = gl.TRIANGLES;
    var offset_ = 0;
    var count = 16 * 6;
    gl.drawArrays(primitiveType, offset_, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }

  String vertexShaderSource = """
    attribute vec4 a_position;
    attribute vec3 a_normal;

    uniform mat4 u_worldViewProjection;
    uniform mat4 u_worldInverseTranspose;

    varying vec3 v_normal;

    void main() {
      // Multiply the position by the matrix.
      gl_Position = u_worldViewProjection * a_position;

      // orient the normals and pass to the fragment shader
      v_normal = mat3(u_worldInverseTranspose) * a_normal;
    }
  """;

  String fragmentShaderSource = """
    precision mediump float;

    // Passed in from the vertex shader.
    varying vec3 v_normal;

    uniform vec3 u_reverseLightDirection;
    uniform vec4 u_color;

    void main() {
      // because v_normal is a varying it's interpolated
      // so it will not be a unit vector. Normalizing it
      // will make it a unit vector again
      vec3 normal = normalize(v_normal);

      float light = dot(normal, u_reverseLightDirection);

      gl_FragColor = u_color;

      // Lets multiply just the color portion (not the alpha)
      // by the light
      gl_FragColor.rgb *= light;
    }
  """;

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

    // Center the F around the origin and Flip it around. We do this because
    // we're in 3D now with and +Y is up where as before when we started with 2D
    // we had +Y as down.

    // We could do by changing all the values above but I'm lazy.
    // We could also do it with a matrix at draw time but you should
    // never do stuff at draw time if you can do it at init time.
    var matrix = M4.xRotation(pi);
    matrix = M4.translate(matrix, -50, -75, -15);

    for (var ii = 0; ii < vertices.length; ii += 3) {
      var vector = M4.transformPoint(matrix, [vertices[ii + 0], vertices[ii + 1], vertices[ii + 2], 1]);
      vertices[ii + 0] = vector[0];
      vertices[ii + 1] = vector[1];
      vertices[ii + 2] = vector[2];
    }
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

  setNormals(gl) {
    List<double> normals = [
      // left column front
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,

      // top rung front
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,

      // middle rung front
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,
      0, 0, 1,

      // left column back
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,

      // top rung back
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,

      // middle rung back
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,
      0, 0, -1,

      // top
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,

      // top rung right
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,

      // under top rung
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,

      // between top rung and middle
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,

      // top of middle rung
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,
      0, 1, 0,

      // right of middle rung
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,

      // bottom of middle rung.
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,

      // right of bottom
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,
      1, 0, 0,

      // bottom
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,
      0, -1, 0,

      // left side
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0,
      -1, 0, 0
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(normals), gl.STATIC_DRAW);
  }
}
