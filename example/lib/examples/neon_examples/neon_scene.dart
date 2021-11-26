import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/common/camera_projection_toggle_menu.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonSceneExample extends StatefulWidget {
  const NeonSceneExample({Key? key}) : super(key: key);

  @override
  _NeonSceneExampleState createState() => _NeonSceneExampleState();
}

class _NeonSceneExampleState extends State<NeonSceneExample> {

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

  NeonScene scene = NeonScene();
  Camera? activeCamera;
  PerspectiveCamera? perspectiveCamera;
  OrthographicCamera? orthographicCamera;
  OrbitControls? orbitControls;
  NeonRenderer? neonRenderer;


  double x = 0;
  double y = 0;
  double z = 0;

  List<bool> selectedCameras = [false, true];

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
      const Duration(milliseconds: 50),
      (Timer t) => {
        if (!flgl.isDisposed)
          {
            render(),
          }
      },
    );
  }

  int pointersCount = 0;


  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neon: Scene example"),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: (ScaleStartDetails scaleStartDetails) {
              setState(() {
                pointersCount = scaleStartDetails.pointerCount;
              });

              // orbit
              if (pointersCount == 1) {
                orbitControls!.onOrbitStart(scaleStartDetails.focalPoint);
              }

              // zoom
              if (pointersCount == 2) {
                orbitControls!.onZoomStart();
              }
            },
            onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
              setState(() {
                // use the pan
                if (pointersCount == 1) {
                  if (activeCamera is OrthographicCamera || activeCamera is PerspectiveCamera) {
                    if (orbitControls != null) {
                      orbitControls!.onOrbit(scaleUpdateDetails.focalPoint);
                    }
                  }
                }
              });

              // don't update the UI if the scale didn't change
              if (scaleUpdateDetails.scale == 1.0) {
                return;
              }

              setState(() {
                if (orbitControls != null) {
                  orbitControls!.onZoom(scaleUpdateDetails.scale);
                }
              });

            },
            onScaleEnd: (details) {
              setState(() {
                if (orbitControls != null) {
                  if (pointersCount == 1) {
                    orbitControls!.onOrbitStop();
                  }

                  if (pointersCount == 2) {
                    orbitControls!.onZoomStop();
                  }
                }
              });
            },
            child: FLGLViewport(
              width: width.toInt() + 1,
              height: height.toInt(),
              onInit: (Flgl _flgl) {
                setState(() {
                  flgl = _flgl;
                  gl = flgl.gl;

                  initScene();
                  startRenderLoop();
                });
              },
            ),
          ),
          
          if (activeCamera != null && scene != null)
            Positioned(
              width: 420,
              top: 10,
              right: 10,
              child: FLGLControls(camera: activeCamera!, scene: scene),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: CameraProjectionToggleMenu(
                options: selectedCameras, 
                onChange: (index) => {
                  setState(() {
                    if (index == 0) {
                      activeCamera = orthographicCamera;
                    } else {
                      activeCamera = perspectiveCamera;
                    }

                    if (orbitControls != null) {
                      orbitControls!.setActiveCamera(activeCamera!);
                    }
                  })
                },
              ),
            ),
            Positioned(
              top: 80,
              left: 10,
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    orbitControls != null ? Text('Camera type: ${orbitControls!.camera is OrthographicCamera ? "Orthographic" : "Perspective"}', style: const TextStyle(color: Colors.white)) : Container(),
                    orbitControls != null ? Text('phi: ${MathUtils.radToDeg(orbitControls!.phi).toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white)) : Container(),
                    orbitControls != null ? Text('theta: ${MathUtils.radToDeg(orbitControls!.theta).toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white)) : Container(),
                    orbitControls != null ? Text('distanceToOrigin: ${orbitControls!.camera.distanceToOrigin.toStringAsFixed(1)}mm', style: const TextStyle(color: Colors.white)) : Container(),
                    activeCamera != null ? Text('activeCamera.position.x: ${activeCamera!.position.x.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                    activeCamera != null ? Text('activeCamera.position.y: ${activeCamera!.position.y.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                    activeCamera != null ? Text('activeCamera.position.z: ${activeCamera!.position.z.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() async {

    // init orthographic camera.
    var aspect = dpr; // 1.5
    orthographicCamera = OrthographicCamera((width * aspect) / -2, (width * aspect) / 2, (height * aspect) / -2, (height * aspect) / 2, -1, 1000);
    orthographicCamera!.name = 'OrthographicCamera';
    orthographicCamera!.setPosition(Vector3(0, 0, 300));
    orthographicCamera!.setViewportSize(width, height);
    orthographicCamera!.setOrthographic(250, -1, 1000);

    // init perspective camera.
    perspectiveCamera = PerspectiveCamera(45, (width * dpr) / (height * dpr), 1, 2000);
    perspectiveCamera!.name = 'PerspectiveCamera';
    perspectiveCamera!.setPosition(Vector3(0, 20, 500));

    // init texture info.
    // TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/pepsi_transparent.png');

    // var geometry = NeonBoxGeometry();
    // var material = NeonMeshBasicMaterial(
    //   color: Color(1, 1, 1, 0.8),
    //   map: textureInfo,
    // );
    // var mesh = NeonMesh(gl, geometry, material);
    // mesh.name = 'Box 1';
    // mesh.setPosition(Vector3(0, 0, 0));
    // mesh.setScale(Vector3(100, 100, 100));
    // scene.add(mesh);


    // Cone mesh setup.
    var geometry1 = NeonConeGeometry();
    var material1 = NeonMeshBasicMaterial(
      color: Color(1, 1, 1, 1),
      // map: textureInfo,
    );
    var mesh1 = NeonMesh(gl, geometry1, material1);
    mesh1.name = 'Cone';
    mesh1.setScale(Vector3(1, 1, 1));
    mesh1.setPosition(Vector3(1, 50, 1));
    scene.add(mesh1);


    // Box mesh - textures only colors on ecah side.
    var geometry2 = NeonBoxGeometry();
    var material2 = NeonMeshBasicMaterial(
      color: Color(1, 1, 1, 0.8),
      // map: textureInfo,
    );
    var mesh2 = NeonMesh(gl, geometry2, material2);
    mesh2.name = 'Box 2';
    mesh2.setScale(Vector3(100, 100, 100));
    mesh2.setPosition(Vector3(0, 0, 0));
    scene.add(mesh2);

    // Setup renderer.
    neonRenderer = NeonRenderer(flgl, gl);
    neonRenderer!.width = width;
    neonRenderer!.height = height;
    neonRenderer!.dpr = dpr;
    neonRenderer!.setClearColor(Color(0, 0, 0, 1));
    neonRenderer!.init();

    // activeCamera = orthographicCamera;
    activeCamera = perspectiveCamera;
    orbitControls = OrbitControls(activeCamera!);
  }

  render() {
    if (neonRenderer != null && activeCamera != null) {

      // setState(() {
      //   x += 0.02;
      //   y += 0.90;
      //   z += 0.90;
      // });
      // scene.children[0].setRotation(Vector3(x, y, z));
      // scene.children[1].setRotation(Vector3(x, -y, -z));
     
      neonRenderer!.render(scene, activeCamera!);

    }
  }
}

