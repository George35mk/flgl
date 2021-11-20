String vs = """
  #version 300 es
  
  layout(location = 0) in vec4 position;

  void main() {
    gl_Position = position;
  }
""";

String fs = """
  #version 300 es
  
  precision highp float;

  layout(location = 0) out vec4 color;

  uniform vec4 u_Color;

  void main() {
    color = u_Color;
    // color = vec4(1, 0, 0.5, 1);
  }
""";

Map<String, String> genericShader = {
  'vertexShader': vs,
  'fragmentShader': fs,
};
