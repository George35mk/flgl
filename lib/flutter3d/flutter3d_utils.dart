// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'core/buffer_geometry.dart';

class Flutter3DUtils {
  Map typeMap = {};
  Map attrTypeMap = {};

  int FLOAT = 0x1406;
  int FLOAT_VEC2 = 0x8B50;
  int FLOAT_VEC3 = 0x8B51;
  int FLOAT_VEC4 = 0x8B52;
  int INT = 0x1404;
  int INT_VEC2 = 0x8B53;
  int INT_VEC3 = 0x8B54;
  int INT_VEC4 = 0x8B55;
  int BOOL = 0x8B56;
  int BOOL_VEC2 = 0x8B57;
  int BOOL_VEC3 = 0x8B58;
  int BOOL_VEC4 = 0x8B59;
  int FLOAT_MAT2 = 0x8B5A;
  int FLOAT_MAT3 = 0x8B5B;
  int FLOAT_MAT4 = 0x8B5C;
  int SAMPLER_2D = 0x8B5E;
  int SAMPLER_CUBE = 0x8B60;
  int SAMPLER_3D = 0x8B5F;
  int SAMPLER_2D_SHADOW = 0x8B62;
  int FLOAT_MAT2x3 = 0x8B65;
  int FLOAT_MAT2x4 = 0x8B66;
  int FLOAT_MAT3x2 = 0x8B67;
  int FLOAT_MAT3x4 = 0x8B68;
  int FLOAT_MAT4x2 = 0x8B69;
  int FLOAT_MAT4x3 = 0x8B6A;
  int SAMPLER_2D_ARRAY = 0x8DC1;
  int SAMPLER_2D_ARRAY_SHADOW = 0x8DC4;
  int SAMPLER_CUBE_SHADOW = 0x8DC5;
  int UNSIGNED_INT = 0x1405;
  int UNSIGNED_INT_VEC2 = 0x8DC6;
  int UNSIGNED_INT_VEC3 = 0x8DC7;
  int UNSIGNED_INT_VEC4 = 0x8DC8;
  int INT_SAMPLER_2D = 0x8DCA;
  int INT_SAMPLER_3D = 0x8DCB;
  int INT_SAMPLER_CUBE = 0x8DCC;
  int INT_SAMPLER_2D_ARRAY = 0x8DCF;
  int UNSIGNED_INT_SAMPLER_2D = 0x8DD2;
  int UNSIGNED_INT_SAMPLER_3D = 0x8DD3;
  int UNSIGNED_INT_SAMPLER_CUBE = 0x8DD4;
  int UNSIGNED_INT_SAMPLER_2D_ARRAY = 0x8DD7;

  int TEXTURE_2D = 0x0DE1;
  int TEXTURE_CUBE_MAP = 0x8513;
  int TEXTURE_3D = 0x806F;
  int TEXTURE_2D_ARRAY = 0x8C1A;

