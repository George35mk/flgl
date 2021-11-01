import 'dart:typed_data';

import 'package:flgl/flutter3d/core/buffer_attribute.dart';
import 'package:flgl/flutter3d/core/buffer_geometry.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'dart:math' as math;

class SphereGeometry extends BufferGeometry {
  OpenGLContextES gl;

  // int radius;
  // int widthSegments;
  // int heightSegments;
  // double phiStart;
  // double phiLength;
  // double thetaStart;
  // double thetaLength;

  List<int> indices = [];
  List<double> vertices = [];
  List<double> normals = [];
  List<double> uvs = [];

  SphereGeometry(
    this.gl,
    double radius,
    int subdivisionsAxis,
    int subdivisionsHeight, [
    double startLatitudeInRadians = 0.0,
    double endLatitudeInRadians = math.pi,
    double startLongitudeInRadians = 0.0,
    double endLongitudeInRadians = (math.pi * 2),
  ]) {
    var opt = computeSphereGeometry(
      radius,
      subdivisionsAxis,
      subdivisionsHeight,
      startLatitudeInRadians,
      endLatitudeInRadians,
      startLongitudeInRadians,
      endLongitudeInRadians,
    );

    var opt2 = deindexVertices(opt);
    indices = opt['indices']!.array.toList();
    vertices = opt2['vertices']!.array.toList();
    normals = opt2['normals']!.array.toList();
    uvs = opt2['uvs']!.array.toList();

    // Set index buffers and attributes.
    setIndex(indices);
    setAttribute('position', Float32BufferAttribute(vertices, 3));
    setAttribute('normal', Float32BufferAttribute(normals, 3));
    setAttribute('uv', Float32BufferAttribute(uvs, 2));
  }
}

Map<String, BufferAttribute> deindexVertices(Map<String, BufferAttribute> vertices) {
  BufferAttribute indices = vertices['indices']!;
  Map<String, BufferAttribute> newVertices = {};
  int numElements = indices.array.length;

  expandToUnindexed(String channel) {
    var srcBuffer = vertices[channel];
    // var numComponents = srcBuffer.numComponents;
    var numComponents = channel == 'uvs' ? 2 : 3;
    // var dstBuffer = createAugmentedTypedArray(numComponents, numElements, srcBuffer.constructor);
    // List<double> dstBuffer = [];
    BufferAttribute dstBuffer = BufferAttribute(Float32List(numElements * numComponents), numComponents);
    for (var ii = 0; ii < numElements; ++ii) {
      var ndx = indices.array[ii];
      var offset = ndx * numComponents;
      for (var jj = 0; jj < numComponents; ++jj) {
        // dstBuffer.add(srcBuffer[offset + jj]);
        dstBuffer.push([srcBuffer!.array[offset + jj]]);
      }
    }
    newVertices[channel] = dstBuffer;
  }

  // 'vertices': vertices,
  // 'normals': normals,
  // 'uvs': uvs,

  // Object.keys(vertices).filter(allButIndices).forEach(expandToUnindexed);
  List<String> options = ['vertices', 'normals', 'uvs'];
  for (var name in options) {
    expandToUnindexed(name);
  }

  return newVertices;
}

