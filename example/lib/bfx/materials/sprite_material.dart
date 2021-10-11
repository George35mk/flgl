import 'package:flgl_example/bfx/materials/fbx_material.dart';
import 'package:flgl_example/bfx/math/color.dart';

class SpriteMaterial extends FBXMaterial {
  bool isSpriteMaterial = true;
  Color color = Color(0xffffff);
  dynamic map;
  dynamic alphaMap;
  dynamic rotation = 0;
  bool sizeAttenuation = true;

  SpriteMaterial([parameters]) {
    type = 'SpriteMaterial';

    transparent = true;

    setValues(parameters);
  }

  // @override
  // SpriteMaterial copy(SpriteMaterial source) {
  //   super.copy(source);

  //   color.copy(source.color);
  //   map = source.map;
  //   alphaMap = source.alphaMap;
  //   rotation = source.rotation;
  //   sizeAttenuation = source.sizeAttenuation;

  //   return this;
  // }
}
