import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class Shader {
  OpenGLContextES gl;
  int m_RendererID = 0;
  int location = 0;
  Map<String, int> m_UniformLocationCache = {};

  Shader(this.gl, Map<String, String> shaderSource) {
    // 1. Create a program based on geometry and material

    int vertexShader = createShader(gl, gl.VERTEX_SHADER, shaderSource['vertexShader']!);
    int fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, shaderSource['fragmentShader']!);

    m_RendererID = createProgram(gl, vertexShader, fragmentShader);
  }

  dispose() {
    gl.deleteProgram(m_RendererID);
  }

  bind() {
    gl.useProgram(m_RendererID);
  }

  unBind() {
    gl.useProgram(0);
  }

  /// Creates a shader.
  ///
  /// Takes a [type] that can be a `gl.VERTEX_SHADER` or `gl.FRAGMENT_SHADER`
  ///
  /// and a [source] the shader source as a String.
  ///
  /// Finaly returns the shader id.
  static int createShader(OpenGLContextES gl, int type, String source) {
    int shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var result = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (result == GL_FALSE) {
      String shaderName = type == GL_VERTEX_SHADER ? 'vertex' : 'fragment';
      // gl.deleteShader(shader);
      throw 'Failed to compile $shaderName shader! the log is: ${gl.getShaderInfoLog(shader)}';
    }
    return shader;
  }

  /// Creates a shader program.
  ///
  /// First creates a program then attatch the vertex
  /// and fragment shaders, links the program finally returns the program id.
  ///
  /// Takes an OpenGl ES context, a [vs] vertex shader id, and a [fs] fragment shader id.
  ///
  /// Finally returns the program id.
  int createProgram(OpenGLContextES gl, int vs, int fs) {
    int program = gl.createProgram();

    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    gl.validateProgram(program);

    gl.deleteShader(vs);
    gl.deleteShader(fs);

    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success != 0) {
      return program;
    }

    print('getProgramInfoLog: ${gl.getProgramInfoLog(program)}');
    gl.deleteProgram(program);
    throw 'failed to create the program';
  }

  // bool compileShader() {}

  // set uniforms

  // one use of this setter is on textures.
  setUniform1i(String name, int value) {
    gl.uniform1i(getUniformLocation(name), value);
  }

  setUniform1f(String name, double value) {
    gl.uniform1f(getUniformLocation(name), value);
  }

  setUniform4f(String name, double v0, double v1, double v2, double v3) {
    gl.uniform4f(getUniformLocation(name), v0, v1, v2, v3);
  }

  int getUniformLocation(String name) {
    if (m_UniformLocationCache[name] != null) {
      return m_UniformLocationCache[name]!;
    } else {
      location = gl.getUniformLocation(m_RendererID, name);
      if (location == -1) {
        print("Warning: Uniform location not found, the value is: $location");
      }
      m_UniformLocationCache[name] = location;
      return location;
    }
  }
}
