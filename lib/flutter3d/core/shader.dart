import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class Shader {
  /// The OpenGL ES context.
  OpenGLContextES gl;

  /// the program location id.
  int m_RendererID = 0;

  /// The shader source code.
  Map<String, String> shaderSource;

  /// Caches the uniforms location id.
  Map<String, int> m_UniformLocationCache = {};

  Shader(this.gl, this.shaderSource) {
    // 1. Create a program based on geometry and material

    // initialize shaders.
    int vertexShader = createShader(gl, gl.VERTEX_SHADER, shaderSource['vertexShader']!);
    int fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, shaderSource['fragmentShader']!);

    // initialize program.
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

  /// Get uniform location.
  ///
  /// Keep in mind.
  /// If a uniform is never used inside the shaders code then
  /// gl.getUniformLocation will return -1.
  int getUniformLocation(String name) {
    if (m_UniformLocationCache[name] != null) {
      return m_UniformLocationCache[name]!;
    } else {
      int location = gl.getUniformLocation(m_RendererID, name);
      if (location == -1) {
        print("Warning: Uniform [$name] location not found, the value is: $location");
      }
      m_UniformLocationCache[name] = location;
      return location;
    }
  }

  // one use of this setter is on textures.
  setUniform1i(String name, int value) {
    int location = getUniformLocation(name);
    gl.uniform1i(location, value);
  }

  setUniform1f(String name, double value) {
    int location = getUniformLocation(name);
    gl.uniform1f(location, value);
  }
  
  setUniform1iv(String name, List<int> value) {
    int location = getUniformLocation(name);
    gl.uniform1iv(location, value);
  }

  // you ca use Vector2 here as a value.
  setUniform2f(String name, double v0, double v1) {
    int location = getUniformLocation(name);
    gl.uniform2f(location, v0, v1);
  }

  // you ca use Vector3 here as a value.
  setUniform3f(String name, double v0, double v1, double v2) {
    int location = getUniformLocation(name);
    gl.uniform3f(location, v0, v1, v2);
  }

  // you ca use Vector4 here as a value.
  setUniform4f(String name, double v0, double v1, double v2, double v3) {
    int location = getUniformLocation(name);
    gl.uniform4f(location, v0, v1, v2, v3);
  }

  /// Sets uniform mat3f
  /// - [value] Matrix3
  setUniformMat3f(String name, List<double> value) {
    int location = getUniformLocation(name);
    gl.uniformMatrix3fv(location, false, value);
  }

  /// Sets uniform mat4f
  /// you can set uniforms with matrix4 data.
  setUniformMat4f(String name, List<double> value) {
    int location = getUniformLocation(name);
    gl.uniformMatrix4fv(location, false, value);
  }
}
