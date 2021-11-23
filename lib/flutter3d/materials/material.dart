class Material {
  /// Set this to false if you don't want to render this object.
  bool visible = true;

  /// Set this to true if you want transparent objects.
  bool transparent = false;

  /// if transparent set to true then you can use
  /// the opacity.
  /// the range of the opacity is between 0.0 and 1.0
  double opacity = 1.0;

  /// The material uniforms.
  Map<String, dynamic> uniforms = {};

  Map<String, String> shaderSource = {};

  Material();
}
