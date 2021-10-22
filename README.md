# flgl

One more plugin to use the openGL ES in Flutter apps.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## How to use the package

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

  initGl() {
    int vertexShader = GLUtils.createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    int fragmentShader = GLUtils.createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = GLUtils.createProgram(gl, vertexShader, fragmentShader);

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
    // gl.viewport(0, 0, width, height);

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

### GLUtils class
```dart
class GLUtils {
  static int createShader(OpenGLContextES gl, int type, String source) {
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

  static int createProgram(OpenGLContextES gl, int vertexShader, int fragmentShader) {
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
}

```
