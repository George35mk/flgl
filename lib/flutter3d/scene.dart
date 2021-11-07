import 'package:flgl/flgl_3d.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'core/object_3d.dart';

class Scene {
  List<Object3D> children = [];
  Scene();

  add(dynamic object) {
    children.add(object);
  }

  dispose(OpenGLContextES gl) {
    children.map((child) {
      if (child.material is MeshBasicMaterial) {
        // dispose the object textures.
        if (child.material.uniforms['u_texture'] != null) {
          print('Starting deleting textures.');
          gl.deleteTexture(child.material.uniforms['u_texture']);
        }
      }

      // dispose program and shaders.
      child.dispose();
    });
  }
}
