import 'dart:typed_data';

import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/flutter3d/math/color.dart';

class MeshBasicMaterial extends Material {
  /// The material color.
  Color? color;

  /// If set to true then the program will chose
  /// `gl.LINES` instead of `gl.TRIANGES`.
  bool wireframe = false;

  /// set this to true if you want to use the
  /// checkboard texture. but you need to
  /// provide the correct data.
  bool checkerboard = false;

  /// The texture map data as Uint8List.
  Uint8List? map; // the texture map.

  /// the texture map width.
  int? mapWidth;

  /// The texture map height.
  int? mapHeigth;

  MeshBasicMaterial({
    this.color,
    this.map,
    this.mapWidth,
    this.mapHeigth,
    this.checkerboard = false,
  }) {
    color ??= Color(1, 1, 1, 1);

    // Set the material uniforms;
    uniforms['u_colorMult'] = color!.toArray();
  }
}
