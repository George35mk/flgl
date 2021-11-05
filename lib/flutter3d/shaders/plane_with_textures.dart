String vertexShader = """
  #version 300 es

  in vec4 a_position;
  in vec2 a_uv;

  uniform mat4 u_projection;
  uniform mat4 u_view;
  uniform mat4 u_world;

  out vec2 v_texcoord;

  void main() {
    gl_Position = u_projection * u_view * u_world * a_position;

     // Pass the texture coord to the fragment shader.
    v_texcoord = a_uv;
  }
""";

String fragmentShader = """
  #version 300 es
  
  precision highp float;

  // Passed in from the vertex shader.
  in vec2 v_texcoord;

  uniform vec4 u_colorMult;
  uniform sampler2D u_texture;

  // we need to declare an output for the fragment shader
  out vec4 outColor;

  void main() {
    // outColor = u_colorMult;
    outColor = texture(u_texture, v_texcoord) * u_colorMult;
  }
""";

Map<String, String> planeWithTextureShaders = {
  'vertexShader': vertexShader,
  'fragmentShader': fragmentShader,
};
