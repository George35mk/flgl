import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class BoxGeometry extends BufferGeometry {
  OpenGLContextES gl;

  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  BoxGeometry(this.gl, [double size = 1.0]) {
    double k = size / 2;

    List<List<double>> cornerVertices = [
      [-k, -k, -k],
      [k, -k, -k],
      [-k, k, -k],
      [k, k, -k],
      [-k, -k, k],
      [k, -k, k],
      [-k, k, k],
      [k, k, k],
    ];

    List<List<double>> faceNormals = [
      [1, 0, 0],
      [-1, 0, 0],
      [0, 1, 0],
      [0, -1, 0],
      [0, 0, 1],
      [0, 0, -1],
    ];

    List<List<double>> uvCoords = [
      [1, 0],
      [0, 0],
      [0, 1],
      [1, 1],
    ];

    List<List<int>> cubeFaceIndices = [
      [3, 7, 5, 1], // right
      [6, 2, 0, 4], // left
      [6, 7, 3, 2], // ??
      [0, 1, 5, 4], // ??
      [7, 6, 4, 5], // front
      [2, 3, 1, 0],
    ];

    for (int f = 0; f < 6; ++f) {
      List<int> faceIndices = cubeFaceIndices[f];
      for (int v = 0; v < 4; ++v) {
        List<double> position = cornerVertices[faceIndices[v]];
        List<double> normal = faceNormals[f];
        List<double> uv = uvCoords[v];

        // Each face needs all four vertices because the normals and texture
        // coordinates are not all the same.
        vertices.addAll(position);
        normals.addAll(normal);
        uvs.addAll(uv);
      }
      // Two triangles make a square face.
      int offset = 4 * f;
      indices.addAll([offset + 0, offset + 1, offset + 2]);
      indices.addAll([offset + 0, offset + 2, offset + 3]);
    }

    // Set index buffers and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}
