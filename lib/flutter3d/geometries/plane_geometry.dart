import 'package:flgl/flgl_3d.dart';
import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';

class PlaneGeometry extends BufferGeometry {
  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  /// the plane width.
  double width;

  /// the plane height.
  double depth;

  /// the plane width subdivisions.
  int subdivisionsWidth;

  /// the plane depth subdivisions.
  int subdivisionsDepth;

  PlaneGeometry([
    this.width = 1,
    this.depth = 1,
    this.subdivisionsWidth = 1,
    this.subdivisionsDepth = 1,
  ]) {
    for (var z = 0; z <= subdivisionsDepth; z++) {
      for (var x = 0; x <= subdivisionsWidth; x++) {
        var u = x / subdivisionsWidth;
        var v = z / subdivisionsDepth;
        vertices.addAll([width * u - width * 0.5, 0, depth * v - depth * 0.5]);
        normals.addAll([0, 1, 0]);
        uvs.addAll([u, v]);
      }
    }

    var numVertsAcross = subdivisionsWidth + 1;

    for (var z = 0; z < subdivisionsDepth; z++) {
      for (var x = 0; x < subdivisionsWidth; x++) {
        // Make triangle 1 of quad.
        indices.addAll([
          (z + 0) * numVertsAcross + x,
          (z + 1) * numVertsAcross + x,
          (z + 0) * numVertsAcross + x + 1,
        ]);

        // Make triangle 2 of quad.
        indices.addAll([
          (z + 1) * numVertsAcross + x,
          (z + 1) * numVertsAcross + x + 1,
          (z + 0) * numVertsAcross + x + 1,
        ]);
      }
    }

    // Set index buffers and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}
