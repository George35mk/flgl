import 'package:flgl/flutter3d/materials/material.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'buffer_geometry.dart';
import 'object_3d.dart';

class Mesh extends Object3D {
  Mesh(OpenGLContextES gl, BufferGeometry geometry, Material material) : super(gl, geometry, material);
}
