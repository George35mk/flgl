import 'dart:math';
import 'dart:typed_data';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

// class AugmentTypedArray {}

// class PositionsData {
//   int numComponents = 0;
//   int numVertices = 0;
//   int numElements = 0;
//   late Float32List data;
//   String type = 'Float32';

//   PositionsData(this.numComponents, this.numVertices) {
//     data = Float32List(numComponents * numVertices);
//     numElements = (data.length ~/ numComponents).toInt() | 0;
//   }
// }

// class NormalsData {
//   int numComponents = 0;
//   int numVertices = 0;
//   int numElements = 0;
//   late Float32List data;
//   String type = 'Float32';

//   NormalsData(this.numComponents, this.numVertices) {
//     data = Float32List(numComponents * numVertices);
//     numElements = (data.length ~/ numComponents).toInt() | 0;
//   }
// }

// class TexCoordsData {
//   int numComponents = 0;
//   int numVertices = 0;
//   int numElements = 0;
//   late Float32List data;
//   String type = 'Float32';

//   TexCoordsData(this.numComponents, this.numVertices) {
//     data = Float32List(numComponents * numVertices);
//     numElements = (data.length ~/ numComponents).toInt() | 0;
//   }
// }

// class IndicesData {
//   int numComponents = 0;
//   int numVertices = 0;
//   int numElements = 0;
//   late Uint16List data;
//   String type = 'Uint16';

//   IndicesData(this.numComponents, this.numVertices) {
//     data = Uint16List(numComponents * numVertices);
//     numElements = (data.length ~/ numComponents).toInt() | 0;
//   }
// }

class ArrayBuffer {
  /// The number of [components].
  int numComponents = 0;

  /// The number of vertices.
  int numVertices = 0;

  /// The list type
  /// Supported types are:
  /// - Float32
  /// - Uint16
  /// - Uint8
  String type = '';

  /// The Array buffer data list.
  dynamic data;

  ArrayBuffer(this.numComponents, this.numVertices, this.type) {
    if (type == 'Float32') {
      data = Float32List(numComponents * numVertices);
    } else if (type == 'Uint16') {
      data = Uint16List(numComponents * numVertices);
    } else if (type == 'Uint8') {
      data = Uint8List(numComponents * numVertices);
    } else {
      throw 'Unsupported list type';
    }
    // numElements = (data.length ~/ numComponents).toInt() | 0;
  }

  /// Returns the number of elements.
  get numElements {
    return (data.length ~/ numComponents).toInt() | 0;
  }
}

///  Array of the indices of corners of each face of a cube.
///  @type {Array.<number[]>}
const CUBE_FACE_INDICES = [
  [3, 7, 5, 1], // right
  [6, 2, 0, 4], // left
  [6, 7, 3, 2], // ??
  [0, 1, 5, 4], // ??
  [7, 6, 4, 5], // front
  [2, 3, 1, 0], // back
];

class Primitives {
  List<dynamic> getAllExceptInticesList(List<dynamic> vertices) {
    List outputList = vertices.where((o) => o['category_id'] == '1').toList();
    return outputList;
  }

  /// Given indexed vertices creates a new set of vertices unindexed by expanding the indexed vertices.
  /// @param {Object.<string, TypedArray>} vertices The indexed vertices to deindex
  /// @return {Object.<string, TypedArray>} The deindexed vertices
  /// @memberOf module:primitives
  static deindexVertices(Map<String, ArrayBuffer> vertices) {
    var indices = vertices['indices']; // get the indices list.
    Map<String, ArrayBuffer> newVertices = {}; // create an empty map
    var numElements = indices!.data.length; // get the number of elements.

    expandToUnindexed(String channel) {
      var srcBuffer = vertices[channel];
      var numComponents = srcBuffer!.numComponents;
      // var dstBuffer = webglUtils.createAugmentedTypedArray(numComponents, numElements, srcBuffer.constructor);
      var dstBuffer = ArrayBuffer(numComponents, numElements, srcBuffer.type);
      var index = 0;
      for (var ii = 0; ii < numElements; ++ii) {
        var ndx = indices.data[ii];
        var offset = ndx * numComponents;
        for (var jj = 0; jj < numComponents; ++jj) {
          // dstBuffer.push(srcBuffer[offset + jj]);
          dstBuffer.data[index] = srcBuffer.data[offset + jj];
          index++;
        }
      }
      newVertices[channel] = dstBuffer;
    }

    // Object.keys(vertices).filter(allButIndices).forEach(expandToUnindexed);

    vertices.forEach((key, value) {
      if (key != 'indices') {
        expandToUnindexed(key);
      }
    });

    return newVertices;
  }

