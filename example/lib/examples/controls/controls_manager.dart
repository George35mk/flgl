class ControlsManager {
  Map<String, Control> controls = {};

  ControlsManager(this.controls);

  add(Control control) {
    controls[control.name] = control;
  }
}

class Control {
  /// The control name
  String name;

  /// The control value.
  double value;

  /// The control minumum value.
  double min;

  /// The control maximum value.
  double max;

  Control({
    this.name = 'default name',
    this.min = 0,
    this.max = 0,
    this.value = 0,
  });
}
