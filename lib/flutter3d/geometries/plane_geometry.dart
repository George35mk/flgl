import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';

class PlaneGeometry extends BufferGeometry {
  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  PlaneGeometry() {
    // Compute the indices, vertices, normals and uvs.
    indices = [
      0, 2, 1, //
      0, 3, 2, //
    ];
    vertices = [
      0.5, 0.5, 0.0, // top right
      0.5, -0.5, 0.0, // bottom right
      -0.5, -0.5, 0.0, // bottom left
      -0.5, 0.5, 0.0 // top left
    ];
    normals = [
      0, 1, 0, //
      0, 1, 0, //
      0, 1, 0, //
      0, 1, 0, //
    ];
    uvs = [0, 0, 1, 0, 0, 1, 1, 1];

    // Set index buffers and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}
