import 'package:flgl_example/bfx/core/object_3d.dart';

class Scene extends Object3D {
  bool isScene = true;

  bool autoUpdate = true;
  dynamic background;
  dynamic environment;
  dynamic fog;
  dynamic overrideMaterial;

  Scene() {
    type = 'Scene';
    background = null;
    environment = null;
    fog = null;
    overrideMaterial = null;
    autoUpdate = true;
  }

  // @override
  // copy(source, [recursive]) {
  //   super.copy(source);

  //   if (source.background != null) this.background = source.background.clone();
  //   if (source.environment != null) this.environment = source.environment.clone();
  //   if (source.fog != null) this.fog = source.fog.clone();

  //   if (source.overrideMaterial != null) this.overrideMaterial = source.overrideMaterial.clone();

  //   this.autoUpdate = source.autoUpdate;
  //   this.matrixAutoUpdate = source.matrixAutoUpdate;

  //   return this;
  // }
}
