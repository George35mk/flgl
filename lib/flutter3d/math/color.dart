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
