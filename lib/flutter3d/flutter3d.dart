import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'core/buffer_geometry.dart';
import 'core/programs.dart';
import 'flutter3d_utils.dart';

class Flutter3D {
  static Flutter3DUtils flutter3DUtils = Flutter3DUtils();

  Flutter3D();

  static int createShader(OpenGLContextES gl, int type, String source) {
    int shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success == 0 || success == false) {
      print("Error compiling shader: " + gl.getShaderInfoLog(shader));
      throw 'Failed to create the shader';
    }
    return shader;
  }

  static int createProgram(OpenGLContextES gl, int vertexShader, int fragmentShader) {
    int program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success != 0 || success != false) {
      return program;
    }
    print('getProgramInfoLog: ${gl.getProgramInfoLog(program)}');
    gl.deleteProgram(program);
    throw 'failed to create the program';
  }

  static drawBufferInfo(OpenGLContextES gl, BufferInfo bufferInfo, [type, count, offset]) {
    // type = type == null ? gl.TRIANGLES : type;
    type ??= gl.TRIANGLES;
    var indices = bufferInfo.indices;
    var elementType = bufferInfo.elementType;
    // var numElements = count == null ? bufferInfo.numElements : count;
    int numElements;
    if (count == null) {
      numElements = bufferInfo.numElements;
    } else {
      numElements = count;
    }
    offset ??= 0;
    if (elementType != null || indices != null) {
      int primitiveType = type;
      int _count = numElements;
      int _type = elementType == null ? gl.UNSIGNED_SHORT : bufferInfo.elementType;
      int _offset = offset;
      // 4, 3, 5123, 0
      gl.drawElements(primitiveType, _count, _type, _offset);
    } else {
      gl.drawArrays(type, offset, numElements);
    }
  }

  static setUniforms(ProgramInfo programInfo, Map<String, dynamic> uniforms) {
    var uniformSetters = programInfo.uniformSetters;
    uniforms.forEach((key, value) {
      var setter = uniformSetters[key];
      if (setter != null) {
        setter(uniforms[key]); // you can use value also
      }
    });
  }

  static createUniformSetters(OpenGLContextES gl, int program) {
    var textureUnit = 0;

    createUniformSetter(int program, ActiveInfo uniformInfo) {
      int location = gl.getUniformLocation(program, uniformInfo.name);
      bool isArray = uniformInfo.size > 1 &&
          uniformInfo.name.substring(uniformInfo.name.length - 3, uniformInfo.name.length) == "[0]";
      int type = uniformInfo.type;
      var typeInfo = flutter3DUtils.typeMap[type];
      if (typeInfo == null) {
        throw "unknown type: 0x" + type.toString(); // we should never get here.
      }
      if (typeInfo['bindPoint'] != null) {
        // it's a sampler
        var unit = textureUnit;
        textureUnit += uniformInfo.size;

        if (isArray) {
          return typeInfo['arraySetter'](gl, type, unit, location, uniformInfo.size);
        } else {
          return typeInfo['setter'](gl, type, unit, location, uniformInfo.size);
        }
      } else {
        if (typeInfo['arraySetter'] != null && isArray) {
          return typeInfo['arraySetter'](gl, location);
        } else {
          return typeInfo['setter'](gl, location);
        }
      }
    }

    Map<String, dynamic> uniformSetters = {};
    int numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);

    for (var ii = 0; ii < numUniforms; ++ii) {
      ActiveInfo uniformInfo = gl.getActiveUniform(program, ii); // or use ActiveInfo
      if (uniformInfo == null) {
        break;
      }
      var name = uniformInfo.name;
      // remove the array suffix.
      if (name.substring(name.length - 3, name.length) == "[0]") {
        name = name.substring(0, name.length - 3);
      }
      var setter = createUniformSetter(program, uniformInfo);
      uniformSetters[name] = setter;
    }
    return uniformSetters;
  }

  static Map<String, dynamic> createAttributeSetters(OpenGLContextES gl, int program) {
    Map<String, dynamic> attribSetters = {};

    var numAttribs = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    for (var ii = 0; ii < numAttribs; ++ii) {
      ActiveInfo attribInfo = gl.getActiveAttrib(program, ii); // ActiveInfo fix this in flgl package.
      if (attribInfo == null) {
        break;
      }
      var index = gl.getAttribLocation(program, attribInfo.name);
      var typeInfo = flutter3DUtils.attrTypeMap[attribInfo.type];
      attribSetters[attribInfo.name] = typeInfo['setter'](gl, index, typeInfo);
    }

    return attribSetters;
  }

  /// Creates the program info.
  ///
  /// Creates the program info for the current model
  ///
  /// - [vertexShaderSource] The vertex Shader Source
  /// - [fragmentShaderSource] The fragment Shader Source
  static ProgramInfo createProgramInfo(OpenGLContextES gl, String vertexShaderSource, String fragmentShaderSource) {
    int vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    int fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    int program = createProgram(gl, vertexShader, fragmentShader);

    var uniformSetters = createUniformSetters(gl, program);
    var attribSetters = createAttributeSetters(gl, program);

    ProgramInfo programInfo = ProgramInfo(program, uniformSetters, attribSetters);
    return programInfo;
  }

  /// Creates VAO, sets the program attributes, and binds the
  /// indices.
  /// - gl
  /// - setters: the programInfo.attribSetters
  /// - attribs: the bufferInfo.attribs
  /// - indices: the bufferInfo.indices
  static createVAOAndSetAttributes(OpenGLContextES gl, setters, attribs, indices) {
    int vao = gl.createVertexArray();
    gl.bindVertexArray(vao);

    Programs.setAttributes(setters, attribs);

    if (indices != null) {
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indices); // fix the type of bindBuffer(int, int);
    }

    // We unbind this because otherwise any change to ELEMENT_ARRAY_BUFFER
    // like when creating buffers for other stuff will mess up this VAO's binding
    // gl.bindVertexArray(null); // maybe I get an issue here.
    // https://gamedev.stackexchange.com/questions/107793/binding-and-unbinding-what-would-you-do
    // gl.bindVertexArray(null); // error fails, I can't pass null value.

    /// https://community.khronos.org/t/do-i-need-to-bind-and-unbind-my-vertex-buffer-every-draw-call/104150
    gl.bindVertexArray(0); // and this line fixed alot of problems.

    return vao;
  }

  static createVAOFromBufferInfo(OpenGLContextES gl, ProgramInfo programInfo, BufferInfo bufferInfo) {
    return createVAOAndSetAttributes(gl, programInfo.attribSetters, bufferInfo.attribs, bufferInfo.indices);
  }
}

class UniformInfo {
  String name;
  int size;
  int type;
  UniformInfo(this.name, this.size, this.type);
}

class ProgramInfo {
  int program;
  Map<String, dynamic> uniformSetters;
  Map<String, dynamic> attribSetters;

  ProgramInfo(this.program, this.uniformSetters, this.attribSetters);
}
