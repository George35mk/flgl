String vertexShader = """
  #version 300 es
  
  // an attribute is an input (in) to a vertex shader.
  // It will receive data from a buffer
  in vec4 a_position;

  // A matrix to transform the positions by
  uniform mat4 u_projection;
  uniform mat4 u_view;
  uniform mat4 u_world;
  
  void main() {
  
    // gl_Position is a special variable a vertex shader
    // is responsible for setting
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

Map<String, String> sphereShaders = {
  'vertexShader': vertexShader,
  'fragmentShader': fragmentShader,
};
