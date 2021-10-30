import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controls/gl_controls.dart';

import 'package:flgl/flgl_3d.dart';
// import 'package:flgl/flutter3d/scene.dart';

class Flutter3DTriangle extends StatefulWidget {
  const Flutter3DTriangle({Key? key}) : super(key: key);

  @override
  _Flutter3DTriangleState createState() => _Flutter3DTriangleState();
}

class _Flutter3DTriangleState extends State<Flutter3DTriangle> {
  bool initialized = false;

  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  /// The viewport width
  double width = 0.0;

  /// The viewport height
  double height = 0.0;

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

  Scene scene = Scene();
  late PerspectiveCamera camera;
  late Renderer renderer;

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

  void startRenderLoop() {
    // Draw 50 frames per second.
    timer = Timer.periodic(
      const Duration(milliseconds: 20),
      (Timer t) => {
        render(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter 3D: Triangle"),
      ),
      body: Stack(
        children: [
          FLGLViewport(
            width: width.toInt() + 1,
            height: height.toInt(),
            onInit: (Flgl _flgl) {
              setState(() {
                initialized = true;
                flgl = _flgl;
                gl = flgl.gl;

                initScene();
                render();

                // startRenderLoop();
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
                  render();
                });
              },
            ),
          )

          // GLControls(),
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() {
    // Setup the camera.
    camera = PerspectiveCamera(60, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);

    // Setup the renderer.
    renderer = Renderer(gl, flgl);
    renderer.width = flgl.width.toDouble();
    renderer.height = flgl.height.toDouble();
    renderer.dpr = flgl.dpr.toDouble();

    // Add objects in the scene graph.
    TriangleGeometry triangleGeometry = TriangleGeometry(gl);
    Mesh mesh = Mesh(gl, triangleGeometry);
    scene.add(mesh);

    // finally render the scene.
    renderer.render(scene, camera);
  }

  /// Render's the scene.
  render() {
    renderer.render(scene, camera);
  }
}
