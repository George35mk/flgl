import 'package:flgl/flgl_3d.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';


class NeonScene {

  List<NeonObject3D> children = [];
  
  NeonScene();

  add(dynamic object) {
    children.add(object);
  }

  // Dispose scene objects.
  dispose(OpenGLContextES gl) {
    children.map((child) {

      // dispose program and shaders.
      child.dispose();
    });
  }
}
