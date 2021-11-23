import 'dart:typed_data';

import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class NeonMeshBasicMaterial extends Material {
  /// The material color.
  Color? color;

  /// The texture map data as Uint8List.
  Uint8List? map; // the texture map.

  String vs = """
    #version 300 es
    
    layout(location = 0) in vec4 a_Position;
    
    // the projection matrix
    // the camera matrix
    // the model matrix

    uniform mat4 u_Projection;
    uniform mat4 u_View;
    uniform mat4 u_Model;

    void main() {
      gl_Position = u_Projection * u_View * u_Model * a_Position;
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


  NeonMeshBasicMaterial({
    this.color,
    this.map,
  }) {
    color ??= Color(1, 1, 1, 1);

    // Initialize the mesh basic material shader source.
    shaderSource = {
      'vertexShader': vs,
      'fragmentShader': fs,
    };

    // ignore: todo
    // TODO: If the user has map data then tou should change the shaderSource.
  }
}


