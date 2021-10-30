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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter 3D: Triangle"),
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

                    initScene();
                    render();

                    // Draw 50 frames per second.
                    // timer = Timer.periodic(
                    //   const Duration(milliseconds: 20),
                    //   (Timer t) => {
                    //     render(),
                    //   },
                    // );
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

  initScene() {
    camera = PerspectiveCamera(60, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);

    renderer = Renderer(gl, flgl);
    renderer.width = flgl.width.toDouble();
    renderer.height = flgl.height.toDouble();
    renderer.dpr = flgl.dpr.toDouble();

    // PlaneGeometry planeGeometry = PlaneGeometry(gl);
    // Mesh plane = Mesh(gl, planeGeometry);
    // scene.add(plane);
    // scene.add(cube);

    TriangleGeometry triangleGeometry = TriangleGeometry(gl);
    Mesh mesh = Mesh(gl, triangleGeometry);
    scene.add(mesh);

    // renderer.render(scene, camera);
    renderer.render2();

    // // !super important.
    // gl.finish();
    // flgl.updateTexture();
  }

  render() {
    // renderer.render(scene, camera);
  }
}
