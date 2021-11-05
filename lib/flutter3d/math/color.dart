class Color {
  double r;
  double g;
  double b;
  double a;

  Color([this.r = 1, this.g = 1, this.b = 1, this.a = 1]);

  /// returns a list of [r, g, b, a];
  toArray() {
    return [r, g, b, a];
  }

  fromRGBA(int r, int g, int b, int a) {
    this.r = r / 255;
    this.g = g / 255;
    this.b = b / 255;
    this.a = a / 255;
    return this;
  }
}
