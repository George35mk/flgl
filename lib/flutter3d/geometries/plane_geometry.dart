import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class PlaneGeometry extends BufferGeometry {
  OpenGLContextES gl;

  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  // dynamic programInfo;
  // dynamic planeVAO;

  // uniforms
  // if you set the uniforms inside the plane geometry
  // then you need to have a uniforms map here. othewise use a mesh object.

  PlaneGeometry(this.gl) {
    // Compute the indices, vertices, normals and uvs.
    indices = [
      0, 2, 1, //
      2, 3, 1, //
    ];
    vertices = [
      -1, 0, -1, //
      1, 0, -1, //
      -1, 0, 1, //
      1, 0, 1, //
    ];
    normals = [
      0, 1, 0, //
      0, 1, 0, //
      0, 1, 0, //
      0, 1, 0, //
    ];
    uvs = [0, 0, 1, 0, 0, 1, 1, 1];

    // set index buffers and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));

    computeBufferInfo(gl);
  }
}
