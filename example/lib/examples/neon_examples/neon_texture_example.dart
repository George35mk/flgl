import 'dart:async';
import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonTextureExample extends StatefulWidget {
  const NeonTextureExample({Key? key}) : super(key: key);

  @override
  _NeonTextureExampleState createState() => _NeonTextureExampleState();
}

class _NeonTextureExampleState extends State<NeonTextureExample> {
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

  // new stuff
  late VertexArray va;
  late VertexBuffer vb;
  late VertexBufferLayout layout;
  late IndexBuffer ib;
  late Shader shader;
  late NeonRenderer hazelRenderer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    // dispose
    va.dispose();
    ib.dispose();
    vb.dispose();
    shader.dispose();
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
        title: const Text("Neon: Texture"),
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
  initScene() async {
    List<double> positions = [
      -0.5, -0.5, 0.0, 0.0, // 0
      0.5, -0.5, 1.0, 0.0, // 1
      0.5, 0.5, 1.0, 1.0, // 2
      -0.5, 0.5, 0.0, 1.0, // 3
    ];

    List<int> indices = [
      0, 1, 2, //
      2, 3, 0, //
    ];

    // use this when you using png textures.
    gl.blendFunc(GL_SRC1_ALPHA_EXT, GL_ONE_MINUS_SRC_ALPHA);

    va = VertexArray(gl);
    vb = VertexBuffer(gl, Float32List.fromList(positions), 4 * 4);

    // init vertex buffer layout.
    layout = VertexBufferLayout();
    layout.pushFloat(2);
    layout.pushFloat(2);
    va.addBuffer(vb, layout);

    // init index buffer.
    ib = IndexBuffer(gl, Uint16List.fromList(indices), 6);

    /// The orthographic projection matrix.
    // List<double> projection = M4.orthographic(-2.0, 2.0, -1.0, 1.0, -1.0, 1.0);
    var aspect = dpr; // 1.5
    List<double> projection = M4.orthographic(
        (width * aspect) / -2, (width * aspect) / 2, (height * aspect) / -2, (height * aspect) / 2, -1, 1);

    // var cameraMatrix = M4.lookAt(
    //   [1, 1, 50],
    //   [1, 1, 1],
    //   [0, 1, 0],
    // );
    // var viewMatrix = M4.inverse(cameraMatrix);
    var viewMatrix = M4.translate(M4.identity(), 0, 0, 0);

    var modelMatrix = M4.translate(M4.identity(), 0, 0, 0);
    modelMatrix = M4.xRotate(modelMatrix, MathUtils.radToDeg(0));
    modelMatrix = M4.yRotate(modelMatrix, MathUtils.radToDeg(0));
    modelMatrix = M4.zRotate(modelMatrix, MathUtils.radToDeg(90));
    modelMatrix = M4.scale(modelMatrix, 500, 500, 1);

    var vp = M4.multiply(projection, viewMatrix);
    var mvp = M4.multiply(vp, modelMatrix);

    // initiaze shader.
    shader = Shader(gl, genericShader);
    shader.bind();

    // initialize texture.
    NeonTexture texture = NeonTexture(gl, 'assets/images/pepsi_transparent.png');
    await texture.loadTexture('assets/images/pepsi_transparent.png');
    texture.bind();

    // set uniforms.
    shader.setUniform1i('u_Texture', 0);
    shader.setUniformMat4f('u_Projection', mvp);

    va.unBind(); // unBind vao.
    vb.unBind(); // unBind vertex buffer.
    ib.unBind(); // unBind index buffer.
    shader.unBind(); // unBind shader.

    hazelRenderer = NeonRenderer(flgl, gl);
  }

  /// Render's the scene.
  render() {
    // renderer!.render(scene, camera!);

    gl.viewport(0, 0, (width * dpr).toInt(), (height * dpr).toInt());
    gl.clearColor(0, 0, 0, 1);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    // gl.clear(gl.COLOR_BUFFER_BIT);

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND); // fixes the png transparent issue.

    // draw
    hazelRenderer.draw(va, ib, shader);

    // ! super important.
    // ! never put this inside a loop because it takes some time
    // ! to update the texture.
    gl.finish();
    flgl.updateTexture();
  }
}
