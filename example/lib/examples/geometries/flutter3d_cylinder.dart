import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flutter/material.dart';

import 'package:flgl/flgl_3d.dart';

class Flutter3DCylinder extends StatefulWidget {
  const Flutter3DCylinder({Key? key}) : super(key: key);

  @override
  _Flutter3DCylinderState createState() => _Flutter3DCylinderState();
}

class _Flutter3DCylinderState extends State<Flutter3DCylinder> {
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

  /// The transform controls manager.
  TransformControlsManager? controlsManager;

  Scene scene = Scene();
  PerspectiveCamera? camera;
  Renderer? renderer;

  @override
  void initState() {
    super.initState();

    // init control manager.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'tx', min: -1.0, max: 1.0, value: 0));
    controlsManager!.add(TransformControl(name: 'ty', min: -5.0, max: 5.0, value: 0));
    controlsManager!.add(TransformControl(name: 'tz', min: -5.0, max: 5.0, value: 0));

    controlsManager!.add(TransformControl(name: 'rx', min: 0, max: 360, value: 0));
    controlsManager!.add(TransformControl(name: 'ry', min: 0, max: 360, value: 0));
    controlsManager!.add(TransformControl(name: 'rz', min: 0, max: 360, value: 0));

    controlsManager!.add(TransformControl(name: 'sx', min: 1.0, max: 5.0, value: 1.0));
    controlsManager!.add(TransformControl(name: 'sy', min: 1.0, max: 5.0, value: 1.0));
    controlsManager!.add(TransformControl(name: 'sz', min: 1.0, max: 5.0, value: 1.0));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<String> asyncRender() {
    // Imagine that this function is more complex and slow.
    return Future.delayed(const Duration(milliseconds: 33), () => render());
  }

  void startRenderLoop() {
    // Draw 50 frames per second.
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
        title: const Text("Flutter 3D: Cylinder geometry example"),
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

    // Create a cylinder mesh.
    CylinderGeometry cylinderGeometry = CylinderGeometry(50, 70, 8, 5, true, true);
    MeshBasicMaterial cylinderMaterial = MeshBasicMaterial(
      color: Color(0.2, 0.3, 0.9, 1.0),
    );
    Mesh cylinderMesh = Mesh(gl, cylinderGeometry, cylinderMaterial);
    cylinderMesh.name = 'cylinder';
    cylinderMesh.setPosition(Vector3(0, 0, 0));
    cylinderMesh.setScale(Vector3(1, 1, 1));
    scene.add(cylinderMesh);
  }

  render() {
    renderer!.render(scene, camera!);
  }
}
