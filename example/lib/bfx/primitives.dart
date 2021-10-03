import 'dart:math';
import 'dart:typed_data';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

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
  int cursor = 0;

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
  }

  /// Returns the number of elements.
  get numElements {
    return (data.length ~/ numComponents).toInt() | 0;
  }

  push(List<num> args) {
    for (var i = 0; i < args.length; i++) {
      var value = args[i];
      data[cursor++] = value;
    }
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
      var dstBuffer = ArrayBuffer(numComponents, numElements, srcBuffer.type);

      for (var ii = 0; ii < numElements; ++ii) {
        var ndx = indices.data[ii];
        var offset = ndx * numComponents;
        for (var jj = 0; jj < numComponents; ++jj) {
          dstBuffer.push([srcBuffer.data[offset + jj]]);
        }
      }
      newVertices[channel] = dstBuffer;
    }

    vertices.forEach((key, value) {
      if (key != 'indices') {
        expandToUnindexed(key);
      }
    });

    return newVertices;
  }

  /// Creates an augmentedTypedArray of random vertex colors.
  ///
  /// If the vertices are indexed (have an indices array) then will
  /// just make random colors. Otherwise assumes they are triangless
  /// and makes one random color for every 3 vertices.
  /// - @param {Object.<string, augmentedTypedArray>} vertices Vertices as returned from one of the createXXXVertices functions.
  /// - @param {module:primitives.RandomVerticesOptions} [options] options.
  /// - @return {Object.<string, augmentedTypedArray>} same vertices as passed in with `color` added.
  /// - @memberOf module:primitives
  static makeRandomVertexColors(Map<String, ArrayBuffer> vertices, [options]) {
    options ??= {};
    var numElements = vertices['position']!.numElements;
    var vcolors = ArrayBuffer(4, numElements, 'Uint8');

    rand(ndx, int channel) {
      return channel < 3 ? Random().nextInt(256) : 255;
    }

    vertices['color'] = vcolors;
    if (vertices.containsKey('indices')) {
      for (var ii = 0; ii < numElements; ++ii) {
        vcolors.push([
          rand(ii, 0), // red
          rand(ii, 1), // green
          rand(ii, 2), // blue
          rand(ii, 3), // alpha
        ]);
      }
    } else {
      // make random colors per triangle
      var numVertsPerColor = options.containsKey('vertsPerColor') ? options['vertsPerColor'] : 3;
      var numSets = numElements / numVertsPerColor;

      for (var ii = 0; ii < numSets; ++ii) {
        var color = [rand(ii, 0), rand(ii, 1), rand(ii, 2), rand(ii, 3)];
        for (var jj = 0; jj < numVertsPerColor; ++jj) {
          vcolors.push(color);
        }
      }
    }
    return vertices;
  }

  // a_texcoord:'texcoord'
  // a_position:'position'
  // a_normal:'normal'
  // a_color:'color'
  static createMapping(Map<String, ArrayBuffer> obj) {
    var mapping = {};
    obj.forEach((key, value) {
      if (key != 'indices') {
        mapping['a_$key'] = key;
      }
    });
    return mapping;
  }

  static createBufferFromTypedArray(OpenGLContextES gl, ArrayBuffer array, [type, drawType]) {
    type ??= gl.ARRAY_BUFFER;
    drawType ??= gl.STATIC_DRAW;
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
  static createAttribsFromArrays(OpenGLContextES gl, Map<String, ArrayBuffer> arrays, [optMapping]) {
    var mapping = optMapping ?? createMapping(arrays);
    var attribs = {};
    mapping.forEach((attribName, value) {
      var bufferName = mapping[attribName];
      var origArray = arrays[bufferName];
      // var array = makeTypedArray(origArray, bufferName);
      var array = origArray;
      attribs[attribName] = {
        'buffer': createBufferFromTypedArray(gl, array!),
        'numComponents': origArray!.numComponents | array.numComponents,
        'type': getGLTypeForTypedArray(gl, array),
        'normalize': getNormalizationForTypedArray(array),
      };
    });
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
    key = key ?? arrays.keys.elementAt(0);

    var array = arrays[key] as ArrayBuffer;
    int length = array.data.length;
    var numComponents = array.numComponents;
    var numElements = (length ~/ numComponents).toInt();

    if (length % numComponents > 0) {
      throw 'numComponents $numComponents not correct for length $length';
    }
    return numElements;
  }

  static createBufferInfoFromArrays(OpenGLContextES gl, Map<String, ArrayBuffer> arrays, [optMapping]) {
    var bufferInfo = {
      'attribs': createAttribsFromArrays(gl, arrays, optMapping),
    };
    var indices = arrays['indices'];
    if (indices != null) {
      // you need to enable this code.
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
    double optEndLongitudeInRadians = pi * 2,
  ]) {
    if (subdivisionsAxis <= 0 || subdivisionsHeight <= 0) {
      throw ('subdivisionAxis and subdivisionHeight must be > 0');
    }

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

        positions.push([radius * ux, radius * uy, radius * uz]);
        normals.push([ux, uy, uz]);
        texCoords.push([1 - u, v]);
      }
    }

    int numVertsAround = subdivisionsAxis + 1;
    // var indices = webglUtils.createAugmentedTypedArray(3, subdivisionsAxis * subdivisionsHeight * 2, Uint16Array);
    var indices = ArrayBuffer(3, subdivisionsAxis * subdivisionsHeight * 2, 'Uint16');
    for (var x = 0; x < subdivisionsAxis; x++) {
      for (var y = 0; y < subdivisionsHeight; y++) {
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
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

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
    var options = {
      'vertsPerColor': 6,
      'rand': (ndx, channel) {
        return channel < 3 ? Random().nextInt(256) : 255;
      }
    };
    vertices = makeRandomVertexColors(vertices, options);

    // create buffer info from arrays.
    return createBufferInfoFromArrays(gl, vertices);
  }

  static createCubeVertices(num size) {
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

    var numVertices = 6 * 4;
    var positions = ArrayBuffer(3, numVertices, 'Float32');
    var normals = ArrayBuffer(3, numVertices, 'Float32');
    var texCoords = ArrayBuffer(2, numVertices, 'Float32');
    var indices = ArrayBuffer(3, 6 * 2, 'Uint16');

    for (var f = 0; f < 6; ++f) {
      var faceIndices = CUBE_FACE_INDICES[f];
      for (var v = 0; v < 4; ++v) {
        var position = cornerVertices[faceIndices[v]]; // Vec3
        var normal = faceNormals[f]; // Vec3
        var uv = uvCoords[v]; // Vec2

        // Each face needs all four vertices because the normals and texture
        // coordinates are not all the same.
        positions.push(position);
        normals.push([
          normal[0].toDouble(),
          normal[1].toDouble(),
          normal[2].toDouble(),
        ]);
        texCoords.push([
          uv[0].toDouble(),
          uv[1].toDouble(),
        ]);
      }
      // Two triangles make a square face.
      var offset = 4 * f;
      indices.push([offset + 0, offset + 1, offset + 2]);
      indices.push([offset + 0, offset + 2, offset + 3]);
    }

    return {
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

  static createCubeWithVertexColorsBufferInfo(OpenGLContextES gl, int size) {
    var vertices = createCubeVertices(size); // createCubeGeometry.
    vertices = deindexVertices(vertices);
    var options = {
      'vertsPerColor': 6,
      'rand': (ndx, channel) {
        return channel < 3 ? Random().nextInt(256) : 255;
      }
    };
    vertices = makeRandomVertexColors(vertices, options);
    return createBufferInfoFromArrays(gl, vertices);
  }

  static createTruncatedConeVertices(
    bottomRadius,
    topRadius,
    height,
    radialSubdivisions,
    verticalSubdivisions, [
    topCap,
    bottomCap,
  ]) {
    if (radialSubdivisions < 3) {
      throw 'radialSubdivisions must be 3 or greater';
    }

    if (verticalSubdivisions < 1) {
      throw 'verticalSubdivisions must be 1 or greater';
    }

    topCap ??= true;
    bottomCap ??= true;

    var extra = (topCap ? 2 : 0) + (bottomCap ? 2 : 0);

    var numVertices = (radialSubdivisions + 1) * (verticalSubdivisions + 1 + extra);
    var positions = ArrayBuffer(3, numVertices, 'Float32');
    var normals = ArrayBuffer(3, numVertices, 'Float32');
    var texCoords = ArrayBuffer(2, numVertices, 'Float32');
    var indices = ArrayBuffer(3, radialSubdivisions * (verticalSubdivisions + extra) * 2, 'Uint16');

    var vertsAroundEdge = radialSubdivisions + 1;

    // The slant of the cone is constant across its surface
    var slant = atan2(bottomRadius - topRadius, height);
    var cosSlant = cos(slant);
    var sinSlant = sin(slant);

    var start = topCap ? -2 : 0;
    var end = verticalSubdivisions + (bottomCap ? 2 : 0);

    for (var yy = start; yy <= end; ++yy) {
      var v = yy / verticalSubdivisions;
      var y = height * v;
      var ringRadius;

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
        var _sin = sin(ii * pi * 2 / radialSubdivisions);
        var _cos = cos(ii * pi * 2 / radialSubdivisions);

        positions.push([_sin * ringRadius, y, _cos * ringRadius]);

        normals.push([
          (yy < 0 || yy > verticalSubdivisions) ? 0.0 : (_sin * cosSlant),
          (yy < 0) ? -1.0 : (yy > verticalSubdivisions ? 1.0 : sinSlant),
          (yy < 0 || yy > verticalSubdivisions) ? 0.0 : (_cos * cosSlant)
        ]);

        texCoords.push([(ii / radialSubdivisions), 1 - v]);
      }
    }

    for (var yy = 0; yy < verticalSubdivisions + extra; ++yy) {
      for (var ii = 0; ii < radialSubdivisions; ++ii) {
        indices.push([
          vertsAroundEdge * (yy + 0) + 0 + ii,
          vertsAroundEdge * (yy + 0) + 1 + ii,
          vertsAroundEdge * (yy + 1) + 1 + ii,
        ]);

        indices.push([
          vertsAroundEdge * (yy + 0) + 0 + ii,
          vertsAroundEdge * (yy + 1) + 1 + ii,
          vertsAroundEdge * (yy + 1) + 0 + ii,
        ]);
      }
    }

    return {
      'position': positions,
      'normal': normals,
      'texcoord': texCoords,
      'indices': indices,
    };
  }

  static createTruncatedConeWithVertexColorsBufferInfo(
    OpenGLContextES gl,
    bottomRadius,
    topRadius,
    height,
    radialSubdivisions,
    verticalSubdivisions, [
    topCap,
    bottomCap,
  ]) {
    // create the cone vertices.
    var vertices = createTruncatedConeVertices(
      bottomRadius,
      topRadius,
      height,
      radialSubdivisions,
      verticalSubdivisions,
      topCap,
      bottomCap,
    );

    // deindex the vertices.
    vertices = deindexVertices(vertices);
    // add colors info
    var options = {
      'vertsPerColor': 6,
      'rand': (ndx, channel) {
        return channel < 3 ? Random().nextInt(256) : 255;
      }
    };
    vertices = makeRandomVertexColors(vertices, options);
    // create buffer info from arrays.
    return createBufferInfoFromArrays(gl, vertices);
  }
}