  /// Creates an augmentedTypedArray of random vertex colors.
  /// If the vertices are indexed (have an indices array) then will
  /// just make random colors. Otherwise assumes they are triangless
  /// and makes one random color for every 3 vertices.
  /// @param {Object.<string, augmentedTypedArray>} vertices Vertices as returned from one of the createXXXVertices functions.
  /// @param {module:primitives.RandomVerticesOptions} [options] options.
  /// @return {Object.<string, augmentedTypedArray>} same vertices as passed in with `color` added.
  /// @memberOf module:primitives
  static makeRandomVertexColors(Map<String, ArrayBuffer> vertices, [options]) {
    options ??= {};
    var numElements = vertices['position']!.numElements;
    // var vcolors = webglUtils.createAugmentedTypedArray(4, numElements, Uint8Array);
    var vcolors = ArrayBuffer(4, numElements, 'Uint8');
    var rand = options.rand ??
        (ndx, channel) {
          return channel < 3 ? Random().nextInt(256) : 255;
        };
    vertices['color'] = vcolors;
    if (vertices.containsKey('indices')) {
      // just make random colors if index
      int index = 0;
      for (var ii = 0; ii < numElements; ++ii) {
        // vcolors.push(rand(ii, 0), rand(ii, 1), rand(ii, 2), rand(ii, 3));
        vcolors.data[index + 0] = rand(ii, 0); // red
        vcolors.data[index + 1] = rand(ii, 1); // green
        vcolors.data[index + 2] = rand(ii, 2); // blue
        vcolors.data[index + 3] = rand(ii, 3); // alpha
        index++;
      }
    } else {
      // make random colors per triangle
      var numVertsPerColor = options.vertsPerColor | 3;
      var numSets = numElements / numVertsPerColor;

      int index = 0;
      for (var ii = 0; ii < numSets; ++ii) {
        var color = [rand(ii, 0), rand(ii, 1), rand(ii, 2), rand(ii, 3)];
        for (var jj = 0; jj < numVertsPerColor; ++jj) {
          // vcolors.push(color);
          vcolors.data[index + 0] = color[0];
          vcolors.data[index + 1] = color[1];
          vcolors.data[index + 2] = color[2];
          vcolors.data[index + 3] = color[3];
          index++;
        }
      }
    }
    return vertices;
  }

  // a_texcoord:'texcoord'
  // a_position:'position'
  // a_normal:'normal'
  // a_color:'color'
  static createMapping(obj) {
    const mapping = {};
    obj.forEach((key, value) {
      if (key != 'indices') {
        mapping['a_' + key] = key;
      }
    });
    return mapping;
  }

  static createBufferFromTypedArray(OpenGLContextES gl, ArrayBuffer array, [type, drawType]) {
    type = type | gl.ARRAY_BUFFER;
    drawType = drawType | gl.STATIC_DRAW;
    var buffer = gl.createBuffer();
    gl.bindBuffer(type, buffer);
    gl.bufferData(type, array.data, drawType);
    return buffer;
  }

  static getGLTypeForTypedArray(OpenGLContextES gl, ArrayBuffer typedArray) {
    if (typedArray.data is Int8List) {
      return gl.BYTE;
    }
    if (typedArray.data is Uint8List) {
      return gl.UNSIGNED_BYTE;
    }
    if (typedArray.data is Int16List) {
      return gl.SHORT;
    }
    if (typedArray.data is Uint16List) {
      return gl.UNSIGNED_SHORT;
    }
    if (typedArray.data is Int32List) {
      return gl.INT;
    }
    if (typedArray.data is Uint32List) {
      return gl.UNSIGNED_INT;
    }
    if (typedArray.data is Float32List) {
      return gl.FLOAT;
    }
    throw 'unsupported typed array type';
  }

