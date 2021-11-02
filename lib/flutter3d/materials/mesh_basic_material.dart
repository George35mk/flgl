import 'dart:typed_data';

import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class MeshBasicMaterial extends Material {
  /// The material color.
  Color? color;

  /// If set to true then the program will chose
  /// `gl.LINES` instead of `gl.TRIANGES`.
  bool wireframe = false;

  /// The texture map data.
  Uint8List? map; // the texture map.

  MeshBasicMaterial({this.color, this.map}) {
    color ??= Color(1, 1, 1, 1);

    // Set the material uniforms;
    uniforms['u_colorMult'] = color!.toArray();
  }
}
