String vertexShader = """
  #version 300 es

  in vec4 a_position;

  uniform mat4 u_projection;
  uniform mat4 u_view;
  uniform mat4 u_world;

  void main() {
    gl_Position = u_projection * u_view * u_world * a_position;
  }
""";

String fragmentShader = """
  #version 300 es
  
  precision highp float;

  uniform vec4 u_colorMult;

  // we need to declare an output for the fragment shader
  out vec4 outColor;

  void main() {
    outColor = u_colorMult;
  }
""";

Map<String, String> planeShaders = {
  'vertexShader': vertexShader,
  'fragmentShader': fragmentShader,
};
