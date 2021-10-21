import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
// import 'package:flgl_example/bfx/geometries/box_geometry.dart';
// import 'package:flgl_example/bfx/objects/mesh.dart';
// import 'package:flgl_example/bfx/materials/mesh_basic_material.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/math/math_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:flgl_example/bfx/cameras/perspective_camera.dart';
// import 'package:flgl_example/bfx/scene.dart';
// import 'package:flgl_example/bfx/renderers/opengl_renderer.dart';

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

  // late Scene scene;
  // late PerspectiveCamera camera;
  // late OpenGLRenderer renderer;

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

                      onInit();
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

  onInit() {
    // scene = Scene();

    // // Setup the camera.
    // var fov = 60.0;
    // var aspect = (width * flgl.dpr) / (height * flgl.dpr);
    // camera = PerspectiveCamera(fov, aspect, 1, 2000);

    // renderer = OpenGLRenderer(gl: gl);

    // var geometry = BoxGeometry();
    // var material = MeshBasicMaterial(color: 0xff00ff);
    // var cube = Mesh(geometry, material);
    // scene.add(cube);
  }

  draw() {
    // renderer.render(scene, camera);
  }
}
