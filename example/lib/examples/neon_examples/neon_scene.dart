import 'dart:async';
import 'dart:math' as math;

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
  PerspectiveCamera? perspectiveCamera;
  OrthographicCamera? orthographicCamera;

  NeonRenderer? neonRenderer;
  Camera? activeCamera;

  OrbitControls? orbitControls;

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

  // scale vars
  double _finalScale = 20;
  final double _baseScale = 20;
  double _newScale = 1;
  double _previewsScale = 1;

  // pan vars
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  Offset _finalOffset = Offset.zero;

  //
  double camX = 0;
  double camY = 0;
  double camZ = 0;
  double direction = 0;
  double deltaX = 0;
  double deltaY = 0;


  // void handleCameraRotation(Camera camera, double dx, double dy) {
  //   if (camera is OrthographicCamera) {
  //     double radious = 180;
  //     double speedFactor = 0.01;

  //     camX = (math.sin(dx * speedFactor) * radious);
  //     camY = (math.cos(dy * speedFactor) * 360);
  //     camZ = (math.cos(dx * speedFactor) * radious);

  //     camX = MathUtils.degToRad(camX);
  //     camY = MathUtils.degToRad(camY);
  //     camZ = MathUtils.degToRad(camZ);

  //     activeCamera!.setPosition(Vector3(-camX, camY, camZ)); // rotate around y axis // Rotate on x, y and z axis works!!!
      
  //     // camera.viewMatrix = M4.inverse(newCameraViewMatrix);
  //   } else if (camera is PerspectiveCamera) {
  //     double radious = 500;
  //     double speedFactor = 0.01;

  //     camX = (math.sin(dx * speedFactor) * radious);
  //     camY = (math.cos(dy * speedFactor) * 360);
  //     camZ = (math.cos(dx * speedFactor) * radious);

  //     camX = MathUtils.degToRad(camX);
  //     camY = MathUtils.degToRad(camY);
  //     camZ = MathUtils.degToRad(camZ);

  //     activeCamera!.setPosition(Vector3(-camX, camY, camZ));
  //   }
  // }

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

              _initialFocalPoint = scaleStartDetails.focalPoint;
              _previewsScale = _newScale;
              // print('scaleStartDetails: $scaleStartDetails');
            },
            onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {

              // print('scaleUpdateDetails: $scaleUpdateDetails');
              direction = scaleUpdateDetails.focalPoint.direction;
              deltaX = scaleUpdateDetails.delta.dx;
              deltaY = scaleUpdateDetails.delta.dy;

              setState(() {
                // use the pan
                if (pointersCount == 1 && activeCamera is OrthographicCamera || activeCamera is PerspectiveCamera) {
                  _sessionOffset = scaleUpdateDetails.focalPoint - _initialFocalPoint;

                  _finalOffset = _offset + _sessionOffset;
                  // handleCameraRotation(activeCamera!, finalOffset.dx, finalOffset.dy);
                  if (orbitControls != null) {
                    orbitControls!.orbit(_finalOffset.dx, _finalOffset.dy);
                  }
                }
              });

              // don't update the UI if the scale didn't change
              if (scaleUpdateDetails.scale == 1.0) {
                return;
              }

              setState(() {
                _newScale = (_previewsScale * scaleUpdateDetails.scale).clamp(0.5, 5.0);
                _finalScale = _newScale * _baseScale;

                // use the zoom.
                // if (activeCamera is OrthographicCamera) {
                //   orthographicCamera!.setOrthographic(_finalScale * 8, -1, 1000);
                // }
                if (orbitControls != null) {
                  orbitControls!.zoom(_finalScale);
                }
              });

            },
            onScaleEnd: (details) {
              setState(() {
                _offset += _sessionOffset;
                // _sessionOffset = Offset.zero;
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
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('x: $x', style: const TextStyle(color: Colors.white),),
                    Text('y: $y', style: const TextStyle(color: Colors.white),),
                    Text('_finalScale: $_finalScale', style: const TextStyle(color: Colors.white),),
                    Text('_finalOffset: $_finalOffset', style: const TextStyle(color: Colors.white),),
                    Text('pointersCount: $pointersCount', style: const TextStyle(color: Colors.white),),
                    Text('_sessionOffset: $_sessionOffset', style: const TextStyle(color: Colors.white),),
                    Text('_offset: $_offset', style: const TextStyle(color: Colors.white),),
                    activeCamera != null ? Text('activeCamera.position.x: ${activeCamera!.position.x.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                    activeCamera != null ? Text('activeCamera.position.y: ${activeCamera!.position.y.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                    activeCamera != null ? Text('activeCamera.position.z: ${activeCamera!.position.z.abs()}', style: const TextStyle(color: Colors.white),) : Container(),
                    Text('camX: ${MathUtils.radToDeg(camX).toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white),),
                    Text('camY: ${MathUtils.radToDeg(camY).toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white),),
                    Text('camZ: ${MathUtils.radToDeg(camZ).toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white),),
                    Text('Direction: $direction', style: const TextStyle(color: Colors.white),),
                    Text('deltaX: $deltaX', style: const TextStyle(color: Colors.white),),
                    Text('deltaY: $deltaY', style: const TextStyle(color: Colors.white),),
                    // Text('yaw: $yaw', style: const TextStyle(color: Colors.white),),
                    // Text('pitch: $pitch', style: const TextStyle(color: Colors.white),),
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
    perspectiveCamera!.setPosition(Vector3(0, 0, 500));

    // init texture info.
    TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/pepsi_transparent.png');

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

    neonRenderer = NeonRenderer(flgl, gl);
    neonRenderer!.width = width;
    neonRenderer!.height = height;
    neonRenderer!.dpr = dpr;
    neonRenderer!.setClearColor(Color(0, 0, 0, 1));
    neonRenderer!.init();

    // activeCamera = orthographicCamera;
    activeCamera = perspectiveCamera;
    orbitControls = OrbitControls(activeCamera);
  }

  render() {
    if (neonRenderer != null && activeCamera != null) {

      setState(() {
        x += 0.02;
        y += 0.90;
        z += 0.90;
      });
      // scene.children[0].setRotation(Vector3(x, y, z));
      // scene.children[1].setRotation(Vector3(x, -y, -z));

      // if (activeCamera is OrthographicCamera) {
      //   orthographicCamera!.setOrthographic(x * 8, -1, 1000);
      // }
      neonRenderer!.render(scene, activeCamera!);

    }
  }
}

