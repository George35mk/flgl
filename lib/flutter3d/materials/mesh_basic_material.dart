import 'package:flgl/flutter3d/materials/material.dart';

class MeshBasicMaterial extends Material {
  Color color = Color(1, 1, 1, 1);

  MeshBasicMaterial({Color? color}) {
    this.color = color ?? Color(1, 1, 1, 1);

    // Set the material uniforms;
    uniforms['u_colorMult'] = this.color.toArray();
  }
}

class Color {
  double r;
  double g;
  double b;
  double a;

  Color(this.r, this.g, this.b, this.a);

  /// returns a list of [r, g, b, a];
  toArray() {
    return [r, g, b, a];
  }
}
