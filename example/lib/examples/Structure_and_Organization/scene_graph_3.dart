import 'dart:async';

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

class SceneGraph3 extends StatefulWidget {
  const SceneGraph3({Key? key}) : super(key: key);

  @override
  _SceneGraph3State createState() => _SceneGraph3State();
}

class _SceneGraph3State extends State<SceneGraph3> {
  bool initialized = false;

  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  /// The viewport width
  late int width = 1333;

  /// The viewport height
  late int height = 752 - 80 - 48;

  double time = 0;
  double fRotationRadians = 0.0;
  double fieldOfViewRadians = 60;

  // Uniforms for each object.
  List<double> cubeTranslation = [-40.0, 0.0, 0.0];

  Timer? timer;

  dynamic programInfo;
  dynamic sphereBufferInfo;

  // List<Map<String, dynamic>> objectsToDraw = [];

  TransformControlsManager? controlsManager;

  // vars for the pan gesture.
  double x = 0;
  double y = 0;
  double z = 0;

  List<Map<String, dynamic>> objectsToDraw = [];
  List<Node> objects = [];

  late Node sunNode;
  late Node earthNode;
  late Node moonNode;

  @override
  void initState() {
    super.initState();

    // init control manager.
    controlsManager = TransformControlsManager({});
    // controlsManager!.add(TransformControl(name: 'fRotation', min: -360, max: 360, value: 0.0));
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
        title: const Text("3D Scene graph 3"),
      ),
      body: Column(
        children: [
          GestureDetector(
            // onHorizontalDragUpdate: (details) {
            //   cubeTranslation[0] += details.delta.dx / 20;
            //   draw();
            // },
            // onVerticalDragUpdate: (details) {
            //   cubeTranslation[1] += (-details.delta.dy) / 20;
            //   draw();
            // },
            // onPanUpdate: (details) {
            //   y = y - details.delta.dx / 100;
            //   x = x + details.delta.dy / 100;
            //   z = z - details.delta.dx / 100;
            //   print('x: $x, y: $y');

            //   cubeTranslation[0] += details.delta.dx / 5;
            //   cubeTranslation[1] += (-details.delta.dy) / 5;
            //   draw();
            // },
            child: Stack(
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
                      // Draw 50 frames per second.
                      timer = Timer.periodic(const Duration(milliseconds: 20), (Timer t) => {draw()});
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
    sphereBufferInfo = Primitives.createSphereWithVertexColorsBufferInfo(gl, 10, 12, 6);

    programInfo = BFX.createProgramInfo(gl, [vertexShaderSource, fragmentShaderSource]);

    // Let's make all the nodes
    sunNode = Node();
    sunNode.localMatrix = M4.translation(0, 0, 0); // sun a the center
    sunNode.drawInfo = {
      'uniforms': {
        'u_colorOffset': [0.6, 0.6, 0, 1], // yellow
        'u_colorMult': [0.4, 0.4, 0, 1],
      },
      'programInfo': programInfo,
      'bufferInfo': sphereBufferInfo,
    };

    earthNode = Node();
    earthNode.localMatrix = M4.translation(80, 0, 0); // earth 100 units from the sun
    // make the earth twice as large
    earthNode.localMatrix = M4.scale(earthNode.localMatrix, 2, 2, 2);
    earthNode.drawInfo = {
      'uniforms': {
        'u_colorOffset': [0.2, 0.5, 0.8, 1], // blue-green
        'u_colorMult': [0.8, 0.5, 0.2, 1],
      },
      'programInfo': programInfo,
      'bufferInfo': sphereBufferInfo,
    };

    moonNode = Node();
    moonNode.localMatrix = M4.translation(25, 0, 0); // moon 20 units from the earth
    moonNode.drawInfo = {
      'uniforms': {
        'u_colorOffset': [0.6, 0.6, 0.6, 1], // gray
        'u_colorMult': [0.1, 0.1, 0.1, 1],
      },
      'programInfo': programInfo,
      'bufferInfo': sphereBufferInfo,
    };

    // connect the celetial objects
    moonNode.setParent(earthNode);
    earthNode.setParent(sunNode);

    objects = [
      sunNode,
      earthNode,
      moonNode,
    ];

    objectsToDraw = [
      sunNode.drawInfo,
      earthNode.drawInfo,
      moonNode.drawInfo,
    ];
  }

  draw() {
    time += 0.01;

    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, (width * flgl.dpr).toInt(), (height * flgl.dpr).toInt());

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 0);

    // Clear the canvas.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // Turn on culling. By default backfacing triangles will be culled.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    // ----------------------- Matrix setup-----------------------

    // Compute the projection matrix
    double fov = MathUtils.degToRad(fieldOfViewRadians);
    double aspect = (width * flgl.dpr) / (height * flgl.dpr);
    double zNear = 1;
    double zFar = 2000;
    var projectionMatrix = M4.perspective(fov, aspect, zNear, zFar);

    // Compute the camera's matrix
    var cameraPosition = [0, -200, 0];
    var cameraTarget = [0, 0, 0];
    var cameraUp = [0, 0, 1];
    var cameraMatrix = M4.lookAt(cameraPosition, cameraTarget, cameraUp);

    // Make a view matrix from the camera matrix.
    var viewMatrix = M4.inverse(cameraMatrix);

    // Compute a view projection matrix
    var viewProjectionMatrix = M4.multiply(projectionMatrix, viewMatrix);

    // update the local matrices for each object.
    M4.multiply(M4.yRotation(0.01), sunNode.localMatrix, sunNode.localMatrix);
    M4.multiply(M4.yRotation(0.01), earthNode.localMatrix, earthNode.localMatrix);
    M4.multiply(M4.yRotation(0.05), moonNode.localMatrix, moonNode.localMatrix);

    // Update all world matrices in the scene graph
    sunNode.updateWorldMatrix();

    // Compute all the matrices for rendering
    for (var object in objects) {
      object.drawInfo['uniforms']['u_matrix'] = M4.multiply(viewProjectionMatrix, object.worldMatrix);
    }

    // ------ Draw the objects --------

    var lastUsedProgramInfo = null;
    var lastUsedBufferInfo = null;

    for (var object in objectsToDraw) {
      var programInfo = object['programInfo'];
      var bufferInfo = object['bufferInfo'];
      var bindBuffers = false;

      if (programInfo != lastUsedProgramInfo) {
        lastUsedProgramInfo = programInfo;
        gl.useProgram(programInfo['program']);

        // We have to rebind buffers when changing programs because we
        // only bind buffers the program uses. So if 2 programs use the same
        // bufferInfo but the 1st one uses only positions the when the
        // we switch to the 2nd one some of the attributes will not be on.
        bindBuffers = true;
      }

      // Setup all the needed attributes.
      if (bindBuffers || bufferInfo != lastUsedBufferInfo) {
        lastUsedBufferInfo = bufferInfo;
        BFX.setBuffersAndAttributes(gl, programInfo, bufferInfo);
      }

      // Set the uniforms.
      BFX.setUniforms(programInfo, object['uniforms']);

      // Draw
      gl.drawArrays(gl.TRIANGLES, 0, bufferInfo['numElements']);
    }

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
    uniform vec4 u_colorOffset;

    void main() {
      gl_FragColor = v_color * u_colorMult + u_colorOffset;
    }
  """;
}

class Node {
  List<Node> children = [];
  List<num> localMatrix = M4.identity();
  List<num> worldMatrix = M4.identity();
  Map<String, dynamic> drawInfo = {};
  Node? parent;

  setParent(Node parent) {
    // if the node has a parent
    // then find the parent and
    // removed from the childen list.
    if (this.parent != null) {
      var ndx = this.parent!.children.indexOf(this);
      if (ndx >= 0) {
        this.parent!.children.removeAt(ndx);
      }
    }

    // Add us to our new parent
    if (parent != null) {
      parent.children.add(this);
    }
    this.parent = parent;
  }

  updateWorldMatrix([parentWorldMatrix]) {
    if (parentWorldMatrix != null) {
      // a matrix was passed in so do the math
      M4.multiply(parentWorldMatrix, this.localMatrix, this.worldMatrix);
    } else {
      // no matrix was passed in so just copy local to world
      M4.copy(this.localMatrix, this.worldMatrix);
    }

    // now process all the children
    var worldMatrix = this.worldMatrix;
    for (var child in this.children) {
      child.updateWorldMatrix(worldMatrix);
    }
  }
}
