import 'dart:async';
import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonBatchRenderingTexturesExample extends StatefulWidget {
  const NeonBatchRenderingTexturesExample({Key? key}) : super(key: key);

  @override
  _NeonBatchRenderingTexturesExampleState createState() => _NeonBatchRenderingTexturesExampleState();
}

class _NeonBatchRenderingTexturesExampleState extends State<NeonBatchRenderingTexturesExample> {
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

  // new stuff
  late VertexArray va;
  late VertexBuffer vb;
  late VertexBufferLayout layout;
  late IndexBuffer ib;
  late Shader shader;
  NeonRenderer? neonRenderer;

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
        title: const Text("Neon: Batch rendering textures"),
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
  initScene() async {
    List<double> vertices = [
      // position(x, y, z) - color(r, g, b , a) - uv(2) - uv_id
      -1.5, -0.5, 0.0,   0.18, 0.6, 0.96, 1.0,   0.0, 0.0,   0, // 0
      -0.5, -0.5, 0.0,   0.18, 0.6, 0.96, 1.0,   1.0, 0.0,   0, // 1
      -0.5,  0.5, 0.0,   0.18, 0.6, 0.96, 1.0,   1.0, 1.0,   0, // 2
      -1.5,  0.5, 0.0,   0.18, 0.6, 0.96, 1.0,   0.0, 1.0,   0, // 3

       0.5, -0.5, 0.0,   1.0, 0.93, 0.24, 1.0,   0.0, 0.0,   1, // 4
       1.5, -0.5, 0.0,   1.0, 0.93, 0.24, 1.0,   1.0, 0.0,   1, // 5
       1.5,  0.5, 0.0,   1.0, 0.93, 0.24, 1.0,   1.0, 1.0,   1, // 6
       0.5,  0.5, 0.0,   1.0, 0.93, 0.24, 1.0,   0.0, 1.0,   1, // 7
    ];

    List<int> indices = [
      0, 1, 2, 2, 3, 0,
      4, 5, 6, 6, 7, 4,
      
    ];


    // List<String> availebleExtensions = gl.getExtension('GL_EXT_gpu_shader5');
    // print(availebleExtensions);

    // use this when you using png textures.
    gl.blendFunc(GL_SRC1_ALPHA_EXT, GL_ONE_MINUS_SRC_ALPHA);

    va = VertexArray(gl);
    vb = VertexBuffer(gl, Float32List.fromList(vertices), 4 * 4);

    // init vertex buffer layout.
    layout = VertexBufferLayout();
    layout.pushFloat(3); // position vertices
    layout.pushFloat(4); // color vertices
    layout.pushFloat(2); // uv vertices
    layout.pushFloat(1); // uv ifs
    va.addBuffer(vb, layout);

    // init index buffer.
    ib = IndexBuffer(gl, Uint16List.fromList(indices), 6);

    /// The orthographic projection matrix.
    var aspect = dpr; // 1.5
    List<double> projection = M4.orthographic(
        (width * aspect) / -2, (width * aspect) / 2, (height * aspect) / -2, (height * aspect) / 2, -1, 1);

    var viewMatrix = M4.translate(M4.identity(), 0, 0, 0);

    var modelMatrix = M4.translate(M4.identity(), 0, 0, 0);
    modelMatrix = M4.xRotate(modelMatrix, MathUtils.radToDeg(0));
    modelMatrix = M4.yRotate(modelMatrix, MathUtils.radToDeg(0));
    modelMatrix = M4.zRotate(modelMatrix, MathUtils.radToDeg(0));
    modelMatrix = M4.scale(modelMatrix, 500, 500, 1);

    var vp = M4.multiply(projection, viewMatrix);
    var mvp = M4.multiply(vp, modelMatrix);

    // initiaze shader.
    shader = Shader(gl, exampleShader);
    shader.bind();

    // initializing texture 1.
    NeonTexture texture0 = NeonTexture(gl, 'assets/images/pepsi_transparent.png');
    await texture0.loadTexture('assets/images/pepsi_transparent.png');
    texture0.bind(0);

    // initializing texture 2.
    // NeonTexture texture1 = NeonTexture(gl, 'assets/images/star.jpg');
    // await texture1.loadTexture('assets/images/star.jpg');
    // texture1.bind(1);
    
    // Set uniforms.
    // dynamic samplers = [0, 1];
    // shader.setUniform1iv('u_Textures', samplers);
    shader.setUniform1i('u_Textures', 0); // in GLES 3 you can't have array sampler.
    // shader.setUniform1i('u_Textures', 1); // in GLES 3 you can't have array sampler.


    shader.setUniformMat4f('u_Projection', mvp);

    va.unBind(); // unBind vao.
    vb.unBind(); // unBind vertex buffer.
    ib.unBind(); // unBind index buffer.
    shader.unBind(); // unBind shader.

    neonRenderer = NeonRenderer(flgl, gl);
  }

  /// Render's the scene.
  render() {
    // renderer!.render(scene, camera!);

    gl.viewport(0, 0, (width * dpr).toInt(), (height * dpr).toInt());
    gl.clearColor(0.1, 0.1, 0.1, 1);

    // Clear the canvas AND the depth buffer.
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    // gl.clear(gl.COLOR_BUFFER_BIT);

    // enable CULL_FACE and DEPTH_TEST.
    gl.enable(gl.CULL_FACE);
    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND); // fixes the png transparent issue.

    // draw
    // otherwise I get late initialization error.
    if (neonRenderer != null) {
      neonRenderer!.draw(va, ib, shader);
    }

    // ! super important.
    // ! never put this inside a loop because it takes some time
    // ! to update the texture.
    gl.finish();
    flgl.updateTexture();
  }
}


String vs = """
  #version 310 es

  precision highp float;
  
  layout (location = 0) in vec4 a_Position;
  layout (location = 1) in vec4 a_Color;
  layout (location = 2) in vec2 a_TexCoord;
  layout (location = 3) in float a_TexIndex;

  out vec4 v_Color;
  out vec2 v_TexCoord;
  out float v_TexIndex;

  uniform mat4 u_Projection; 

  void main() {
    v_Color = a_Color;
    v_TexCoord = a_TexCoord;
    v_TexIndex = a_TexIndex;
    gl_Position = u_Projection * a_Position;
  }
""";

String fs = """
  #version 310 es

  precision highp float;
  
  layout(location = 0) out vec4 o_Color;

  in vec4 v_Color;
  in vec2 v_TexCoord;
  in float v_TexIndex;

  uniform sampler2D u_Textures[2];

  void main() {
    // o_Color = vec4(v_TexCoord, 0.0, 1.0);
    // o_Color = vec4(v_TexIndex, v_TexIndex, v_TexIndex, 1.0);
    int index = int(v_TexIndex);
    o_Color = texture(u_Textures[0], v_TexCoord);
  }
""";

Map<String, String> exampleShader = {
  'vertexShader': vs,
  'fragmentShader': fs,
};