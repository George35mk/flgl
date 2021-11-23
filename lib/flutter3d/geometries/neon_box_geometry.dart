import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';
import 'package:flgl/flutter3d/math/color.dart';

class NeonBoxGeometry extends NeonBufferGeometry {

  NeonBoxGeometry([double size = 1.0]) {
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

    List<Color> faceColors = [
      Color(1, 0, 0, 1), // face 1
      Color(0, 1, 0, 1), // face 2
      Color(0, 0, 1, 1), // face 3
      Color(1, 1, 0, 1), // face 4
      Color(0, 1, 1, 1), // face 5
      Color(1, 0, 1, 1), // face 6
    ];

    for (int f = 0; f < 6; ++f) {
      List<int> faceIndices = cubeFaceIndices[f];
      Color faceColor = faceColors[f];

      for (int v = 0; v < 4; ++v) {
        List<double> position = cornerVertices[faceIndices[v]];
        List<double> normal = faceNormals[f];
        List<double> uv = uvCoords[v];

        // Each face needs all four vertices because the normals and texture
        // coordinates are not all the same.
        vertices.addAll(position);
        vertices.addAll(faceColor.toArray());
        vertices.addAll(normal);
        vertices.addAll(uv);
      }
      // Two triangles make a square face.
      int offset = 4 * f;
      indices.addAll([offset + 0, offset + 1, offset + 2]);
      indices.addAll([offset + 0, offset + 2, offset + 3]);
    }
  }
}
