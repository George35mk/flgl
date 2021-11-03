import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:image/image.dart' as image;

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/transform_control.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controls/gl_controls.dart';

import 'package:flgl/flgl_3d.dart';
import 'package:flutter/services.dart' show rootBundle;

class Flutter3DAssetsTexture extends StatefulWidget {
  const Flutter3DAssetsTexture({Key? key}) : super(key: key);

  @override
  _Flutter3DAssetsTextureState createState() => _Flutter3DAssetsTextureState();
}

class _Flutter3DAssetsTextureState extends State<Flutter3DAssetsTexture> {
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
  Vector3 scale = Vector3(1.0, 1.0, 1.0);

  @override
  void initState() {
    super.initState();

    // init control manager.
    controlsManager = TransformControlsManager({});
    controlsManager!.add(TransformControl(name: 'tx', min: -100.0, max: 100.0, value: 0));
    controlsManager!.add(TransformControl(name: 'ty', min: -100.0, max: 100.0, value: 0));
    controlsManager!.add(TransformControl(name: 'tz', min: -500.0, max: 100.0, value: 0));

    controlsManager!.add(TransformControl(name: 'rx', min: 0, max: 360, value: 90));
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
      const Duration(milliseconds: 50),
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
    // render();
  }

  Future<Uint8List> getImageData() async {
    ByteData bytes = await rootBundle.load('assets/images/star.jpg');
    Uint8List imageData = Uint8List.view(bytes.buffer);
    return imageData;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    var imgData = getImageData();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter 3D: Assets texture example"),
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
          ),

          // Positioned(
          //   top: 10,
          //   left: 10,
          //   // child: Image.asset('assets/images/star.jpg'),
          //   child: FutureBuilder(
          //     future: imgData,
          //     builder: (context, snapshot) {
          //       print('data: ${snapshot.data}');
          //       if (snapshot.data == null) {
          //         return Container();
          //       } else {
          //         return Image.memory(snapshot.data as dynamic);
          //       }
          //     },
          //   ),
          // ),

          // GLControls(),
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() async {
    // colors
    Color redColor = Color(1, 0, 0, 1);
    Color greenColor = Color(0, 1, 0, 1);
    Color blueColor = Color(0, 0, 1, 1);
    Color whiteColor = Color(1, 1, 1, 1);

    // Setup the camera.
    camera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
    camera!.setPosition(Vector3(0, 0, 20));

    // Setup the renderer.
    renderer = Renderer(gl, flgl);
    renderer!.setBackgroundColor(0, 0, 0, 1);
    renderer!.setWidth(width);
    renderer!.setHeight(height);
    renderer!.setDPR(dpr);

    // Create a plane mesh 1
    PlaneGeometry planeGeometry = PlaneGeometry();
    MeshBasicMaterial material2 = MeshBasicMaterial(
      color: redColor,
    );
    Mesh planeMesh = Mesh(gl, planeGeometry, material2);
    planeMesh.setPosition(Vector3(0, 0, 0));
    planeMesh.setRotation(Vector3(90, 0, 0));
    planeMesh.setScale(Vector3(2, 2, 1));
    scene.add(planeMesh);

    // Create a plane mesh 2
    PlaneGeometry planeGeometry2 = PlaneGeometry();
    MeshBasicMaterial material3 = MeshBasicMaterial(color: greenColor);
    Mesh planeMesh2 = Mesh(gl, planeGeometry2, material3);
    planeMesh2.setPosition(Vector3(-2, 0, 0));
    planeMesh2.setRotation(Vector3(90, 0, 0));
    planeMesh2.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh2);

    TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/a.png');

    // Create a plane mesh 3
    PlaneGeometry planeGeometry4 = PlaneGeometry(textureInfo.width.toDouble(), textureInfo.height.toDouble(), 2, 2);
    MeshBasicMaterial material5 = MeshBasicMaterial(
      color: whiteColor,
      map: textureInfo.imageData,
      mapWidth: textureInfo.width,
      mapHeigth: textureInfo.height,
    );
    Mesh planeMesh4 = Mesh(gl, planeGeometry4, material5);
    planeMesh4.setPosition(Vector3(0, 0, 0));
    planeMesh4.setRotation(Vector3(90, 0, 0));
    planeMesh4.setScale(Vector3(1, 1, 1));
    scene.add(planeMesh4);
  }

  /// Render's the scene.
  render() {
    // print('Render runining...');

    int index = scene.children.length - 1;
    scene.children[index].setPosition(translation);
    // scene.children[index].setRotation(rotation.addScalar(0.01));
    scene.children[index].setRotation(rotation);
    scene.children[index].setScale(scale);

    renderer!.render(scene, camera!);
  }
}
