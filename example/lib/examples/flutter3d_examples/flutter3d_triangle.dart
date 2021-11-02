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
    TriangleGeometry triangleGeometry = TriangleGeometry();
    MeshBasicMaterial material0 = MeshBasicMaterial(
      color: Color(0.0, 1.0, 0.0, 1.0),
    );
    Mesh triangleMesh = Mesh(gl, triangleGeometry, material0);
    triangleMesh.setPosition(Vector3(0, 0, 0));
    triangleMesh.setScale(Vector3(1, 1, 1));
    scene.add(triangleMesh);

    // Add the second mesh.
    TriangleGeometry triangleGeometry2 = TriangleGeometry();
    MeshBasicMaterial material1 = MeshBasicMaterial(
      color: Color(1.0, 0.0, 0.0, 1.0),
    );
    Mesh triangleMesh2 = Mesh(gl, triangleGeometry2, material1);
    triangleMesh2.setPosition(Vector3(-0.7, 0, 0));
    triangleMesh2.setScale(Vector3(1, 1, 1));
    scene.add(triangleMesh2);

    // Create a plane mesh 1
    PlaneGeometry planeGeometry = PlaneGeometry();
    MeshBasicMaterial material2 = MeshBasicMaterial(
      color: Color(1.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh = Mesh(gl, planeGeometry, material2);
    planeMesh.setPosition(Vector3(2, 0, 0));
    planeMesh.setScale(Vector3(1, 1, 0));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry();
    MeshBasicMaterial material3 = MeshBasicMaterial(
      color: Color(0.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh2 = Mesh(gl, planeGeometry2, material3);
    planeMesh2.setPosition(Vector3(-2, 0, 0));
    planeMesh2.setScale(Vector3(1, 1, 0));
    scene.add(planeMesh2);

    // Create a plane mesh 3
    PlaneGeometry planeGeometry3 = PlaneGeometry();
    MeshBasicMaterial material4 = MeshBasicMaterial(
      color: Color(0.3, 0.0, 1.0, 1.0),
    );
    Mesh planeMesh3 = Mesh(gl, planeGeometry3, material4);
    planeMesh3.setPosition(Vector3(-2, -2, 0));
    planeMesh3.setScale(Vector3(1, 1, 0));
    scene.add(planeMesh3);

    // Create a sphere mesh
    SphereGeometry sphereGeometry = SphereGeometry(0.5, 12, 6);
    MeshBasicMaterial spherematerial = MeshBasicMaterial(
      color: Color(1.0, 1.0, 0.0, 1.0),
    );
    Mesh sphereMesh = Mesh(gl, sphereGeometry, spherematerial);
    sphereMesh.setPosition(Vector3(-4, 0, 0));
    sphereMesh.setScale(Vector3(1, 1, 1));
    scene.add(sphereMesh);

    // Create box mesh.
    BoxGeometry boxGeometry = BoxGeometry(0.5);
    MeshBasicMaterial material5 = MeshBasicMaterial(
      color: Color(1.0, 1.0, 0.0, 1.0),
    );
    Mesh boxMesh = Mesh(gl, boxGeometry, material5);
    boxMesh.setPosition(Vector3(4, 0, 0));
    boxMesh.setScale(Vector3(1, 1, 1));
    scene.add(boxMesh);

    // Create box mesh.
    BoxGeometry boxGeometry1 = BoxGeometry();
    MeshBasicMaterial material6 = MeshBasicMaterial(
      color: Color(1, 0.3, 1, 1.0),
    ); // Magenta / Fuchsia
    Mesh boxMesh1 = Mesh(gl, boxGeometry1, material6);
    boxMesh1.setPosition(Vector3(-2, 3, 0));
    boxMesh1.setScale(Vector3(1, 1, 1));
    scene.add(boxMesh1);

    // Create a cone mesh.
    ConeGeometry coneGeometry = ConeGeometry(2, 0, 2, 4, 1, true, false);
    MeshBasicMaterial coneMaterial = MeshBasicMaterial(
      color: Color(0.2, 0.7, 0.2, 1.0),
    );
    Mesh coneMesh = Mesh(gl, coneGeometry, coneMaterial);
    coneMesh.setPosition(Vector3(2, 3, 0));
    coneMesh.setScale(Vector3(1, 1, 1));
    scene.add(coneMesh);

    // Create a cylinder mesh.
    CylinderGeometry cylinderGeometry = CylinderGeometry(1, 4, 8, 5, true, true);
    MeshBasicMaterial cylinderMaterial = MeshBasicMaterial(
      color: Color(0.2, 0.3, 0.9, 1.0),
    );
    Mesh cylinderMesh = Mesh(gl, cylinderGeometry, cylinderMaterial);
    cylinderMesh.setPosition(Vector3(2, 3, 0));
    cylinderMesh.setScale(Vector3(1, 1, 1));
    scene.add(cylinderMesh);
  }

  /// Render's the scene.
  render() {
    // print('Render runining...');

    int index = scene.children.length - 1;
    scene.children[index].setPosition(translation);
    scene.children[index].setRotation(rotation.addScalar(0.01));
    scene.children[index].setScale(scale);

    renderer!.render(scene, camera!);
  }
}
