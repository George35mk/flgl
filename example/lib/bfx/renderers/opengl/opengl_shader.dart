import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

OpenGLShader(OpenGLContextES gl, type, string) {
  final shader = gl.createShader(type);

  gl.shaderSource(shader, string);
  gl.compileShader(shader);

  return shader;
}
