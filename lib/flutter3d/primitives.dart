import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class Plane {
  List<double> positions = [];
  List<double> colors = [];
  List<double> textures = [];
  List<int> indices = [];

  Map buffers = {};

  Plane(OpenGLContextES gl, double width, double height) {
    positions = [
      // Front face
      -1.0, -1.0, 1.0,
      1.0, -1.0, 1.0,
      1.0, 1.0, 1.0,
      -1.0, 1.0, 1.0,
    ];

    colors = [
      1.0, 1.0, 1.0, 1.0, // white
      1.0, 0.0, 0.0, 1.0, // red
      0.0, 1.0, 0.0, 1.0, // green
      0.0, 0.0, 1.0, 1.0, // blue
    ];

    textures = [
      // Front
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
    ];

    indices = [0, 1, 2, 0, 2, 3];

    var positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(positions), gl.STATIC_DRAW);

    var colorBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(colors), gl.STATIC_DRAW);

    var textureBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, textureBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(textures), gl.STATIC_DRAW);

    var indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, Uint16List.fromList(indices), gl.STATIC_DRAW);

    buffers['positionBuffer'] = positionBuffer;
    buffers['colorBuffer'] = colorBuffer;
    buffers['textureBuffer'] = textureBuffer;
    buffers['indexBuffer'] = indexBuffer;
  }
}

class Cube {
  double width;
  double height;
  double depth;

  List<double> positions = [];
  List<double> colors = [];
  List<double> textures = [];
  List<int> indices = [];

  Map buffers = {};

  Cube(OpenGLContextES gl, this.width, this.height, this.depth);
}

class Primitives {
  Primitives();

  static createPlane(OpenGLContextES gl) {
    var positions = [
      // Front face
      -1.0, -1.0, 1.0,
      1.0, -1.0, 1.0,
      1.0, 1.0, 1.0,
      -1.0, 1.0, 1.0,
    ];

    var colors = [
      1.0, 1.0, 1.0, 1.0, // white
      1.0, 0.0, 0.0, 1.0, // red
      0.0, 1.0, 0.0, 1.0, // green
      0.0, 0.0, 1.0, 1.0, // blue
    ];

    var textures = [
      // Front
      0.0, 0.0,
      1.0, 0.0,
      1.0, 1.0,
      0.0, 1.0,
    ];

    var indices = [0, 1, 2, 0, 2, 3];

    var positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(positions), gl.STATIC_DRAW);

    var colorBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(colors), gl.STATIC_DRAW);

    var textureBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, textureBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32List.fromList(textures), gl.STATIC_DRAW);

    var indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, Uint16List.fromList(indices), gl.STATIC_DRAW);

    // the plane buffers info.
    return {
      'position': positionBuffer,
      'color': colorBuffer,
      'textureCoord': textureBuffer,
      'indices': indexBuffer,
    };
  }

  static createCube(OpenGLContextES gl) {}
}
