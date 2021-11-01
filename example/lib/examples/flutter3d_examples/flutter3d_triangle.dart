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

  /// The device pixel ratio.
  double dpr = 1.0;

  /// The timer for the render loop.
  Timer? timer;

  /// The transform controls manager.
  TransformControlsManager? controlsManager;

  Scene scene = Scene();
  PerspectiveCamera? camera;
  Renderer? renderer;

  Vector3 translation = Vector3(0.0, 0.0, 0.0);
  Vector3 rotation = Vector3(0.0, 0.0, 0.0);
  Vector3 scale = Vector3(1.0, 1.0, 1.0);

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

  void handleControlsMangerChanges(TransformControl control) {
    switch (control.name) {
      case 'tx':
        translation.x = control.value;
        break;
      case 'ty':
        translation.y = control.value;
        break;
      case 'tz':
        translation.z = control.value;
        break;
      case 'rx':
        rotation.x = MathUtils.degToRad(control.value);
        break;
      case 'ry':
        rotation.y = MathUtils.degToRad(control.value);
        break;
      case 'rz':
        rotation.z = MathUtils.degToRad(control.value);
        break;
      case 'sx':
        scale.x = control.value;
        break;
      case 'sy':
        scale.y = control.value;
        break;
      case 'sz':
        scale.z = control.value;
        break;
      default:
    }
    // render();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

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
                // render();
                startRenderLoop();
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
    camera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
    camera!.setPosition(Vector3(0, 0, 10));

    // Setup the renderer.
    renderer = Renderer(gl, flgl);
    renderer!.setBackgroundColor(0, 0, 0, 1);
    renderer!.setWidth(width);
    renderer!.setHeight(height);
    renderer!.setDPR(dpr);

    // Add the first mesh in the scene graph.
    TriangleGeometry triangleGeometry = TriangleGeometry(gl);
    Mesh triangleMesh = Mesh(gl, triangleGeometry);
    triangleMesh.uniforms['u_colorMult'] = [0.0, 1.0, 0.0, 1.0]; // green
    triangleMesh.setPosition(Vector3(0, 0, 0));
    triangleMesh.setScale(Vector3(1, 1, 1));
    scene.add(triangleMesh);

    // Add the second mesh.
    TriangleGeometry triangleGeometry2 = TriangleGeometry(gl);
    Mesh triangleMesh2 = Mesh(gl, triangleGeometry2);
    triangleMesh2.uniforms['u_colorMult'] = [1.0, 0.0, 0.0, 1.0]; // red
    triangleMesh2.setPosition(Vector3(-0.7, 0, 0));
    triangleMesh2.setScale(Vector3(1, 1, 1));
    scene.add(triangleMesh2);

    // Create a plane mesh 1
    PlaneGeometry planeGeometry = PlaneGeometry(gl);
    Mesh planeMesh = Mesh(gl, planeGeometry);
    planeMesh.uniforms['u_colorMult'] = [1.0, 1.0, 1.0, 1.0]; // white
    planeMesh.setPosition(Vector3(2, 0, 0));
    planeMesh.setScale(Vector3(1, 1, 0));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry(gl);
    Mesh planeMesh2 = Mesh(gl, planeGeometry2);
    planeMesh2.uniforms['u_colorMult'] = [0.0, 1.0, 1.0, 1.0]; // bluish white
    planeMesh2.setPosition(Vector3(-2, 0, 0));
    planeMesh2.setScale(Vector3(1, 1, 0));
    scene.add(planeMesh2);

    // Create a sphere mesh
    // SphereGeometry sphereGeometry = SphereGeometry(gl, 0.5, 12, 6);
    // Mesh sphereMesh = Mesh(gl, sphereGeometry);
    // sphereMesh.uniforms['u_colorMult'] = [1.0, 1.0, 0.0, 1.0]; // yellow
    // sphereMesh.setPosition(Vector3(-4, 0, 0));
    // sphereMesh.setScale(Vector3(1, 1, 1));
    // scene.add(sphereMesh);

    // finally render the scene.
    // renderer!.render(scene, camera!);
  }

  /// Render's the scene.
  render() {
    // print('Render runining...');

    // triangleMesh!.setPosition(Vector3(translation[0], translation[1], translation[2]));
    // triangleMesh!.setRotation(Vector3(rotation[0], rotation[1], rotation[2]));
    // triangleMesh!.setScale(Vector3(scale[0], scale[1], scale[2]));

    scene.children[0].setPosition(Vector3(translation.x, translation.y, translation.z));
    scene.children[0].setRotation(Vector3(rotation.x, rotation.y, rotation.z));
    scene.children[0].setScale(Vector3(scale.x, scale.y, scale.z));

    renderer!.render(scene, camera!);
  }
}