  static getNormalizationForTypedArray(ArrayBuffer typedArray) {
    if (typedArray.data is Int8List) {
      return true;
    }
    if (typedArray.data is Uint8List) {
      return true;
    }
    return false;
  }

  // change arrays with arrayBuffers.
  static createAttribsFromArrays(OpenGLContextES gl, arrays, [opt_mapping]) {
    var mapping = opt_mapping | createMapping(arrays);
    var attribs = {};
    attribs.forEach((attribName, value) {
      var bufferName = mapping[attribName];
      var origArray = arrays[bufferName];
      if (origArray.value) {
        attribs[attribName] = {
          'value': origArray.value,
        };
      } else {
        // var array = makeTypedArray(origArray, bufferName);
        var array = origArray;
        attribs[attribName] = {
          'buffer': createBufferFromTypedArray(gl, array),
          // 'numComponents': origArray.numComponents || array.numComponents || guessNumComponentsFromName(bufferName),
          'numComponents': origArray.numComponents || array.numComponents,
          'type': getGLTypeForTypedArray(gl, array),
          'normalize': getNormalizationForTypedArray(array),
        };
      }
    });
    // Object.keys(mapping).forEach(function(attribName) {
    //   var bufferName = mapping[attribName];
    //   var origArray = arrays[bufferName];
    //   if (origArray.value) {
    //     attribs[attribName] = {
    //       'value': origArray.value,
    //     };
    //   } else {
    //     const array = makeTypedArray(origArray, bufferName);
    //     attribs[attribName] = {
    //       'buffer':        createBufferFromTypedArray(gl, array),
    //       'numComponents': origArray.numComponents || array.numComponents || guessNumComponentsFromName(bufferName),
    //       'type':          getGLTypeForTypedArray(gl, array),
    //       'normalize':     getNormalizationForTypedArray(array),
    //     };
    //   }
    // });
    return attribs;
  }

  /// tries to get the number of elements from a set of arrays.
  static getNumElementsFromNonIndexedArrays(Map<String, ArrayBuffer> arrays) {
    const positionKeys = ['position', 'positions', 'a_position'];

    var key;
    for (String k in positionKeys) {
      if (arrays.containsKey(k)) {
        key = k;
        break;
      }
    }

    // else get the first key in arrays
    key = key | arrays.keys.elementAt(0);
    // arrays.keys.elementAt(0);

    var array = arrays[key] as ArrayBuffer;
    var length = array.data.length;
    var numComponents = array.numComponents;
    var numElements = length / numComponents;
    if (length % numComponents > 0) {
      throw 'numComponents $numComponents not correct for length $length';
    }
    return numElements;
  }

  static createBufferInfoFromArrays(OpenGLContextES gl, arrays, [opt_mapping]) {
    var bufferInfo = {
      'attribs': createAttribsFromArrays(gl, arrays, opt_mapping),
    };
    var indices = arrays.indices;
    if (indices) {
      // indices = makeTypedArray(indices, 'indices');
      // bufferInfo['indices'] = createBufferFromTypedArray(gl, indices, gl.ELEMENT_ARRAY_BUFFER);
      // bufferInfo['numElements'] = indices.length;
    } else {
      bufferInfo['numElements'] = getNumElementsFromNonIndexedArrays(arrays);
    }

    return bufferInfo;
  }

