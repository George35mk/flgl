import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';

import 'dart:math' as math;

class ConeGeometry extends BufferGeometry {
  /// Bottom radius of truncated cone.
  double bottomRadius;

  /// Top radius of truncated cone.
  double topRadius;

  /// Height of truncated cone.
  double height;

  /// The number of subdivisions around the truncated cone.
  int radialSubdivisions;

  /// The number of subdivisions down the truncated cone.
  int verticalSubdivisions;

  /// Create top cap. Default = true.
  bool topCap;

  /// Create bottom cap. Default = true.
  bool bottomCap;

  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  ConeGeometry(
    this.bottomRadius,
    this.topRadius,
    this.height,
    this.radialSubdivisions,
    this.verticalSubdivisions, [
    this.topCap = true,
    this.bottomCap = true,
  ]) {
    if (radialSubdivisions < 3) {
      throw ('radialSubdivisions must be 3 or greater');
    }

    if (verticalSubdivisions < 1) {
      throw ('verticalSubdivisions must be 1 or greater');
    }

    // bool topCap = opt_topCap == null ? true : opt_topCap;
    // bool bottomCap = opt_bottomCap == null ? true : opt_bottomCap;

    var extra = (topCap ? 2 : 0) + (bottomCap ? 2 : 0);

    var numVertices = (radialSubdivisions + 1) * (verticalSubdivisions + 1 + extra);

    var vertsAroundEdge = radialSubdivisions + 1;

    // The slant of the cone is constant across its surface
    var slant = math.atan2(bottomRadius - topRadius, height);
    var cosSlant = math.cos(slant);
    var sinSlant = math.sin(slant);

    var start = topCap ? -2 : 0;
    var end = verticalSubdivisions + (bottomCap ? 2 : 0);

    for (int yy = start; yy <= end; ++yy) {
      double v = yy / verticalSubdivisions;
      double y = height * v;
      double ringRadius;

      if (yy < 0) {
        y = 0;
        v = 1;
        ringRadius = bottomRadius;
      } else if (yy > verticalSubdivisions) {
        y = height;
        v = 1;
        ringRadius = topRadius;
      } else {
        ringRadius = bottomRadius + (topRadius - bottomRadius) * (yy / verticalSubdivisions);
      }

      if (yy == -2 || yy == verticalSubdivisions + 2) {
        ringRadius = 0;
        v = 0;
      }

      y -= height / 2;
      for (var ii = 0; ii < vertsAroundEdge; ++ii) {
        var sin = math.sin(ii * math.pi * 2 / radialSubdivisions);
        var cos = math.cos(ii * math.pi * 2 / radialSubdivisions);

        vertices.addAll([
          sin * ringRadius,
          y,
          cos * ringRadius,
        ]);

        normals.addAll([
          yy < 0 || yy > verticalSubdivisions ? 0 : sin * cosSlant,
          yy < 0
              ? -1
              : yy > verticalSubdivisions
                  ? 1
                  : sinSlant,
          yy < 0 || yy > verticalSubdivisions ? 0 : cos * cosSlant
        ]);

        uvs.addAll([ii / radialSubdivisions, 1 - v]);
      }
    }

    for (int yy = 0; yy < verticalSubdivisions + extra; ++yy) {
      for (int ii = 0; ii < radialSubdivisions; ++ii) {
        indices.addAll([
          vertsAroundEdge * (yy + 0) + 0 + ii,
          vertsAroundEdge * (yy + 0) + 1 + ii,
          vertsAroundEdge * (yy + 1) + 1 + ii
        ]);
        indices.addAll([
          vertsAroundEdge * (yy + 0) + 0 + ii,
          vertsAroundEdge * (yy + 1) + 1 + ii,
          vertsAroundEdge * (yy + 1) + 0 + ii
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
