import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class GLUtils {
  static createShader(OpenGLContextES gl, int type, String source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success == 0 || success == false) {
      print("Error compiling shader: " + gl.getShaderInfoLog(shader));
      return;
    }
    return shader;
  }

  static createProgram(OpenGLContextES gl, vertexShader, fragmentShader) {
    var program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success != 0 || success != false) {
      return program;
    }
    print('getProgramInfoLog: ${gl.getProgramInfoLog(program)}');
    gl.deleteProgram(program);
  }
}
