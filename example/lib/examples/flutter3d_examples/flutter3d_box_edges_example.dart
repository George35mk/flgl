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

  /// The transform controls manager.
  TransformControlsManager? controlsManager;

  Scene scene = Scene();
  PerspectiveCamera? camera;
  Renderer? renderer;

  Vector3 translation = Vector3(0.0, 0.0, 0.0);
  Vector3 rotation = Vector3(90, 0.0, 0.0);
  Vector3 scale = Vector3(20.0, 20.0, 20.0);

  @override
  void initState() {
    super.initState();

    // the min and max translation.
    double translationMin = -200.0;
    double translationMax = 200.0;

    // the min and max rotation.
    double rotationMin = 0.0;
    double rotationMax = 360.0;

    // the min and max scale.
    double scaleMin = 1.0;
    double scaleMax = 100.0;

    // init control manager.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'tx', min: translationMin, max: translationMax, value: translation.x));
    controlsManager!.add(TransformControl(name: 'ty', min: translationMin, max: translationMax, value: translation.y));
    controlsManager!.add(TransformControl(name: 'tz', min: translationMin, max: translationMax, value: translation.z));

    controlsManager!.add(TransformControl(name: 'rx', min: rotationMin, max: rotationMax, value: rotation.x));
    controlsManager!.add(TransformControl(name: 'ry', min: rotationMin, max: rotationMax, value: rotation.y));
    controlsManager!.add(TransformControl(name: 'rz', min: rotationMin, max: rotationMax, value: rotation.z));

    controlsManager!.add(TransformControl(name: 'sx', min: scaleMin, max: scaleMax, value: scale.x));
    controlsManager!.add(TransformControl(name: 'sy', min: scaleMin, max: scaleMax, value: scale.y));
    controlsManager!.add(TransformControl(name: 'sz', min: scaleMin, max: scaleMax, value: scale.z));
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
        rotation.x = control.value;
        break;
      case 'ry':
        rotation.y = control.value;
        break;
      case 'rz':
        rotation.z = control.value;
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
        print('Unknown control name: ${control.name}');
        break;
    }
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
    camera!.setPosition(Vector3(0, 0, 300));

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
    edgedBoxMesh.setPosition(Vector3(0, 0, 0));
    edgedBoxMesh.setRotation(Vector3(90, 0, 0));
    edgedBoxMesh.setScale(Vector3(50, 50, 50));
    scene.add(edgedBoxMesh);
  }

  /// Render's the scene.
  render() {
    int index = scene.children.length - 1;
    scene.children[index].setPosition(translation);
    scene.children[index].setRotation(rotation.addScalar(0.2));
    scene.children[index].setScale(scale);

    renderer!.render(scene, camera!);
  }
}
