import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';

class NeonTriangleGeometry extends NeonBufferGeometry {

  NeonTriangleGeometry() {
    // Compute the indices, vertices, normals and uvs.
    indices = [0, 2, 1]; // 1
    vertices = [0, 0, 0, 0, 0.5, 0, 0.5, 0, 0]; // 3
    normals = [0, 1, 0, 0, 1, 0, 0, 1, 0]; // 3
    uvs = [0, 0, 1, 0, 0, 1, 1, 1]; // 2
  }
}
