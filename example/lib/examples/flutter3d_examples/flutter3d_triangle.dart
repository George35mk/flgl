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

class Flutter3DTriangle extends StatefulWidget {
  const Flutter3DTriangle({Key? key}) : super(key: key);

  @override
  _Flutter3DTriangleState createState() => _Flutter3DTriangleState();
}

class _Flutter3DTriangleState extends State<Flutter3DTriangle> {
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

  /// The timer for the render loop.
  Timer? timer;

  /// The transform controls manager.
  TransformControlsManager? controlsManager;

  Scene scene = Scene();
  PerspectiveCamera? camera;
  Renderer? renderer;

  List<double> translation = [0.0, 0.0, 0.0];
  List<double> rotation = [0.0, 0.0, 0.0];
  List<double> scale = [1.0, 1.0, 1.0];
  List<double> matrix = M4.identity();
  Mesh? triangleMesh;

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

  void startRenderLoop() {
    // Draw 50 frames per second.
    timer = Timer.periodic(
      const Duration(milliseconds: 20),
      (Timer t) => {
        render(),
      },
    );
  }

  void handleControlsMangerChanges(TransformControl control) {
    // setState(() {
    switch (control.name) {
      case 'tx':
        translation[0] = control.value;
        break;
      case 'ty':
        translation[1] = control.value;
        break;
      case 'tz':
        translation[2] = control.value;
        break;
      case 'rx':
        rotation[0] = MathUtils.degToRad(control.value);
        break;
      case 'ry':
        rotation[1] = MathUtils.degToRad(control.value);
        break;
      case 'rz':
        rotation[2] = MathUtils.degToRad(control.value);
        break;
      case 'sx':
        scale[0] = control.value;
        break;
      case 'sy':
        scale[1] = control.value;
        break;
      case 'sz':
        scale[2] = control.value;
        break;
      default:
    }
    render();
    // });
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
                handleControlsMangerChanges(control);
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
    renderer!.width = flgl.width.toDouble();
    renderer!.height = flgl.height.toDouble();
    renderer!.dpr = flgl.dpr.toDouble();

    // Add the first mesh in the scene graph.
    TriangleGeometry triangleGeometry = TriangleGeometry(gl);
    triangleMesh = Mesh(gl, triangleGeometry);
    triangleMesh!.uniforms['u_colorMult'] = [0.0, 1.0, 0.0, 1.0];
    triangleMesh!.setPosition(Vector3(0, 0, 0));

    // Add the second mesh.
    TriangleGeometry triangleGeometry2 = TriangleGeometry(gl);
    Mesh triangleMesh2 = Mesh(gl, triangleGeometry2);
    triangleMesh2.uniforms['u_colorMult'] = [1.0, 0.0, 0.0, 1.0];
    triangleMesh2.setPosition(Vector3(-0.7, 0, 0));

    // Add the meshes inside the scene.
    scene.add(triangleMesh);
    scene.add(triangleMesh2);

    // finally render the scene.
    // renderer!.render(scene, camera!);
  }

  /// Render's the scene.
  render() {
    // print('Render runining...');

    triangleMesh!.setPosition(Vector3(translation[0], translation[1], translation[2]));
    triangleMesh!.setRotation(Vector3(rotation[0], rotation[1], rotation[2]));
    triangleMesh!.setScale(Vector3(scale[0], scale[1], scale[2]));

    // scene.children[1].setRotation(Vector3(rotation[0], rotation[1], rotation[2]));

    renderer!.render(scene, camera!);
  }
}
