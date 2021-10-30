import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../math/m4.dart';
import 'buffer_geometry.dart';
import 'object_3d.dart';

class Mesh extends Object3D {
  // BufferGeometry geometry;
  // dynamic material;

  // OpenGLContextES gl;

  Mesh(OpenGLContextES gl, BufferGeometry geometry) : super(gl, geometry) {
    uniforms['u_colorMult'] = [0.5, 0.5, 1.0, 1.0]; // lightblue
    // uniforms['u_texture'] = checkerboardTexture;
    uniforms['u_world'] = M4.translation(0, 0, 0);

    // camera settings.
    uniforms['u_view'] = M4.identity(); // viewMatrix;
    uniforms['u_projection'] = M4.identity(); // projectionMatrix;
  }

  // them add a higher level functions that control the uniforms
}
