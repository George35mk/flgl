import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';
import 'dart:math' as math;

class NeonConeGeometry extends NeonBufferGeometry {

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

  NeonConeGeometry({
    this.bottomRadius = 10.0,
    this.topRadius = 0.0,
    this.height = 40.0,
    this.radialSubdivisions = 10,
    this.verticalSubdivisions = 10,
    this.topCap = true,
    this.bottomCap = true,
  }) {

    if (radialSubdivisions < 3) {
      throw ('radialSubdivisions must be 3 or greater');
    }

    if (verticalSubdivisions < 1) {
      throw ('verticalSubdivisions must be 1 or greater');
    }

    int extra = (topCap ? 2 : 0) + (bottomCap ? 2 : 0);
    int vertsAroundEdge = radialSubdivisions + 1;

    // The slant of the cone is constant across its surface
    double slant = math.atan2(bottomRadius - topRadius, height);
    double cosSlant = math.cos(slant);
    double sinSlant = math.sin(slant);

    int start = topCap ? -2 : 0;
    int end = verticalSubdivisions + (bottomCap ? 2 : 0);

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

        List<double> _positions = [
          sin * ringRadius,
          y,
          cos * ringRadius,
        ];

        List<double> _normals = [
          yy < 0 || yy > verticalSubdivisions ? 0 : sin * cosSlant,
          yy < 0
              ? -1
              : yy > verticalSubdivisions
                  ? 1
                  : sinSlant,
          yy < 0 || yy > verticalSubdivisions ? 0 : cos * cosSlant
        ];

        List<double> _uvs = [ii / radialSubdivisions, 1 - v];
        List<double> _colors = [1, 1, 1, 1];

        // vertices.
        vertices.addAll(_positions);

        // colors
        vertices.addAll(_colors);

        // normals.
        vertices.addAll(_normals);

        // uvs.
        vertices.addAll(_uvs);
      }
    }

    // indices.
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
    
  }
}