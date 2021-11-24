import 'dart:async';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/common/camera_projection_toggle_menu.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonCubeExample extends StatefulWidget {
  const NeonCubeExample({Key? key}) : super(key: key);

  @override
  _NeonCubeExampleState createState() => _NeonCubeExampleState();
}

class _NeonCubeExampleState extends State<NeonCubeExample> {

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
  PerspectiveCamera? perspectiveCamera;
  OrthographicCamera? orthographicCamera;

  NeonRenderer? neonRenderer;
  Camera? activeCamera;

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

  

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neon: Cube example"),
      ),
      body: Stack(
        children: [
          FLGLViewport(
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
                  })
                },
              ),
            ),
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
    orthographicCamera!.setPosition(Vector3(0, 0, 100));

    // init perspective camera.
    perspectiveCamera = PerspectiveCamera(45, (width * dpr) / (height * dpr), 1, 2000);
    perspectiveCamera!.name = 'PerspectiveCamera';
    perspectiveCamera!.setPosition(Vector3(0, 0, 300));

    // init texture info.
    // TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/pepsi_transparent.png');

    var geometry = NeonBoxGeometry();
    var material = NeonMeshBasicMaterial(
      color: Color(1, 1, 1, 0.8),
      // map: textureInfo,
    );
    var mesh = NeonMesh(gl, geometry, material);
    mesh.name = 'Quad';
    mesh.setScale(Vector3(100, 100, 100));

    scene.add(mesh);

    neonRenderer = NeonRenderer(flgl, gl);
    neonRenderer!.width = width;
    neonRenderer!.height = height;
    neonRenderer!.dpr = dpr;
    neonRenderer!.setClearColor(Color(0, 0, 0, 1));
    neonRenderer!.init();

    // activeCamera = orthographicCamera;
    activeCamera = perspectiveCamera;
  }

  render() {
    if (neonRenderer != null && activeCamera != null) {
      x += 0.90;
      y += 0.90;
      z += 0.90;
      scene.children[0].setRotation(Vector3(x, y, z));
      neonRenderer!.render(scene, activeCamera!);
    }
  }
}

