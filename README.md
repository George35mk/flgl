# flgl

One more plugin to expose OpenGL ES in Flutter applications.


## Getting Started

`flutter pub add flgl`


## How FLGL plugin renders 3D graphics?

FLGL plugin uses the Texture widget to render 3D graphics 
but the texture widget needs a texture id, to get the texture id in android 
devices for example I use platform-specific android code using platform 
channels.

Then I make a second call to init egl in android code and then I use the 
OpenGL ES bindings from dart side to expose the gl context.

The plugin needs your help if you know what to do to improved I am open for 
pull requests from anybody know about 3D graphics.


## What I can do with FLGL_3D class? 

FLGL plugin expose the gl context but is more powerful when you combined with 
`flgl_3d`, then you can build 3D apps with less code like three.js

An example on how to use the `flgl_3d` class.

```dart
import 'package:flgl/flgl.dart';
import 'package:flgl/flgl_3d.dart';

initScene() {
  // Setup the camera.
  camera = PerspectiveCamera(45, (width * flgl.dpr) / (height * flgl.dpr), 1, 2000);
  camera.setPosition(Vector3(0, 0, 300));

  // Setup the renderer.
  renderer = Renderer(gl, flgl);
  renderer.setBackgroundColor(0, 0, 0, 1);
  renderer.setWidth(width);
  renderer.setHeight(height);
  renderer.setDPR(dpr);

  // Create the box geometry.
  BoxGeometry boxGeometry = BoxGeometry(0.5);

  // Create the box material.
  MeshBasicMaterial material = MeshBasicMaterial(
    color: Color(1.0, 1.0, 0.0, 1.0),
  );

  // Create the box mesh.
  Mesh boxMesh = Mesh(gl, boxGeometry, material);
  boxMesh.name = 'box';
  boxMesh.setPosition(Vector3(4, 0, 0));
  boxMesh.setScale(Vector3(100, 100, 100));

  scene.add(boxMesh);
}

/// Render's the scene.
render() {
  renderer.render(scene, camera);
}
```


## need help?

Check in examples dir.

## known issues
The plugin is not stable, renders 3D objects but I need help to
fix some issues with memory and make sure the app not crashes.

I have tested the plugin only in android devices.

Maybe the issue is with the egl setup or the egl dispose. For unknown reason the app freezes after the 28th reload. 

`¯\_(ツ)_/¯`


## How to help

The core files are inside the `lib/`

For example in `lib/flgl.dart` is the root of the plugin, there you will find 
- how I get the texture id, 
- how I init the egl
- how I prepare the egl context
- how I update the texture.
- how I dispose the plugin.



## Example rendering 

```dart
import 'package:flgl/flgl.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl/flgl_viewport.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../gl_utils.dart';

class Example1 extends StatefulWidget {
  const Example1({Key? key}) : super(key: key);

  @override
  _Example1State createState() => _Example1State();
}

class _Example1State extends State<Example1> {
  bool initialized = false;

  dynamic positionLocation;
  dynamic positionBuffer;
  dynamic program;

  late Flgl flgl;
  late OpenGLContextES gl;

  late int width = 1333;
  late int height = 752 - 80 - 48;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example Hello world"),
      ),
      body: Column(
        children: [
          FLGLViewport(
              width: width,
              height: height,
              onInit: (Flgl _flgl) {
                setState(() {
                  initialized = true;
                  flgl = _flgl;
                  gl = flgl.gl;

                  initGl();
                  draw();
                });
              }),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  render();
                },
                child: const Text("Render"),
              )
            ],
          )
        ],
      ),
    );
  }

  render() {
    draw();
  }

  String vertexShaderSource = """
    // an attribute will receive data from a buffer
    attribute vec4 a_position;
    
    // all shaders have a main function
    void main() {
    
      // gl_Position is a special variable a vertex shader
      // is responsible for setting
      gl_Position = a_position;
    }
  """;

  String fragmentShaderSource = """
    // fragment shaders don't have a default precision so we need
    // to pick one. mediump is a good default. It means "medium precision"
    precision mediump float;
    
    void main() {
      // gl_FragColor is a special variable a fragment shader
      // is responsible for setting
      gl_FragColor = vec4(1, 0, 0.5, 1); // return reddish-purple
    }
  """;

  int createShader(OpenGLContextES gl, int type, String source) {
    int shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success == 0 || success == false) {
      print("Error compiling shader: " + gl.getShaderInfoLog(shader));
      throw 'Failed to create the shader';
    }
    return shader;
  }

  int createProgram(OpenGLContextES gl, int vertexShader, int fragmentShader) {
    int program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success != 0 || success != false) {
      return program;
    }
    print('getProgramInfoLog: ${gl.getProgramInfoLog(program)}');
    gl.deleteProgram(program);
    throw 'failed to create the program';
  }

  initGl() {
    int vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    int fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = createProgram(gl, vertexShader, fragmentShader);

    positionLocation = gl.getAttribLocation(program, "a_position");

    positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // three 2d points
    List<double> positions = [
      0, 0, //
      0, 0.5, //
      0.5, 0, //
    ];
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(positions), gl.STATIC_DRAW);
  }

  draw() {
    // Tell WebGL how to convert from clip space to pixels
    gl.viewport(0, 0, width, height);

    // Clear the canvas. sets the canvas background color.
    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    // Tell it to use our program (pair of shaders)
    gl.useProgram(program);

    // Turn on the attribute
    gl.enableVertexAttribArray(positionLocation);

    // Bind the position buffer.
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    var size = 2; // 2 components per iteration
    var type = gl.FLOAT; // the data is 32bit floats
    var normalize = false; // don't normalize the data
    var stride = 0;
    var offset = 0; // start at the beginning of the buffer
    gl.vertexAttribPointer(positionLocation, size, type, normalize, stride, offset);

    // draw TRIANGLE
    var primitiveType = gl.TRIANGLES;
    var offset_draw = 0;
    var count = 3;
    gl.drawArrays(primitiveType, offset_draw, count);

    // !super important.
    gl.finish();
    flgl.updateTexture();
  }
}
```
