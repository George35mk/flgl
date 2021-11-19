import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'core/buffer_geometry.dart';
import 'core/programs.dart';
import 'flutter3d_utils.dart';

class Flutter3D {
  static Flutter3DUtils flutter3DUtils = Flutter3DUtils();

  Flutter3D();

  // clears the error.
  static void glClearError(OpenGLContextES gl) {
    while (gl.getError() != GL_NO_ERROR) {}
  }

  // checks the error
  static void glLogCall(OpenGLContextES gl) {
    int error = gl.getError();
    if (error != 0) {
      throw 'GL Error: $error';
    }
    // while (error != 0) {
    //   throw 'GL Error: $error';
    // }
  }

  /// Creates a shader.
  ///
  /// Takes a [type] that can be a `gl.VERTEX_SHADER` or `gl.FRAGMENT_SHADER`
  ///
  /// and a [source] the shader source as a String.
  ///
  /// Finaly returns the shader id.
  static int createShader(OpenGLContextES gl, int type, String source) {
    int shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var result = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (result == GL_FALSE) {
      String shaderName = type == GL_VERTEX_SHADER ? 'vertex' : 'fragment';
      // gl.deleteShader(shader);
      throw 'Failed to compile $shaderName shader! the log is: ${gl.getShaderInfoLog(shader)}';
    }
    return shader;
  }

  /// Creates a shader program.
  ///
  /// First creates a program then attatch the vertex
  /// and fragment shaders, links the program finally returns the program id.
  ///
  /// Takes an OpenGl ES context, a [vs] vertex shader id, and a [fs] fragment shader id.
  ///
  /// Finally returns the program id.
  static int createProgram(OpenGLContextES gl, int vs, int fs) {
    int program = gl.createProgram();

    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    gl.validateProgram(program);

    gl.deleteShader(vs);
    gl.deleteShader(fs);

    var success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success != 0) {
      return program;
    }

    print('getProgramInfoLog: ${gl.getProgramInfoLog(program)}');
    gl.deleteProgram(program);
    throw 'failed to create the program';
  }

  /// Draws the buffer info.
  ///
  /// - [gl] the OpenGlES context.
  /// - [bufferInfo] the object buffer info.
  /// - [mode] the draw type. default value is `gl.TRIANGLES`.
  /// - [count] the count value. default value is `0`.
  /// - [offset] the offset value. default value is `0`.
  static drawBufferInfo(OpenGLContextES gl, BufferInfo bufferInfo, [mode, count, int offset = 0]) {
    mode ??= gl.TRIANGLES;
    count ??= bufferInfo.numElements;

    var indices = bufferInfo.indices;
    dynamic elementType = bufferInfo.elementType;

    // glClearError(gl);
    if (elementType != null || indices != null) {
      int type = elementType == null ? gl.UNSIGNED_SHORT : bufferInfo.elementType;
      // 4, 3, 5123, 0
      // Draw ellements if you have an index buffer.
      gl.drawElements(mode, count, type, offset);
    } else {
      // Draw arrays if you don't have an index buffer.
      gl.drawArrays(mode, offset, count);
    }
    // glLogCall(gl);
  }

  /// Sets the program uniforms.
  ///
  /// - [programInfo] the program info.
  /// - [uniforms] the uniforms to set.
  static setUniforms(ProgramInfo programInfo, Map<String, dynamic> uniforms) {
    var uniformSetters = programInfo.uniformSetters;
    uniforms.forEach((key, value) {
      var setter = uniformSetters[key];
      if (setter != null) {
        setter(uniforms[key]); // you can use value also
      }
    });
  }

  /// Creates uniform setters.
  ///
  /// - [gl] the OpenGlES context.
  /// - [program] the program id
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

  /// Creates attribute setters.
  ///
  /// - [gl] the OpenGlES context.
  /// - [program] the program id
  static Map<String, dynamic> createAttributeSetters(OpenGLContextES gl, int program) {
    Map<String, dynamic> attribSetters = {};

    int numAttribs = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
    for (var ii = 0; ii < numAttribs; ++ii) {
      ActiveInfo? attribInfo = gl.getActiveAttrib(program, ii);
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

    ProgramInfo programInfo = ProgramInfo(program, vertexShader, fragmentShader, uniformSetters, attribSetters);
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
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indices);
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

  /// Creates VAO from buffer info and set's the attributes.
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
  /// The program id.
  int program;

  /// The vertex shader id.
  int vertexShader;

  /// The fragment shader id.
  int fragmentShader;

  /// The uniform setters.
  Map<String, dynamic> uniformSetters;

  /// The attribute setters.
  Map<String, dynamic> attribSetters;

  ProgramInfo(this.program, this.vertexShader, this.fragmentShader, this.uniformSetters, this.attribSetters);
}
