import 'package:flgl_example/examples/controls/transform_control.dart';

class TransformControlsManager {
  Map<String, TransformControl> controls = {};

  TransformControlsManager(this.controls);

  add(TransformControl control) {
    controls[control.name] = control;
  }
}