Map<String, BufferAttribute> computeSphereGeometry(
  double radius,
  int subdivisionsAxis,
  int subdivisionsHeight, [
  double startLatitudeInRadians = 0.0,
  double endLatitudeInRadians = math.pi,
  double startLongitudeInRadians = 0.0,
  double endLongitudeInRadians = (math.pi * 2),
]) {
  double latRange = endLatitudeInRadians - startLatitudeInRadians;
  double longRange = endLongitudeInRadians - startLongitudeInRadians;

  int numVertices = (subdivisionsAxis + 1) * (subdivisionsHeight + 1);

  // List<int> indices = [];
  // List<double> vertices = [];
  // List<double> normals = [];
  // List<double> uvs = [];

  BufferAttribute vertices = BufferAttribute(Float32List(numVertices * 3), 3);
  BufferAttribute normals = BufferAttribute(Float32List(numVertices * 3), 3);
  BufferAttribute uvs = BufferAttribute(Float32List(numVertices * 2), 2);

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

      vertices.push([radius * ux, radius * uy, radius * uz]);
      normals.push([ux, uy, uz]);
      uvs.push([1 - u, v]);
    }
  }

  int numVertsAround = subdivisionsAxis + 1;
  BufferAttribute indices = BufferAttribute(Uint16List((subdivisionsAxis * subdivisionsHeight * 2) * 3), 3);
  for (int x = 0; x < subdivisionsAxis; x++) {
    for (int y = 0; y < subdivisionsHeight; y++) {
      // Make triangle 1 of quad.
      indices.push([
        (y + 0) * numVertsAround + x,
        (y + 0) * numVertsAround + x + 1,
        (y + 1) * numVertsAround + x,
      ]);

      // Make triangle 2 of quad.
      indices.push([
        (y + 1) * numVertsAround + x,
        (y + 0) * numVertsAround + x + 1,
        (y + 1) * numVertsAround + x + 1,
      ]);
    }
  }

  return {
    'indices': indices,
    'vertices': vertices,
    'normals': normals,
    'uvs': uvs,
  };
}



///////////////////////////////////


// SphereGeometry(
//     this.gl, [
//     this.radius = 1,
//     this.widthSegments = 32,
//     this.heightSegments = 16,
//     this.phiStart = 0,
//     this.phiLength = math.pi * 2,
//     this.thetaStart = 0,
//     this.thetaLength = math.pi,
//   ]) {
//     widthSegments = math.max(3, widthSegments.floor());
//     heightSegments = math.max(2, heightSegments.floor());

//     var thetaEnd = math.min(thetaStart + thetaLength, math.pi);

//     var index = 0;
//     var grid = [];

//     var vertex = Vector3();
//     var normal = Vector3();

//     // buffers

//     // var indices = [];
//     // var vertices = [];
//     // var normals = [];
//     // var uvs = [];

//     // generate vertices, normals and uvs

//     for (var iy = 0; iy <= heightSegments; iy++) {
//       var verticesRow = [];

//       var v = iy / heightSegments;

//       // special case for the poles

//       var uOffset = 0;

//       if (iy == 0 && thetaStart == 0) {
//         uOffset = 0.5 ~/ widthSegments;
//       } else if (iy == heightSegments && thetaEnd == math.pi) {
//         uOffset = -0.5 ~/ widthSegments;
//       }

//       for (var ix = 0; ix <= widthSegments; ix++) {
//         var u = ix / widthSegments;

//         // vertex

//         vertex.x = -radius * math.cos(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);
//         vertex.y = radius * math.cos(thetaStart + v * thetaLength);
//         vertex.z = radius * math.sin(phiStart + u * phiLength) * math.sin(thetaStart + v * thetaLength);

//         vertices.addAll([vertex.x, vertex.y, vertex.z]);

//         // normal

//         normal.copy(vertex).normalize();
//         normals.addAll([normal.x, normal.y, normal.z]);

//         // uv

//         uvs.addAll([u + uOffset, 1 - v]);

//         verticesRow.add(index++);
//       }

//       grid.add(verticesRow);
//     }

//     // indices

//     for (var iy = 0; iy < heightSegments; iy++) {
//       for (var ix = 0; ix < widthSegments; ix++) {
//         var a = grid[iy][ix + 1];
//         var b = grid[iy][ix];
//         var c = grid[iy + 1][ix];
//         var d = grid[iy + 1][ix + 1];

//         if (iy != 0 || thetaStart > 0) indices.addAll([a, b, d]);
//         if (iy != heightSegments - 1 || thetaEnd < math.pi) indices.addAll([b, c, d]);
//       }
//     }