import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class Flutter3DSphere extends StatefulWidget {
  const Flutter3DSphere({Key? key}) : super(key: key);

  @override
  _Flutter3DSphereState createState() => _Flutter3DSphereState();
}

class _Flutter3DSphereState extends State<Flutter3DSphere> {
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
        title: const Text("Flutter 3D: Sphere geometry example"),
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
                startRenderLoop();
              });
            },
          ),
          // if (camera != null && scene != null)
          //   Positioned(
          //     width: 420,
          //     top: 10,
          //     right: 10,
          //     child: FLGLControls(camera: camera!, scene: scene),
          //   ),
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

    // Create a sphere mesh
    SphereGeometry sphereGeometry = SphereGeometry(0.5, 12, 6);
    MeshBasicMaterial spherematerial = MeshBasicMaterial(
      color: Color(1.0, 1.0, 0.0, 1.0),
    );
    Mesh sphereMesh = Mesh(gl, sphereGeometry, spherematerial);
    sphereMesh.name = 'Sphere';
    sphereMesh.setPosition(Vector3(-4, 0, 0));
    sphereMesh.setScale(Vector3(100, 100, 100));
    scene.add(sphereMesh);
  }

  /// Render's the scene.
  render() {
    renderer!.render(scene, camera!);
  }
}
