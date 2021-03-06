import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';

class TriangleGeometry extends BufferGeometry {
  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  TriangleGeometry() {
    // Compute the indices, vertices, normals and uvs.
    indices = [0, 2, 1];
    vertices = [0, 0, 0, 0, 0.5, 0, 0.5, 0, 0];
    normals = [0, 1, 0, 0, 1, 0, 0, 1, 0];
    uvs = [0, 0, 1, 0, 0, 1, 1, 1];

    // Set index buffer and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}
