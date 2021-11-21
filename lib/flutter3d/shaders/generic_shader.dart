String vs = """
  #version 300 es
  
  layout(location = 0) in vec4 position;
  layout(location = 1) in vec2 texCoord;

  out vec2 v_TexCoord;

  uniform mat4 u_Projection; // or use u_MVP

  void main() {
    gl_Position = u_Projection * position;
    v_TexCoord = texCoord;
  }
""";

String fs = """
  #version 300 es
  
  precision highp float;

  layout(location = 0) out vec4 color;

  in vec2 v_TexCoord;

  uniform vec4 u_Color;
  uniform sampler2D u_Texture;

  void main() {
    vec4 texColor = texture(u_Texture, v_TexCoord);
    color = texColor;
  }
""";

Map<String, String> genericShader = {
  'vertexShader': vs,
  'fragmentShader': fs,
};
