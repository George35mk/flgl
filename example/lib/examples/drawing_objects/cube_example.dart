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

class CubeExample extends StatefulWidget {
  const CubeExample({Key? key}) : super(key: key);

  @override
  _CubeExampleState createState() => _CubeExampleState();
}

class _CubeExampleState extends State<CubeExample> {
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

  dynamic cubeBufferInfo;
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
  var nodeInfosByName = {};
  var scene;

  // Let's make all the nodes
  var blockGuyNodeDescriptions = {
    'name': "point between feet",
    'draw': false,
    'children': [
      {
        'name': "waist",
        'translation': [0, 3, 0],
        'children': [
          {
            'name': "torso",
            'translation': [0, 2, 0],
            'children': [
              {
                'name': "neck",
                'translation': [0, 1, 0],
                'children': [
                  {
                    'name': "head",
                    'translation': [0, 1, 0],
                  },
                ],
              },
              {
                'name': "left-arm",
                'translation': [-1, 0, 0],
                'children': [
                  {
                    'name': "left-forearm",
                    'translation': [-1, 0, 0],
                    'children': [
                      {
                        'name': "left-hand",
                        'translation': [-1, 0, 0],
                      },
                    ],
                  },
                ],
              },
              {
                'name': "right-arm",
                'translation': [1, 0, 0],
                'children': [
                  {
                    'name': "right-forearm",
                    'translation': [1, 0, 0],
                    'children': [
                      {
                        'name': "right-hand",
                        'translation': [1, 0, 0],
                      },
                    ],
                  },
                ],
              },
            ],
          },
          {
            'name': "left-leg",
            'translation': [-1, -1, 0],
            'children': [
              {
                'name': "left-calf",
                'translation': [0, -1, 0],
                'children': [
                  {
                    'name': "left-foot",
                    'translation': [0, -1, 0],
                  },
                ],
              }
            ],
          },
          {
            'name': "right-leg",
            'translation': [1, -1, 0],
            'children': [
              {
                'name': "right-calf",
                'translation': [0, -1, 0],
                'children': [
                  {
                    'name': "right-foot",
                    'translation': [0, -1, 0],
                  },
                ],
              }
            ],
          },
        ],
      },
    ],
  };

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
        title: const Text("Cube example"),
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

  makeNodes(List nodeChildren) {
    if (nodeChildren != null) {
      // return nodeDescriptions.map(makeNode);
      return nodeChildren.map((node) => makeNode(node));
    } else {
      return [];
    }
    // return nodeDescriptions ? nodeDescriptions.map(makeNode) : [];
  }

  makeNode(nodeDescription) {
    var trs = TRS();
    var node = Node(trs);

    nodeInfosByName[nodeDescription['name']] = {
      'trs': trs,
      'node': node,
    };

    trs.translation = nodeDescription['translation'] ?? trs.translation;

    if (nodeDescription['draw'] != false) {
      node.drawInfo = {
        'uniforms': {
          'u_colorOffset': [0, 0, 0.6, 0],
          'u_colorMult': [0.4, 0.4, 0.4, 1],
        },
        'programInfo': programInfo,
        'bufferInfo': cubeBufferInfo,
      };
      objectsToDraw.add(node.drawInfo);
      objects.add(node);
    }

    if (nodeDescription['children'] != null) {
      makeNodes(nodeDescription['children']).forEach((child) {
        child.setParent(node);
      });
    }

    return node;
  }

  initGl() {
    cubeBufferInfo = Primitives.createCubeWithVertexColorsBufferInfo(gl, 1);
    programInfo = BFX.createProgramInfo(gl, [vertexShaderSource, fragmentShaderSource]);

    scene = makeNode(blockGuyNodeDescriptions);
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
    var cameraPosition = [4, 3.5, 10];
    var cameraTarget = [0, 3.5, 0];
    var cameraUp = [0, 1, 0];
    var cameraMatrix = M4.lookAt(cameraPosition, cameraTarget, cameraUp);

    // Make a view matrix from the camera matrix.
    var viewMatrix = M4.inverse(cameraMatrix);

    // Compute a view projection matrix
    var viewProjectionMatrix = M4.multiply(projectionMatrix, viewMatrix);

    // Draw objects

    // Update all world matrices in the scene graph
    scene.updateWorldMatrix();

    var adjust;
    var speed = 2;
    var c = time * speed;

    adjust = sin(c).abs();
    nodeInfosByName["point between feet"]['trs'].translation[1] = adjust;

    adjust = sin(c);
    nodeInfosByName["left-leg"]['trs'].rotation[0] = adjust;
    nodeInfosByName["right-leg"]['trs'].rotation[0] = -adjust;

    adjust = sin(c + 0.1) * 0.4;
    nodeInfosByName["left-calf"]['trs'].rotation[0] = -adjust;
    nodeInfosByName["right-calf"]['trs'].rotation[0] = adjust;

    adjust = sin(c + 0.1) * 0.4;
    nodeInfosByName["left-foot"]['trs'].rotation[0] = -adjust;
    nodeInfosByName["right-foot"]['trs'].rotation[0] = adjust;

    adjust = sin(c) * 0.4;
    nodeInfosByName["left-arm"]['trs'].rotation[2] = adjust;
    nodeInfosByName["right-arm"]['trs'].rotation[2] = adjust;

    adjust = sin(c + 0.1) * 0.4;
    nodeInfosByName["left-forearm"]['trs'].rotation[2] = adjust;
    nodeInfosByName["right-forearm"]['trs'].rotation[2] = adjust;

    adjust = sin(c - 0.1) * 0.4;
    nodeInfosByName["left-hand"]['trs'].rotation[2] = adjust;
    nodeInfosByName["right-hand"]['trs'].rotation[2] = adjust;

    adjust = sin(c) * 0.4;
    nodeInfosByName["waist"]['trs'].rotation[1] = adjust;

    adjust = sin(c) * 0.4;
    nodeInfosByName["torso"]['trs'].rotation[1] = adjust;

    adjust = sin(c + 0.25) * 0.4;
    nodeInfosByName["neck"]['trs'].rotation[1] = adjust;

    adjust = sin(c + 0.5) * 0.4;
    nodeInfosByName["head"]['trs'].rotation[1] = adjust;

    adjust = cos(c * 2) * 0.4;
    nodeInfosByName["head"]['trs'].rotation[0] = adjust;

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

class TRS {
  List<num> translation = [0, 0, 0];
  List<num> rotation = [0, 0, 0];
  List<num> scale = [1, 1, 1];

  List<num> getMatrix([dst]) {
    dst ??= M4.identity();

    var t = this.translation;
    var r = this.rotation;
    var s = this.scale;

    dst = M4.identity();
    dst = M4.translate(dst, t[0], t[1], t[2]);
    dst = M4.xRotate(dst, r[0]);
    dst = M4.yRotate(dst, r[1]);
    dst = M4.zRotate(dst, r[2]);
    dst = M4.scale(dst, s[0], s[1], s[2]);

    return dst;
  }
}

class Node {
  List<Node> children = [];
  List<num> localMatrix = M4.identity();
  List<num> worldMatrix = M4.identity();
  Map<String, dynamic> drawInfo = {};
  Node? parent;
  TRS source;

  Node(this.source);

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
    var source = this.source;
    if (source != null) {
      this.localMatrix = source.getMatrix(this.localMatrix);
    }

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
