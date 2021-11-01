import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class MeshBasicMaterial extends Material {
  Color color = Color(1, 1, 1, 1);

  MeshBasicMaterial({Color? color}) {
    this.color = color ?? Color(1, 1, 1, 1);

    // Set the material uniforms;
    uniforms['u_colorMult'] = this.color.toArray();
  }
}
