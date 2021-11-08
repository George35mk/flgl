import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Flutter3DMultipleGeometries extends StatefulWidget {
  const Flutter3DMultipleGeometries({Key? key}) : super(key: key);

  @override
  _Flutter3DMultipleGeometriesState createState() => _Flutter3DMultipleGeometriesState();
}

class _Flutter3DMultipleGeometriesState extends State<Flutter3DMultipleGeometries> {
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
    scene.dispose(gl);
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
        title: const Text("Flutter 3D: Multiple geometries"),
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

    // Add the first mesh in the scene graph.
    TriangleGeometry triangleGeometry = TriangleGeometry();
    MeshBasicMaterial material0 = MeshBasicMaterial(
      color: Color(0.0, 1.0, 0.0, 1.0),
    );
    Mesh triangleMesh = Mesh(gl, triangleGeometry, material0);
    triangleMesh.name = 'triangle 1';
    triangleMesh.setPosition(Vector3(0, -50, 0));
    triangleMesh.setScale(Vector3(50, 50, 50));
    scene.add(triangleMesh);

    // Add the second mesh.
    TriangleGeometry triangleGeometry2 = TriangleGeometry();
    MeshBasicMaterial material1 = MeshBasicMaterial(
      color: Color(1.0, 0.0, 0.0, 1.0),
    );
    Mesh triangleMesh2 = Mesh(gl, triangleGeometry2, material1);
    triangleMesh2.name = 'triangle 2';
    triangleMesh2.setPosition(Vector3(0, -50, 25));
    triangleMesh2.setScale(Vector3(25, 25, 1));
    scene.add(triangleMesh2);

    // Create a plane mesh 1
    PlaneGeometry planeGeometry = PlaneGeometry(50, 50);
    MeshBasicMaterial material2 = MeshBasicMaterial(
      color: Color(1.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh = Mesh(gl, planeGeometry, material2);
    planeMesh.name = 'plane 1';
    planeMesh.setPosition(Vector3(0, 0, 0));
    planeMesh.setRotation(Vector3(90, 0, 0));
    planeMesh.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry(30, 30);
    MeshBasicMaterial material3 = MeshBasicMaterial(
      color: Color(0.0, 1.0, 1.0, 1.0),
    );
    Mesh planeMesh2 = Mesh(gl, planeGeometry2, material3);
    planeMesh2.name = 'plane 2';
    planeMesh2.setPosition(Vector3(0, 0, 20));
    planeMesh2.setRotation(Vector3(90, 0, 0));
    planeMesh2.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh2);

    // Create a plane mesh 3
    PlaneGeometry planeGeometry3 = PlaneGeometry(15, 15);
    MeshBasicMaterial material4 = MeshBasicMaterial(
      color: Color(0.3, 0.0, 1.0, 1.0),
    );
    Mesh planeMesh3 = Mesh(gl, planeGeometry3, material4);
    planeMesh3.name = 'plane 3';
    planeMesh3.setPosition(Vector3(0, 0, 40));
    planeMesh3.setRotation(Vector3(90, 0, 0));
    planeMesh3.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh3);

    // Create a sphere mesh
    SphereGeometry sphereGeometry = SphereGeometry(25, 12, 6);
    MeshBasicMaterial spherematerial = MeshBasicMaterial(
      color: Color(1.0, 1.0, 0.0, 1.0),
    );
    Mesh sphereMesh = Mesh(gl, sphereGeometry, spherematerial);
    sphereMesh.name = 'sphere 1';
    sphereMesh.setPosition(Vector3(60, 0, 0));
    sphereMesh.setScale(Vector3(1, 1, 1));
    scene.add(sphereMesh);

    // Create box mesh.
    BoxGeometry boxGeometry1 = BoxGeometry(0.5);
    MeshBasicMaterial boxMaterial1 = MeshBasicMaterial(
      color: Color(1.0, 1.0, 0.0, 1.0),
    );
    Mesh boxMesh = Mesh(gl, boxGeometry1, boxMaterial1);
    boxMesh.name = 'box 1';
    boxMesh.setPosition(Vector3(-45, 0, 0));
    boxMesh.setScale(Vector3(50, 50, 50));
    scene.add(boxMesh);

    // Create box mesh.
    BoxGeometry boxGeometry2 = BoxGeometry();
    MeshBasicMaterial boxMaterial2 = MeshBasicMaterial(
      color: Color(1, 0.3, 1, 1.0),
    ); // Magenta / Fuchsia
    Mesh boxMesh2 = Mesh(gl, boxGeometry2, boxMaterial2);
    boxMesh2.name = 'box 2';
    boxMesh2.setPosition(Vector3(-87, 75, 0));
    boxMesh2.setScale(Vector3(50, 50, 50));
    scene.add(boxMesh2);

    // Create a cone mesh.
    ConeGeometry coneGeometry = ConeGeometry(30, 0, 50, 4, 1, true, false);
    MeshBasicMaterial coneMaterial = MeshBasicMaterial(
      color: Color(0.2, 0.7, 0.2, 1.0),
    );
    Mesh coneMesh = Mesh(gl, coneGeometry, coneMaterial);
    coneMesh.name = 'cone';
    coneMesh.setPosition(Vector3(-84, -45, 0));
    coneMesh.setScale(Vector3(1, 1, 1));
    scene.add(coneMesh);

    // Create a cylinder mesh.
    CylinderGeometry cylinderGeometry = CylinderGeometry(20, 40, 8, 5, true, true);
    MeshBasicMaterial cylinderMaterial = MeshBasicMaterial(
      color: Color(0.2, 0.3, 0.9, 1.0),
    );
    Mesh cylinderMesh = Mesh(gl, cylinderGeometry, cylinderMaterial);
    cylinderMesh.name = 'cylinder';
    cylinderMesh.setPosition(Vector3(-160, 0, 0));
    cylinderMesh.setScale(Vector3(1, 1, 1));
    scene.add(cylinderMesh);
  }

  render() {
    renderer!.render(scene, camera!);
  }
}
