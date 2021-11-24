import 'package:flgl/flutter3d/core/neon_buffer_geometry.dart';

import 'dart:math' as math;

class NeonSphereGeometry extends NeonBufferGeometry {

  double radius;
  int subdivisionsAxis;
  int subdivisionsHeight;
  double startLatitudeInRadians;
  double endLatitudeInRadians;
  double startLongitudeInRadians;
  double endLongitudeInRadians;

  NeonSphereGeometry({
    this.radius = 20,
    this.subdivisionsAxis = 10,
    this.subdivisionsHeight = 10, 
    this.startLatitudeInRadians = 0.0,
    this.endLatitudeInRadians = math.pi,
    this.startLongitudeInRadians = 0.0,
    this.endLongitudeInRadians = (math.pi * 2),
  }) {

    double latRange = endLatitudeInRadians - startLatitudeInRadians;
    double longRange = endLongitudeInRadians - startLongitudeInRadians;

    // int numVertices = (subdivisionsAxis + 1) * (subdivisionsHeight + 1);

    for (int y = 0; y <= subdivisionsHeight; y++) {
      for (int x = 0; x <= subdivisionsAxis; x++) {
        // Generate a vertex based on its spherical coordinates
        var u = x / subdivisionsAxis;
        var v = y / subdivisionsHeight;
        var theta = longRange * u;
        var phi = latRange * v;
        var sinTheta = math.sin(theta);
        var cosTheta = math.cos(theta);
        var sinPhi = math.sin(phi);
        var cosPhi = math.cos(phi);
        var ux = cosTheta * sinPhi;
        var uy = cosPhi;
        var uz = sinTheta * sinPhi;

        // vertices.push([radius * ux, radius * uy, radius * uz]);
        // normals.push([ux, uy, uz]);
        // uvs.push([1 - u, v]);

        // vertices.addAll([radius * ux, radius * uy, radius * uz]);
        // normals.addAll([ux, uy, uz]);
        // uvs.addAll([1 - u, v]);

        vertices.addAll([radius * ux, radius * uy, radius * uz]); // vertices
        vertices.addAll([1, 1, 1, 1]); // colors
        vertices.addAll([ux, uy, uz]); // normals
        vertices.addAll([1 - u, v]); // uvs
      }
    }

    int numVertsAround = subdivisionsAxis + 1;

    for (int x = 0; x < subdivisionsAxis; x++) {
      for (int y = 0; y < subdivisionsHeight; y++) {
        // Make triangle 1 of quad.
        indices.addAll([
          (y + 0) * numVertsAround + x,
          (y + 0) * numVertsAround + x + 1,
          (y + 1) * numVertsAround + x,
        ]);

        // Make triangle 2 of quad.
        indices.addAll([
          (y + 1) * numVertsAround + x,
          (y + 0) * numVertsAround + x + 1,
          (y + 1) * numVertsAround + x + 1,
        ]);
      }
    }

    // Set index buffers and attributes.
    // setIndex(indices);
    // setAttribute('position', Float32BufferAttribute(vertices, 3));
    // setAttribute('normal', Float32BufferAttribute(normals, 3));
    // setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }

}