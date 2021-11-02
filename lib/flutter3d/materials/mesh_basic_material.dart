import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class MeshBasicMaterial extends Material {
  /// The material color.
  Color color = Color(1, 1, 1, 1);

  /// If set to true then the program will chose
  /// `gl.LINES` instead of `gl.TRIANGES`.
  bool wireframe = false;

  /// The texture map.
  dynamic map; // the texture map.

  MeshBasicMaterial({Color? color}) {
    this.color = color ?? Color(1, 1, 1, 1);

    // Set the material uniforms;
    uniforms['u_colorMult'] = this.color.toArray();
  }
}
