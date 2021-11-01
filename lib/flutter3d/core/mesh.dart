import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../math/m4.dart';
import 'buffer_geometry.dart';
import 'object_3d.dart';

class Mesh extends Object3D {
  // BufferGeometry geometry;
  // dynamic material;

  Mesh(OpenGLContextES gl, BufferGeometry geometry) : super(gl, geometry);

  // them add a higher level functions that control the uniforms
}
