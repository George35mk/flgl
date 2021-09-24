class TransformControl {
  /// The control name
  String name;

  /// The control value.
  double value;

  /// The control minumum value.
  double min;

  /// The control maximum value.
  double max;

  TransformControl({
    this.name = 'default name',
    this.min = 0,
    this.max = 0,
    this.value = 0,
  });
}