  static createSphereVertices(
    int radius,
    int subdivisionsAxis,
    int subdivisionsHeight, [
    double optStartLatitudeInRadians = 0.0,
    double optEndLatitudeInRadians = pi,
    double optStartLongitudeInRadians = 0.0,
    double optEndLongitudeInRadians = (pi * 2),
  ]) {
    if (subdivisionsAxis <= 0 || subdivisionsHeight <= 0) {
      throw ('subdivisionAxis and subdivisionHeight must be > 0');
    }

    // optStartLatitudeInRadians ??= 0;
    // optEndLatitudeInRadians ??= pi;
    // optStartLongitudeInRadians ??= 0;
    // optEndLongitudeInRadians ??= (pi * 2);

    var latRange = optEndLatitudeInRadians - optStartLatitudeInRadians;
    var longRange = optEndLongitudeInRadians - optStartLongitudeInRadians;

    // We are going to generate our sphere by iterating through its
    // spherical coordinates and generating 2 triangles for each quad on a
    // ring of the sphere.
    var numVertices = (subdivisionsAxis + 1) * (subdivisionsHeight + 1);
    var positions = ArrayBuffer(3, numVertices, 'Float32');
    var normals = ArrayBuffer(3, numVertices, 'Float32');
    var texCoords = ArrayBuffer(2, numVertices, 'Float32');

    // Generate the individual vertices in our vertex buffer.
    // The goal here is to compute the spere positions, normals and texCoords.
    int index = 0;
    for (var y = 0; y <= subdivisionsHeight; y++) {
      for (var x = 0; x <= subdivisionsAxis; x++) {
        // Generate a vertex based on its spherical coordinates
        var u = x / subdivisionsAxis;
        var v = y / subdivisionsHeight;
        var theta = longRange * u + optStartLongitudeInRadians;
        var phi = latRange * v + optStartLatitudeInRadians;
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
        positions.data[index + 0] = radius * ux;
        positions.data[index + 1] = radius * uy;
        positions.data[index + 2] = radius * uz;

        // set the normals.
        normals.data[index + 0] = ux;
        normals.data[index + 1] = uy;
        normals.data[index + 2] = uz;

        // set the texCoords.
        texCoords.data[index + 0] = 1 - u;
        texCoords.data[index + 1] = v;

        index++;
      }
    }

    var indicesIndex = 0;
    int numVertsAround = subdivisionsAxis + 1;
    // var indices = webglUtils.createAugmentedTypedArray(3, subdivisionsAxis * subdivisionsHeight * 2, Uint16Array);
    var indices = ArrayBuffer(3, subdivisionsAxis * subdivisionsHeight * 2, 'Uint16');
    for (var x = 0; x < subdivisionsAxis; x++) {
      for (var y = 0; y < subdivisionsHeight; y++) {
        // Make triangle 1 of quad.
        // indices.push(
        //     (y + 0) * numVertsAround + x,
        //     (y + 0) * numVertsAround + x + 1,
        //     (y + 1) * numVertsAround + x);

        // Make triangle 2 of quad.
        // indices.push(
        //     (y + 1) * numVertsAround + x,
        //     (y + 0) * numVertsAround + x + 1,
        //     (y + 1) * numVertsAround + x + 1);

        // Make triangle 1 of quad.
        indices.data[indicesIndex + 0] = (y + 0) * numVertsAround + x;
        indices.data[indicesIndex + 1] = (y + 0) * numVertsAround + x + 1;
        indices.data[indicesIndex + 2] = (y + 1) * numVertsAround + x;

        // Make triangle 2 of quad.
        indices.data[indicesIndex + 3] = (y + 1) * numVertsAround + x;
        indices.data[indicesIndex + 4] = (y + 0) * numVertsAround + x + 1;
        indices.data[indicesIndex + 5] = (y + 1) * numVertsAround + x + 1;

        indicesIndex++;
      }
    }

    return {
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

  // createFlattenedFunc(vertFunc) {
  //   return (gl, ...args) => {
  //     var vertices = vertFunc(...args);
  //     vertices = deindexVertices(vertices);
  //     // add colors
  //     vertices = makeRandomVertexColors(vertices, {
  //         vertsPerColor: 6,
  //         rand: function(ndx, channel) {
  //           return channel < 3 ? ((128 + Math.random() * 128) | 0) : 255;
  //         },
  //       });
  //     return webglUtils.createBufferInfoFromArrays(gl, vertices);
  //   };
  // }

  static createSphereWithVertexColorsBufferInfo(
    OpenGLContextES gl,
    int radius,
    int subdivisionsAxis,
    int subdivisionsHeight, [
    double startLatitudeInRadians = 0.0,
    double endLatitudeInRadians = pi,
    double startLongitudeInRadians = 0.0,
    double endLongitudeInRadians = (pi * 2),
  ]) {
    // create the sphere vertices.
    var vertices = createSphereVertices(
      radius,
      subdivisionsAxis,
      subdivisionsHeight,
      startLatitudeInRadians,
      endLatitudeInRadians,
      startLongitudeInRadians,
      endLongitudeInRadians,
    );
    // deindex the vertices.
    vertices = deindexVertices(vertices);
    // add colors info
    vertices = makeRandomVertexColors(vertices);
    // create buffer info from arrays.
    return createBufferInfoFromArrays(gl, vertices);
  }

  createCubeVertices(num size) {
    double k = size / 2;

    List<List<num>> cornerVertices = [
      [-k, -k, -k],
      [k, -k, -k],
      [-k, k, -k],
      [k, k, -k],
      [-k, -k, k],
      [k, -k, k],
      [-k, k, k],
      [k, k, k],
    ];

    List<List<int>> faceNormals = [
      [1, 0, 0],
      [-1, 0, 0],
      [0, 1, 0],
      [0, -1, 0],
      [0, 0, 1],
      [0, 0, -1],
    ];

    List<List<int>> uvCoords = [
      [1, 0],
      [0, 0],
      [0, 1],
      [1, 1],
    ];

    const numVertices = 6 * 4;
    var positions = ArrayBuffer(3, numVertices, 'Float32');
    var normals = ArrayBuffer(3, numVertices, 'Float32');
    var texCoords = ArrayBuffer(2, numVertices, 'Float32');
    var indices = ArrayBuffer(3, 6 * 2, 'Uint16');

    int index = 0;
    for (var f = 0; f < 6; ++f) {
      var faceIndices = CUBE_FACE_INDICES[f];
      for (var v = 0; v < 4; ++v) {
        var position = cornerVertices[faceIndices[v]]; // Vec3
        var normal = faceNormals[f]; // Vec3
        var uv = uvCoords[v]; // Vec2

        // Each face needs all four vertices because the normals and texture
        // coordinates are not all the same.
        // positions.push(position);
        // normals.push(normal);
        // texCoords.push(uv);

        positions.data[index + 0] = position[0].toDouble();
        positions.data[index + 1] = position[1].toDouble();
        positions.data[index + 2] = position[2].toDouble();

        normals.data[index + 0] = normal[0].toDouble();
        normals.data[index + 1] = normal[1].toDouble();
        normals.data[index + 2] = normal[2].toDouble();

        texCoords.data[index + 0] = uv[0].toDouble();
        texCoords.data[index + 1] = uv[1].toDouble();
      }
      // Two triangles make a square face.
      var offset = 4 * f;
      // indices.push(offset + 0, offset + 1, offset + 2);
      // indices.push(offset + 0, offset + 2, offset + 3);

      indices.data[index + 0] = offset + 0;
      indices.data[index + 1] = offset + 1;
      indices.data[index + 2] = offset + 2;
      indices.data[index + 3] = offset + 0;
      indices.data[index + 4] = offset + 2;
      indices.data[index + 5] = offset + 3;

      index++;
    }

    return {
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

  createCubeWithVertexColorsBufferInfo(OpenGLContextES gl, int size) {
    // create the sphere vertices.
    var vertices = createCubeVertices(size); // createCubeGeometry.
    // deindex the vertices.
    vertices = deindexVertices(vertices);
    // add colors info
    var options = {
      'vertsPerColor': 6,
      'rand': (ndx, channel) {
        return channel < 3 ? Random().nextInt(256) : 255;
      }
    };
    vertices = makeRandomVertexColors(vertices);
    // create buffer info from arrays.
    return createBufferInfoFromArrays(gl, vertices);
  }
}
