String planeVertexShaderSource = """
  #version 300 es

  in vec4 a_position;
  in vec2 a_texcoord;

  uniform mat4 u_projection;
  uniform mat4 u_view;
  uniform mat4 u_world;

  out vec2 v_texcoord;

  void main() {
    // Multiply the position by the matrix.
    gl_Position = u_projection * u_view * u_world * a_position;

    // Pass the texture coord to the fragment shader.
    v_texcoord = a_texcoord;
  }
""";