  Flutter3DUtils() {
    attrTypeMap[FLOAT] = {'size': 4, 'setter': floatAttribSetter};
    attrTypeMap[FLOAT_VEC2] = {'size': 8, 'setter': floatAttribSetter};
    attrTypeMap[FLOAT_VEC3] = {'size': 12, 'setter': floatAttribSetter};
    attrTypeMap[FLOAT_VEC4] = {'size': 16, 'setter': floatAttribSetter};
    attrTypeMap[INT] = {'size': 4, 'setter': intAttribSetter};
    attrTypeMap[INT_VEC2] = {'size': 8, 'setter': intAttribSetter};
    attrTypeMap[INT_VEC3] = {'size': 12, 'setter': intAttribSetter};
    attrTypeMap[INT_VEC4] = {'size': 16, 'setter': intAttribSetter};
    attrTypeMap[UNSIGNED_INT] = {'size': 4, 'setter': intAttribSetter};
    attrTypeMap[UNSIGNED_INT_VEC2] = {'size': 8, 'setter': intAttribSetter};
    attrTypeMap[UNSIGNED_INT_VEC3] = {'size': 12, 'setter': intAttribSetter};
    attrTypeMap[UNSIGNED_INT_VEC4] = {'size': 16, 'setter': intAttribSetter};
    attrTypeMap[BOOL] = {'size': 4, 'setter': intAttribSetter};
    attrTypeMap[BOOL_VEC2] = {'size': 8, 'setter': intAttribSetter};
    attrTypeMap[BOOL_VEC3] = {'size': 12, 'setter': intAttribSetter};
    attrTypeMap[BOOL_VEC4] = {'size': 16, 'setter': intAttribSetter};
    attrTypeMap[FLOAT_MAT2] = {'size': 4, 'setter': matAttribSetter, 'count': 2};
    attrTypeMap[FLOAT_MAT3] = {'size': 9, 'setter': matAttribSetter, 'count': 3};
    attrTypeMap[FLOAT_MAT4] = {'size': 16, 'setter': matAttribSetter, 'count': 4};

    typeMap[FLOAT] = {'Type': Float32List, 'size': 4, 'setter': floatSetter, 'arraySetter': floatArraySetter};
    typeMap[FLOAT_VEC2] = {'Type': Float32List, 'size': 8, 'setter': floatVec2Setter};
    typeMap[FLOAT_VEC3] = {'Type': Float32List, 'size': 12, 'setter': floatVec3Setter};
    typeMap[FLOAT_VEC4] = {'Type': Float32List, 'size': 16, 'setter': floatVec4Setter};
    typeMap[INT] = {'Type': Int32List, 'size': 4, 'setter': intSetter, 'arraySetter': intArraySetter};
    typeMap[INT_VEC2] = {'Type': Int32List, 'size': 8, 'setter': intVec2Setter};
    typeMap[INT_VEC3] = {'Type': Int32List, 'size': 12, 'setter': intVec3Setter};
    typeMap[INT_VEC4] = {'Type': Int32List, 'size': 16, 'setter': intVec4Setter};
    typeMap[UNSIGNED_INT] = {'Type': Uint32List, 'size': 4, 'setter': uintSetter, 'arraySetter': uintArraySetter};
    typeMap[UNSIGNED_INT_VEC2] = {'Type': Uint32List, 'size': 8, 'setter': uintVec2Setter};
    typeMap[UNSIGNED_INT_VEC3] = {'Type': Uint32List, 'size': 12, 'setter': uintVec3Setter};
    typeMap[UNSIGNED_INT_VEC4] = {'Type': Uint32List, 'size': 16, 'setter': uintVec4Setter};
    typeMap[BOOL] = {'Type': Uint32List, 'size': 4, 'setter': intSetter, 'arraySetter': intArraySetter};
    typeMap[BOOL_VEC2] = {'Type': Uint32List, 'size': 8, 'setter': intVec2Setter};
    typeMap[BOOL_VEC3] = {'Type': Uint32List, 'size': 12, 'setter': intVec3Setter};
    typeMap[BOOL_VEC4] = {'Type': Uint32List, 'size': 16, 'setter': intVec4Setter};
    typeMap[FLOAT_MAT2] = {'Type': Float32List, 'size': 16, 'setter': floatMat2Setter};
    typeMap[FLOAT_MAT3] = {'Type': Float32List, 'size': 36, 'setter': floatMat3Setter};
    typeMap[FLOAT_MAT4] = {'Type': Float32List, 'size': 64, 'setter': floatMat4Setter};
    typeMap[FLOAT_MAT2x3] = {'Type': Float32List, 'size': 24, 'setter': floatMat23Setter};
    typeMap[FLOAT_MAT2x4] = {'Type': Float32List, 'size': 32, 'setter': floatMat24Setter};
    typeMap[FLOAT_MAT3x2] = {'Type': Float32List, 'size': 24, 'setter': floatMat32Setter};
    typeMap[FLOAT_MAT3x4] = {'Type': Float32List, 'size': 48, 'setter': floatMat34Setter};
    typeMap[FLOAT_MAT4x2] = {'Type': Float32List, 'size': 32, 'setter': floatMat42Setter};
    typeMap[FLOAT_MAT4x3] = {'Type': Float32List, 'size': 48, 'setter': floatMat43Setter};
    typeMap[SAMPLER_2D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D
    };
    typeMap[SAMPLER_CUBE] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_CUBE_MAP
    };
    typeMap[SAMPLER_3D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_3D
    };
    typeMap[SAMPLER_2D_SHADOW] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D
    };
    typeMap[SAMPLER_2D_ARRAY] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D_ARRAY
    };
    typeMap[SAMPLER_2D_ARRAY_SHADOW] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D_ARRAY
    };
    typeMap[SAMPLER_CUBE_SHADOW] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_CUBE_MAP
    };
    typeMap[INT_SAMPLER_2D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D
    };
    typeMap[INT_SAMPLER_3D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_3D
    };
    typeMap[INT_SAMPLER_CUBE] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_CUBE_MAP
    };
    typeMap[INT_SAMPLER_2D_ARRAY] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D_ARRAY
    };
    typeMap[UNSIGNED_INT_SAMPLER_2D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D
    };
    typeMap[UNSIGNED_INT_SAMPLER_3D] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_3D
    };
    typeMap[UNSIGNED_INT_SAMPLER_CUBE] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_CUBE_MAP
    };
    typeMap[UNSIGNED_INT_SAMPLER_2D_ARRAY] = {
      'Type': null,
      'size': 0,
      'setter': samplerSetter,
      'arraySetter': samplerArraySetter,
      'bindPoint': TEXTURE_2D_ARRAY
    };
  }

  getBindPointForSamplerType(gl, type) {
    return typeMap[type]['bindPoint'];
  }

  floatSetter(OpenGLContextES gl, location) {
    return (v) => gl.uniform1f(location, v);
  }

  floatArraySetter(OpenGLContextES gl, location) {
    return (v) => {gl.uniform1fv(location, v)};
  }

  floatVec2Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform2fv(location, v);
    };
  }

  floatVec3Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform3fv(location, v);
    };
  }

  floatVec4Setter(OpenGLContextES gl, location) {
    return (List<double> v) {
      gl.uniform4fv(location, v);
    };
  }

  intSetter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform1i(location, v);
    };
  }

  intArraySetter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform1iv(location, v);
    };
  }

  intVec2Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform2iv(location, v);
    };
  }

  intVec3Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform3iv(location, v);
    };
  }

  intVec4Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform4iv(location, v);
    };
  }

  uintSetter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform1ui(location, v);
    };
  }

  uintArraySetter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform1uiv(location, v);
    };
  }

  uintVec2Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform2uiv(location, v);
    };
  }

  uintVec3Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform3uiv(location, v);
    };
  }

  uintVec4Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniform4uiv(location, v);
    };
  }

  floatMat2Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix2fv(location, false, v);
    };
  }

  floatMat3Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix3fv(location, false, v);
    };
  }

  floatMat4Setter(OpenGLContextES gl, location) {
    //  v: List<double>
    return (v) {
      // mpori na einai kai provlima to Float32List, ean ne totes vgalto.
      gl.uniformMatrix4fv(location, false, v); // change the last param type from List<num> to List<double>
    };
  }

  floatMat23Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix2x3fv(location, false, v);
    };
  }

  floatMat32Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix3x2fv(location, false, v);
    };
  }

  floatMat24Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix2x4fv(location, false, v);
    };
  }

  floatMat42Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix4x2fv(location, false, v);
    };
  }

  floatMat34Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix3x4fv(location, false, v);
    };
  }

  floatMat43Setter(OpenGLContextES gl, location) {
    return (v) {
      gl.uniformMatrix4x3fv(location, false, v);
    };
  }

  samplerSetter(OpenGLContextES gl, type, int unit, location, [test]) {
    var bindPoint = getBindPointForSamplerType(gl, type);
    return (dynamic textureOrPair) {
      int texture = textureOrPair;
      // if (textureOrPair is WebGLTexture) {
      //   texture = textureOrPair;
      // } else {
      //   // maybe I don't need this part for now.
      //   texture = textureOrPair.texture;
      //   gl.bindSampler(unit, textureOrPair.sampler); // ! fix this
      // }

      gl.uniform1i(location, unit);
      gl.activeTexture(gl.TEXTURE0 + unit);
      gl.bindTexture(bindPoint, texture);
    };
  }

  samplerArraySetter(OpenGLContextES gl, type, unit, location, int size) {
    var bindPoint = getBindPointForSamplerType(gl, type);
    var units = Int32List(size);
    for (var ii = 0; ii < size; ++ii) {
      units[ii] = unit + ii;
    }

    return (List textures) {
      // gl.uniform1iv(location, units);
      // textures.forEach((textureOrPair, index) {
      //   gl.activeTexture(gl.TEXTURE0 + units[index]);
      //   var texture = 0;
      //   if (textureOrPair is WebGLTexture) {
      //     texture = textureOrPair;
      //   } else {
      //     texture = textureOrPair.texture;
      //     gl.bindSampler(unit, textureOrPair.sampler);
      //   }
      //   gl.bindTexture(bindPoint, texture);
      // });
    };
  }

  floatAttribSetter(OpenGLContextES gl, int index, [typeInfo]) {
    return (AttributeBufferInfo b) {
      gl.bindBuffer(gl.ARRAY_BUFFER, b.buffer);
      gl.enableVertexAttribArray(index);
      gl.vertexAttribPointer(index, b.numComponents, b.type, b.normalize, b.stride, b.offset);
    };
  }

  intAttribSetter(OpenGLContextES gl, index) {
    return (b) {
      gl.bindBuffer(gl.ARRAY_BUFFER, b.buffer);
      gl.enableVertexAttribArray(index);
      gl.vertexAttribIPointer(index, b.numComponents ?? b.size, b.type ?? gl.INT, b.stride ?? 0, b.offset ?? 0);
    };
  }

  matAttribSetter(OpenGLContextES gl, index, typeInfo) {
    var defaultSize = typeInfo.size;
    int count = typeInfo.count;

    return (AttributeBufferInfo b) {
      gl.bindBuffer(gl.ARRAY_BUFFER, b.buffer);
      int numComponents = b.numComponents;
      int size = numComponents ~/ count;
      int type = b.type;
      var typeInfo = typeMap[type];
      int stride = typeInfo.size * numComponents;
      bool normalize = b.normalize || false;
      int offset = b.offset;
      int rowOffset = stride ~/ count;
      for (var i = 0; i < count; ++i) {
        gl.enableVertexAttribArray(index + i);
        gl.vertexAttribPointer(index + i, size, type, normalize, stride, offset + rowOffset * i);
      }
    };
  }
}
