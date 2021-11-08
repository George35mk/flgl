import 'dart:async';
import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class Flutter3DPlaneWithTexture extends StatefulWidget {
  const Flutter3DPlaneWithTexture({Key? key}) : super(key: key);

  @override
  _Flutter3DPlaneWithTextureState createState() => _Flutter3DPlaneWithTextureState();
}

class _Flutter3DPlaneWithTextureState extends State<Flutter3DPlaneWithTexture> {
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
      const Duration(milliseconds: 50),
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
        title: const Text("Flutter 3D: Plane with checkboard texture example"),
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
    // colors
    Color redColor = Color(1, 0, 0, 1);
    Color greenColor = Color(0, 1, 0, 1);
    Color whiteColor = Color(1, 1, 1, 1);

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
    PlaneGeometry planeGeometry1 = PlaneGeometry(50, 50);
    MeshBasicMaterial material1 = MeshBasicMaterial(
      color: redColor,
    );
    Mesh planeMesh = Mesh(gl, planeGeometry1, material1);
    planeMesh.name = 'planeMesh';
    planeMesh.setPosition(Vector3(-75, 0, 0));
    planeMesh.setRotation(Vector3(90, 0, 0));
    planeMesh.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry(50, 50);
    MeshBasicMaterial material2 = MeshBasicMaterial(
      color: whiteColor,
      mapWidth: 8,
      mapHeigth: 8,
      checkerboard: true,
      map: Uint8List.fromList([
        0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
        0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
        0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
        0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
        0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
        0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
        0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
        0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
      ]),
    );
    Mesh planeMesh2 = Mesh(gl, planeGeometry2, material2);
    planeMesh2.name = 'planeMesh3';
    planeMesh2.setPosition(Vector3(0, 0, 0));
    planeMesh2.setRotation(Vector3(90, 0, 0));
    planeMesh2.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh2);

    // Create a plane mesh 3
    PlaneGeometry planeGeometry3 = PlaneGeometry(50, 50);
    MeshBasicMaterial material3 = MeshBasicMaterial(color: greenColor);
    Mesh planeMesh3 = Mesh(gl, planeGeometry3, material3);
    planeMesh3.name = 'planeMesh2';
    planeMesh3.setPosition(Vector3(75, 0, 0));
    planeMesh3.setRotation(Vector3(90, 0, 0));
    planeMesh3.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh3);
  }

  render() {
    renderer!.render(scene, camera!);
  }
}
