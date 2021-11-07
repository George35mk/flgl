import 'dart:async';
import 'dart:math' as math;

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Flutter3DAssetsTexture extends StatefulWidget {
  const Flutter3DAssetsTexture({Key? key}) : super(key: key);

  @override
  _Flutter3DAssetsTextureState createState() => _Flutter3DAssetsTextureState();
}

class _Flutter3DAssetsTextureState extends State<Flutter3DAssetsTexture> {
  /// Set this to true when the FLGLViewport initialized.
  bool initialized = false;
  bool isReady = false;

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

    // dispose all the textures.
    scene.dispose(gl);

    // dispose FBO and DBO
    flgl.dispose();

    super.dispose();
  }

  // Draw 50 frames per second.
  void startRenderLoop() {
    timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (Timer t) => {
        render(),
      },
    );
  }

  double roundDouble(double value, int places) {
    double mod = math.pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    // int pointerCount = 0;
    // Offset startOffset = Offset(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter 3D: Assets texture example"),
      ),
      body: Stack(
        children: [
          // GestureDetector(
          //   onScaleStart: (details) {
          //     pointerCount = details.pointerCount;
          //     startOffset = details.localFocalPoint;
          //   },
          //   onScaleUpdate: (ScaleUpdateDetails details) {
          //     bool isPos = details.scale > 1 ? true : false;

          //     // if user use 2 fingers.
          //     if (pointerCount == 2) {
          //       if (isPos) {
          //         // print('POSITIVE');
          //         if (camera!.position.z > 300) {
          //           camera!.position.z -= 10 * 0.90;
          //         }
          //       } else {
          //         // print('NEGATIVE');
          //         camera!.position.z += 10 * 0.90;
          //       }
          //       camera!.setPosition(Vector3(camera!.position.x, camera!.position.y, camera!.position.z));
          //     } else if (pointerCount == 1) {
          //       Offset x = details.localFocalPoint - startOffset;
          //       var dx = -x.dx * 0.9;
          //       var dy = x.dy * 0.9;
          //       camera!.setPosition(Vector3(dx, dy, camera!.position.z));
          //     }
          //   },
          //   child: FLGLViewport(
          //     width: width.toInt() + 1,
          //     height: height.toInt(),
          //     onInit: (Flgl _flgl) {
          //       setState(() {
          //         initialized = true;
          //         flgl = _flgl;
          //         gl = flgl.gl;

          //         initScene();
          //         // render();
          //         startRenderLoop();
          //       });
          //     },
          //   ),
          // ),
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
          if (isReady && (camera != null && scene != null))
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
    Color whiteColor = Color(1, 1, 1, 1);
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

    // var activeTextures = gl.getParameter(gl.ACTIVE_TEXTURE);
    // print('activeTextures: $activeTextures'); // returns "33984" (0x84C0, gl.TEXTURE0 enum value)

    // Create a plane mesh 3
    TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/a.png');
    PlaneGeometry planeGeometry3 = PlaneGeometry(textureInfo.width.toDouble(), textureInfo.height.toDouble(), 2, 2);
    MeshBasicMaterial material3 = MeshBasicMaterial(
      color: whiteColor,
      map: textureInfo.imageData,
      mapWidth: textureInfo.width,
      mapHeigth: textureInfo.height,
    );
    Mesh planeMesh4 = Mesh(gl, planeGeometry3, material3);
    planeMesh4.name = 'plane';
    planeMesh4.setPosition(Vector3(0, 0, 0));
    planeMesh4.setRotation(Vector3(90, 0, 0));
    planeMesh4.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh4);

    // Create an Edged Box Geometry
    EdgedBoxGeometry edgedBoxGeometry = EdgedBoxGeometry();
    MeshBasicMaterial edgeMat = MeshBasicMaterial(color: lightGreenColor);
    Mesh edgedBoxMesh = Mesh(gl, edgedBoxGeometry, edgeMat);
    edgedBoxMesh.name = 'box';
    edgedBoxMesh.setPosition(Vector3(0, 0, 0));
    edgedBoxMesh.setRotation(Vector3(0, 0, 0));
    edgedBoxMesh.setScale(Vector3(50, 50, 50));
    scene.add(edgedBoxMesh);

    // activeTextures = gl.getParameter(gl.ACTIVE_TEXTURE);
    // print(activeTextures);

    setState(() {
      isReady = true;
    });
  }

  render() {
    renderer!.render(scene, camera!);
  }
}
