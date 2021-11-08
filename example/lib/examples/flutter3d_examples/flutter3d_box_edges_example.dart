import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

import 'package:flgl/flgl_3d.dart';

class Flutter3DBoxEdgesExample extends StatefulWidget {
  const Flutter3DBoxEdgesExample({Key? key}) : super(key: key);

  @override
  _Flutter3DBoxEdgesExampleState createState() => _Flutter3DBoxEdgesExampleState();
}

class _Flutter3DBoxEdgesExampleState extends State<Flutter3DBoxEdgesExample> {
  /// Set this to true when the FLGLViewport initialized.
  bool initialized = false;

  /// The flutter graphics library instance.
  late Flgl flgl;

  /// The OpenGL context.
  late OpenGLContextES gl;

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

  /// Starts the render loop.
  /// - draws 25 frames per second.
  void startRenderLoop() {
    timer = Timer.periodic(
      const Duration(milliseconds: 40),
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
        title: const Text("Flutter 3D: Box with edges example"),
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
  initScene() async {
    Color lightGreenColor = Color().fromRGBA(121, 255, 47, 255);

    // Setup the camera.
    camera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
    camera!.setPosition(Vector3(0, 0, 300)); // {0, 0, +z} is the OpenGL camera coordinates. Right-handed system

    // Setup the renderer.
    renderer = Renderer(gl, flgl);
    renderer!.setBackgroundColor(0, 0, 0, 1);
    renderer!.setWidth(width);
    renderer!.setHeight(height);
    renderer!.setDPR(dpr);

    // Create a Edged Box Geometry
    EdgedBoxGeometry edgedBoxGeometry = EdgedBoxGeometry();
    MeshBasicMaterial edgeMat = MeshBasicMaterial(color: lightGreenColor);
    Mesh edgedBoxMesh = Mesh(gl, edgedBoxGeometry, edgeMat);
    edgedBoxMesh.name = 'Box 1';
    edgedBoxMesh.setPosition(Vector3(0, 0, 0));
    edgedBoxMesh.setRotation(Vector3(0, 0, 0));
    edgedBoxMesh.setScale(Vector3(50, 50, 50));
    scene.add(edgedBoxMesh);

    // Create a Edged Box Geometry
    EdgedBoxGeometry edgedBoxGeometry1 = EdgedBoxGeometry();
    MeshBasicMaterial edgeMat1 = MeshBasicMaterial(color: lightGreenColor);
    Mesh edgedBoxMesh1 = Mesh(gl, edgedBoxGeometry1, edgeMat1);
    edgedBoxMesh1.name = 'Box 2';
    edgedBoxMesh1.setPosition(Vector3(0, 0, 0));
    edgedBoxMesh1.setRotation(Vector3(0, 0, 0));
    edgedBoxMesh1.setScale(Vector3(50, 50, 50));
    scene.add(edgedBoxMesh1);
  }

  /// Render's the scene.
  render() {
    renderer!.render(scene, camera!);
  }
}
