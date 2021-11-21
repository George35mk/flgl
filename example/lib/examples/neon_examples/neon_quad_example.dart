import 'dart:async';
import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonQuadExample extends StatefulWidget {
  const NeonQuadExample({Key? key}) : super(key: key);

  @override
  _NeonQuadExampleState createState() => _NeonQuadExampleState();
}

class _NeonQuadExampleState extends State<NeonQuadExample> {
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

  /// dummy var for red color.
  double r = 0;

  // new stuff
  late VertexArray va;
  late VertexBuffer vb;
  late VertexBufferLayout layout;
  late IndexBuffer ib;
  late Shader shader;
  late NeonRenderer neonRenderer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
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
        title: const Text("Neon: Triangle"),
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
          // if (camera != null && scene != null)
          //   Positioned(
          //     width: 420,
          //     top: 10,
          //     right: 10,
          //     child: FLGLControls(camera: camera!, scene: scene),
          //   ),
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() {
    List<double> positions = [
      -0.5, -0.5, // 0
      0.5, -0.5, // 1
      0.5, 0.5, // 2
      -0.5, 0.5, // 3
    ];

    var indices = [
      0, 1, 2, //
      2, 3, 0, //
    ];

    va = VertexArray(gl);
    vb = VertexBuffer(gl, Float32List.fromList(positions), 4 * 2);

    // init vertex buffer layout.
    layout = VertexBufferLayout();
    layout.pushFloat(2);
    va.addBuffer(vb, layout);

    // init index buffer.
    ib = IndexBuffer(gl, Uint16List.fromList(indices), 6);

    // init shader.
    shader = Shader(gl, exampleShader);
    shader.bind();

    va.unBind(); // vao
    vb.unBind(); // vertex buffer
    ib.unBind(); // index buffer
    shader.unBind();

    neonRenderer = NeonRenderer(flgl, gl);
  }

  render() {
    gl.viewport(0, 0, (width * dpr).toInt(), (height * dpr).toInt());
    gl.clearColor(0, 0, 0, 1);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);

    // draw
    if (neonRenderer != null) {
      // shader.bind();
      shader.setUniform4f('u_Color', r, 0, 1, 1);
      neonRenderer.draw(va, ib, shader);

      if (r >= 1) {
        r = 0;
      }
      r += 0.01;
    }

    // ! super important.
    // ! never put this inside a loop because it takes some time
    // ! to update the texture.
    gl.finish();
    flgl.updateTexture();
  }
}

String vs = """
  #version 300 es
  
  layout(location = 0) in vec4 position;

  void main() {
    gl_Position = position;
  }
""";

String fs = """
  #version 300 es
  
  precision highp float;

  layout(location = 0) out vec4 color;

  uniform vec4 u_Color;

  void main() {
    color = u_Color;
  }
""";

Map<String, String> exampleShader = {
  'vertexShader': vs,
  'fragmentShader': fs,
};
