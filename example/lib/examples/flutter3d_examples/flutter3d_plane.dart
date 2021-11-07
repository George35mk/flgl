import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Flutter3DPlane extends StatefulWidget {
  const Flutter3DPlane({Key? key}) : super(key: key);

  @override
  _Flutter3DPlaneState createState() => _Flutter3DPlaneState();
}

class _Flutter3DPlaneState extends State<Flutter3DPlane> {
  /// The flutter graphics library instance.
  late Flgl flgl;

  /// The OpenGL context.
  late OpenGLContextES gl;

  /// Set this to true when the FLGLViewport initialized.
  bool initialized = false;

  /// The viewport width.
  double width = 0.0;

  /// The viewport height.
  double height = 0.0;

  /// The device pixel ratio.
  double dpr = 1.0;

  /// The timer for the render loop.
  Timer? timer;

  /// The transform controls manager.
  TransformControlsManager? controlsManager;

  Scene scene = Scene();
  PerspectiveCamera? camera;
  Renderer? renderer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Draw 50 frames per second.
  void startRenderLoop() {
    timer = Timer.periodic(
      const Duration(milliseconds: 33),
      (Timer t) => {
        render(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter 3D: Plane example"),
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
                // render();
                startRenderLoop();
              });
            },
          ),
          if (camera != null && scene != null)
            Positioned(
              width: 420,
              top: 10,
              right: 10,
              child: FLGLControls(camera: camera!, scene: scene),
            ),
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() {
    // Setup the camera.
    camera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
    camera!.setPosition(Vector3(0, 0, 300));

    // Setup the renderer.
    renderer = Renderer(gl, flgl);
    renderer!.setBackgroundColor(0, 0, 0, 1);
    renderer!.setWidth(width);
    renderer!.setHeight(height);
    renderer!.setDPR(dpr);

    // Create a plane mesh 1
    PlaneGeometry planeGeometry = PlaneGeometry();
    MeshBasicMaterial material2 = MeshBasicMaterial(
      color: Color(1.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh = Mesh(gl, planeGeometry, material2);
    planeMesh.name = 'plane 1';
    planeMesh.setPosition(Vector3(0, 0, 50));
    planeMesh.setRotation(Vector3(90, 0, 0));
    planeMesh.setScale(Vector3(20, 20, 20));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry();
    MeshBasicMaterial material3 = MeshBasicMaterial(
      color: Color(0.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh2 = Mesh(gl, planeGeometry2, material3);
    planeMesh2.name = 'plane 2';
    planeMesh2.setPosition(Vector3(0, 0, 25));
    planeMesh2.setRotation(Vector3(90, 0, 0));
    planeMesh2.setScale(Vector3(50, 50, 50));
    scene.add(planeMesh2);

    // Create a plane mesh 3
    PlaneGeometry planeGeometry3 = PlaneGeometry();
    MeshBasicMaterial material4 = MeshBasicMaterial(
      color: Color(0.3, 0.0, 1.0, 1.0),
    );
    Mesh planeMesh3 = Mesh(gl, planeGeometry3, material4);
    planeMesh3.name = 'plane 3';
    planeMesh3.setPosition(Vector3(0, 0, 0));
    planeMesh3.setRotation(Vector3(90, 0, 0));
    planeMesh3.setScale(Vector3(100, 100, 100));
    scene.add(planeMesh3);
  }

  /// Render's the scene.
  render() {
    renderer!.render(scene, camera!);
  }
}
