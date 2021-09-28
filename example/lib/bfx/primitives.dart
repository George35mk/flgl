import 'dart:math';

import 'dart:typed_data';

class AugmentTypedArray {
  
}

class PositionsData {
  int numComponents = 0;
  int numVertices = 0;
  int numElements = 0;
  late Float32List data;

  PositionsData(this.numComponents, this.numVertices) {
    data = Float32List(numComponents * numElements); 
    numElements = (data.length ~/ numComponents).toInt() | 0;
  }
}

class NormalsData {
  int numComponents = 0;
  int numVertices = 0;
  int numElements = 0;
  Float32List? data;

  NormalsData(this.numComponents, this.numVertices) {
    data = Float32List(numComponents * numElements); 
    numElements = (data!.length ~/ numComponents).toInt() | 0;
  }
}

class TexCoordsData {
  int numComponents = 0;
  int numVertices = 0;
  int numElements = 0;
  Float32List? data;

  TexCoordsData(this.numComponents, this.numVertices) {
    data = Float32List(numComponents * numElements); 
    numElements = (data!.length ~/ numComponents).toInt() | 0;
  }
}

class Primitives {

  createSphereVertices(
      radius,
      subdivisionsAxis,
      subdivisionsHeight,
      opt_startLatitudeInRadians,
      opt_endLatitudeInRadians,
      opt_startLongitudeInRadians,
      opt_endLongitudeInRadians) {
    if (subdivisionsAxis <= 0 || subdivisionsHeight <= 0) {
      throw ('subdivisionAxis and subdivisionHeight must be > 0');
    }

    opt_startLatitudeInRadians ??= 0;
    opt_endLatitudeInRadians ??= pi;
    opt_startLongitudeInRadians ??= 0;
    opt_endLongitudeInRadians ??= (pi * 2);

    var latRange = opt_endLatitudeInRadians - opt_startLatitudeInRadians;
    var longRange = opt_endLongitudeInRadians - opt_startLongitudeInRadians;

    // We are going to generate our sphere by iterating through its
    // spherical coordinates and generating 2 triangles for each quad on a
    // ring of the sphere.
    var numVertices = (subdivisionsAxis + 1) * (subdivisionsHeight + 1);
    var positions = PositionsData(3, numVertices);
    var normals   = NormalsData(3, numVertices);
    var texCoords = TexCoordsData(2 , numVertices);

    // Generate the individual vertices in our vertex buffer.
    // The goal here is to compute the spere positions, normals and texCoords.
    int index = 0;
    for (var y = 0; y <= subdivisionsHeight; y++) {
      for (var x = 0; x <= subdivisionsAxis; x++) {
        // Generate a vertex based on its spherical coordinates
        var u = x / subdivisionsAxis;
        var v = y / subdivisionsHeight;
        var theta = longRange * u + opt_startLongitudeInRadians;
        var phi = latRange * v + opt_startLatitudeInRadians;
        var sinTheta = sin(theta);
        var cosTheta = cos(theta);
        var sinPhi = sin(phi);
        var cosPhi = cos(phi);
        var ux = cosTheta * sinPhi;
        var uy = cosPhi;
        var uz = sinTheta * sinPhi;
        // positions.push(radius * ux, radius * uy, radius * uz);
        // normals.push(ux, uy, uz);
        // texCoords.push(1 - u, v);

        // set the positions.
        positions.data![index + 0] = radius * ux;
        positions.data![index + 1] = radius * uy;
        positions.data![index + 2] = radius * uz;

        // set the normals.
        normals.data![index + 0] = ux;
        normals.data![index + 1] = uy;
        normals.data![index + 2] = uz;

        // set the texCoords.
        texCoords.data![index + 0] = 1 - u;
        texCoords.data![index + 1] = v;

        index++;
      }
    }

    var numVertsAround = subdivisionsAxis + 1;
    var indices = webglUtils.createAugmentedTypedArray(3, subdivisionsAxis * subdivisionsHeight * 2, Uint16Array);
    for (let x = 0; x < subdivisionsAxis; x++) {
      for (let y = 0; y < subdivisionsHeight; y++) {
        // Make triangle 1 of quad.
        indices.push(
            (y + 0) * numVertsAround + x,
            (y + 0) * numVertsAround + x + 1,
            (y + 1) * numVertsAround + x);

        // Make triangle 2 of quad.
        indices.push(
            (y + 1) * numVertsAround + x,
            (y + 0) * numVertsAround + x + 1,
            (y + 1) * numVertsAround + x + 1);
      }
    }

    return {
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

  createFlattenedFunc(vertFunc) {
    return (gl, ...args) => {
      var vertices = vertFunc(...args);
      vertices = deindexVertices(vertices);
      vertices = makeRandomVertexColors(vertices, {
          vertsPerColor: 6,
          rand: function(ndx, channel) {
            return channel < 3 ? ((128 + Math.random() * 128) | 0) : 255;
          },
        });
      return webglUtils.createBufferInfoFromArrays(gl, vertices);
    };
  }

  createSphereWithVertexColorsBufferInfo() {
    return createFlattenedFunc(createSphereVertices);
  }
}
