import 'dart:async';
import 'dart:typed_data';

import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/examples/controls/flgl_controls.dart';
import 'package:flutter/material.dart';

class NeonQuadExample2 extends StatefulWidget {
  const NeonQuadExample2({Key? key}) : super(key: key);

  @override
  _NeonQuadExample2State createState() => _NeonQuadExample2State();
}

class _NeonQuadExample2State extends State<NeonQuadExample2> {
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
  // late VertexArray va;
  // late VertexBuffer vb;
  // late BufferLayout layout;
  // late IndexBuffer ib;
  // late Shader shader;

  late NeonMesh mesh;
  late NeonRenderer neonRenderer;

  NeonScene scene = NeonScene();
  late PerspectiveCamera perspectiveCamera;
  late OrthographicCamera orthographicCamera;
  late Camera activeCamera;

  bool ok = false;
  var dropdownValue = 'OrthographicCamera';
  double zoom = 0;

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

  Widget dropDownMenu() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          if (dropdownValue == 'PerspectiveCamera') {
            activeCamera = perspectiveCamera;
          } else if (dropdownValue == 'OrthographicCamera') {
            activeCamera = orthographicCamera;
          }
        });
      },
      items: <String>['PerspectiveCamera', 'OrthographicCamera']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    dpr = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neon: Quad 2"),
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
          if (ok && activeCamera != null && scene != null)
            Positioned(
              width: 420,
              top: 10,
              right: 10,
              child: FLGLControls(camera: activeCamera, scene: scene),
            ),

          // Positioned(
          //   top: 10,
          //   child: TextButton(
          //     child: const Text('BUY TICKETS'),
          //     onPressed: () {/* ... */},
          //   ),
          // ),
          // Positioned(
          //   top: 10,
          //   left: 120,
          //   child: TextButton(
          //     child: const Text('BUY TICKETS2'),
          //     onPressed: () {/* ... */},
          //   ),
          // ),
          Positioned(
            top: 10,
            left: 10,
            child: dropDownMenu(),
          ),
        ],
      ),
    );
  }

  /// Initialize's the scene.
  initScene() {
    var aspect = dpr; // 1.5
    orthographicCamera = OrthographicCamera((width * aspect) / -2, (width * aspect) / 2, (height * aspect) / -2, (height * aspect) / 2, -1, 1000);
    orthographicCamera.name = 'OrthographicCamera';
    orthographicCamera.setPosition(Vector3(0, 0, 100));

    perspectiveCamera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
    perspectiveCamera.name = 'PerspectiveCamera';
    perspectiveCamera.setPosition(Vector3(0, 0, 300));



    var geometry = NeonQuadGeometry();
    var material = NeonMeshBasicMaterial(color: Color(0, 1, 0, 1));
    var mesh = NeonMesh(gl, geometry, material);
    mesh.name = 'Quad';
    mesh.setScale(Vector3(100, 100, 1));

    scene.add(mesh);

    neonRenderer = NeonRenderer(flgl, gl);
    neonRenderer.width = width;
    neonRenderer.height = height;
    neonRenderer.dpr = dpr;
    neonRenderer.init();

    

    print(perspectiveCamera.cameraMatrix);
    print(perspectiveCamera.viewMatrix);

    activeCamera = orthographicCamera;
    // activeCamera = perspectiveCamera;

    ok = true;
  }

  render() {
    // gl.viewport(0, 0, (width * dpr).toInt(), (height * dpr).toInt());
    // gl.clearColor(0, 0, 0, 1);

    // // Clear the canvas AND the depth buffer.
    // gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // gl.enable(gl.CULL_FACE);
    // gl.enable(gl.DEPTH_TEST);

    // draw
    if (neonRenderer != null) {
      // zoom = 1 / zoom;
      // orthographicCamera.zoom(zoom);
      
      // shader.bind();
      // shader.setUniform4f('u_Color', r, 0, 1, 1);
      // neonRenderer.draw(va, ib, shader);
      // neonRenderer.render(scene, orthographicCamera);
      neonRenderer.render(scene, activeCamera);

      // if (r >= 1) {
      //   r = 0;
      // }
      // r += 0.01;
    }

    // // ! super important.
    // // ! never put this inside a loop because it takes some time
    // // ! to update the texture.
    // gl.finish();
    // flgl.updateTexture();
  }
}

// String vs = """
//   #version 300 es
  
//   layout(location = 0) in vec4 position;

//   void main() {
//     gl_Position = position;
//   }
// """;

// String fs = """
//   #version 300 es
  
//   precision highp float;

//   layout(location = 0) out vec4 color;

//   uniform vec4 u_Color;

//   void main() {
//     color = u_Color;
//   }
// """;

// Map<String, String> exampleShader = {
//   'vertexShader': vs,
//   'fragmentShader': fs,
// };
