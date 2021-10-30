String planeFragmentShaderSource = """
  #version 300 es
  
  precision highp float;

  // Passed in from the vertex shader.
  in vec2 v_texcoord;

  uniform vec4 u_colorMult;
  uniform sampler2D u_texture;

  out vec4 outColor;

  void main() {
    outColor = texture(u_texture, v_texcoord) * u_colorMult;
  }
""";
