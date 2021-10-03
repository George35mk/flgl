import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class BFX {
  /// Creates a program, attaches shaders, binds attrib locations, links the
  /// program and calls useProgram.
  ///
  /// - @param {WebGLShader[]} shaders The shaders to attach
  /// - @param {string[]} [opt_attribs] An array of attribs names. Locations will be assigned by index if not passed in
  /// - @param {number[]} [opt_locations] The locations for the. A parallel array to opt_attribs letting you assign locations.
  /// - @param {module:webgl-utils.ErrorCallback} opt_errorCallback callback for errors. By default it just prints an error to the console
  ///        on error. If you want something else pass an callback. It's passed an error message.
  static int createProgram(
    OpenGLContextES gl,
    List<int> shaders, [
    attribs,
    locations,
  ]) {
    // Create a program.
    int program = gl.createProgram();

    // for each shader attach the shader.
    for (var shader in shaders) {
      gl.attachShader(program, shader);
    }

    // maybe an issue here. /= null maybe is better solution.
    if (attribs != null) {
      attribs.forEachIndexed((index, element) {
        print('index: $index, element: $element');
        gl.bindAttribLocation(program, locations ? locations[index] : index, element);
      });
    }

    gl.linkProgram(program);

    // Check the link status
    var linked = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (linked == 0) {
      // something went wrong with the link
      var lastError = gl.getProgramInfoLog(program);
      gl.deleteProgram(program);
      throw ('Error in program linking: $lastError');
    }

    return program;
  }

  /// Returns the corresponding bind point for a given sampler type
  static getBindPointForSamplerType(gl, type) {
    if (type == gl.SAMPLER_2D) return gl.TEXTURE_2D;
    if (type == gl.SAMPLER_CUBE) return gl.TEXTURE_CUBE_MAP;
    return null;
  }

  /// Creates setter functions for all uniforms of a shader
  /// program.
  ///
  /// - @see {@link module:webgl-utils.setUniforms}
  ///
  /// - @param {WebGLProgram} program the program to create setters for.
  /// - @returns {Object.<string, function>} an object with a setter by name for each uniform
  static createUniformSetters(OpenGLContextES gl, int program) {
    var textureUnit = 0;

    /// Creates a setter for a uniform of the given program with it's
    /// location embedded in the setter.
    /// - @param {WebGLProgram} program
    /// - @param {WebGLUniformInfo} uniformInfo
    /// - @returns {function} the created setter.
    createUniformSetter(int program, uniformInfo) {
      var location = gl.getUniformLocation(program, uniformInfo.name);
      var type = uniformInfo.type;
      String ufName = uniformInfo.name;

      // Check if this uniform is an array
      var isArray = (uniformInfo.size > 1 && ufName.substring(ufName.length - 3, ufName.length) == '[0]');

      if (type == gl.FLOAT && isArray) {
        return (v) => gl.uniform1fv(location, v);
      }

      if (type == gl.FLOAT) {
        return (v) => gl.uniform1f(location, v);
      }

      if (type == gl.FLOAT_VEC2) {
        return (v) => gl.uniform2fv(location, v);
      }

      if (type == gl.FLOAT_VEC3) {
        return (v) => gl.uniform3fv(location, v);
      }

      if (type == gl.FLOAT_VEC4) {
        return (v) => gl.uniform4fv(location, v);
      }

      if (type == gl.INT && isArray) {
        return (v) => gl.uniform1iv(location, v);
      }

      if (type == gl.INT) {
        return (v) => gl.uniform1i(location, v);
      }

      if (type == gl.INT_VEC2) {
        return (v) => gl.uniform2iv(location, v);
      }

      if (type == gl.INT_VEC3) {
        return (v) => gl.uniform3iv(location, v);
      }

      if (type == gl.INT_VEC4) {
        return (v) => gl.uniform4iv(location, v);
      }

      if (type == gl.BOOL) {
        return (v) => gl.uniform1iv(location, v);
      }

      if (type == gl.BOOL_VEC2) {
        return (v) => gl.uniform2iv(location, v);
      }

      if (type == gl.BOOL_VEC3) {
        return (v) => gl.uniform3iv(location, v);
      }

      if (type == gl.BOOL_VEC4) {
        return (v) => gl.uniform4iv(location, v);
      }

      if (type == gl.FLOAT_MAT2) {
        return (v) => gl.uniformMatrix2fv(location, false, v);
      }

      if (type == gl.FLOAT_MAT3) {
        return (v) => gl.uniformMatrix3fv(location, false, v);
      }

      if (type == gl.FLOAT_MAT4) {
        return (v) => gl.uniformMatrix4fv(location, false, v);
      }

      // if ((type == gl.SAMPLER_2D || type == gl.SAMPLER_CUBE) && isArray) {
      //   const units = [];
      //   for (var ii = 0; ii < info.size; ++ii) {
      //     units.push(textureUnit++);
      //   }
      //   return function(bindPoint, units) {
      //     return function(textures) {
      //       gl.uniform1iv(location, units);
      //       textures.forEach(function(texture, index) {
      //         gl.activeTexture(gl.TEXTURE0 + units[index]);
      //         gl.bindTexture(bindPoint, texture);
      //       });
      //     };
      //   }(getBindPointForSamplerType(gl, type), units);
      // }

      // if (type == gl.SAMPLER_2D || type == gl.SAMPLER_CUBE) {
      //   return function(bindPoint, unit) {
      //     return function(texture) {
      //       gl.uniform1i(location, unit);
      //       gl.activeTexture(gl.TEXTURE0 + unit);
      //       gl.bindTexture(bindPoint, texture);
      //     };
      //   }(getBindPointForSamplerType(gl, type), textureUnit++);
      // }

      throw ('unknown type: 0x' + type.toString(16)); // we should never get here.
    }

    /// a map of uniform setters.
    var uniformSetters = {};

    /// get how many uniforms are in the program shaders.
    var numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);

    /// for exach uniform in the program get the active uniform object
    /// get the name of the active uniform
    /// and create a uniform setter.
    /// last add this uniform setter in the uniform setters map.
    for (var ii = 0; ii < numUniforms; ++ii) {
      var uniformInfo = gl.getActiveUniform(program, ii);
      if (uniformInfo == null) {
        break;
      }
      String name = uniformInfo.name;
      // remove the array suffix.
      if (name.substring(name.length - 3, name.length) == '[0]') {
        name = name.substring(0, name.length - 3);
      }
      var setter = createUniformSetter(program, uniformInfo);
      uniformSetters[name] = setter;
    }
    return uniformSetters;
  }

  static setAttributes(Map<String, dynamic> setters, Map<String, dynamic> attribs) {
    // setters = Map<String, dynamic>.from(setters['attribSetters']) ?? setters;
    setters = Map<String, dynamic>.from(setters['attribSetters']);
    attribs.forEach((key, value) {
      var setter = setters[key];
      if (setter != null) {
        setter(attribs[key]);
      }
    });
  }

  ///
  /// - gl
  /// - setters the programInfo
  /// - buffers the 3d object buffers
  static setBuffersAndAttributes(OpenGLContextES gl, Map<String, dynamic> setters, Map<String, dynamic> buffers) {
    Map<String, dynamic> attribs = Map<String, dynamic>.from(buffers['attribs']);
    setAttributes(setters, attribs);
    if (buffers.containsKey('indices') && buffers['indices']) {
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers['indices']);
    }
  }

  /// Creates setter functions for all attributes of a shader
  /// program. You can pass this to {@link module:webgl-utils.setBuffersAndAttributes} to set all your buffers and attributes.
  ///
  /// - @see {@link module:webgl-utils.setAttributes} for example
  /// - @param {WebGLProgram} program the program to create setters for.
  /// - @return {Object.<string, function>} an object with a setter for each attribute by name.
  static createAttributeSetters(OpenGLContextES gl, program) {
    var attribSetters = {};

    func2(b, [index]) {
      if (b.containsKey('value')) {
        gl.disableVertexAttribArray(index);

        switch (b['value'].length) {
          case 4:
            gl.vertexAttrib4fv(index, b['value']);
            break;
          case 3:
            gl.vertexAttrib3fv(index, b['value']);
            break;
          case 2:
            gl.vertexAttrib2fv(index, b['value']);
            break;
          case 1:
            gl.vertexAttrib1fv(index, b['value']);
            break;
          default:
            throw ('the length of a float constant value must be between 1 and 4!');
        }
      } else {
        gl.bindBuffer(gl.ARRAY_BUFFER, b['buffer']);
        gl.enableVertexAttribArray(index);
        gl.vertexAttribPointer(
          index,
          b['numComponents'] ?? b['size'],
          b['type'] ?? gl.FLOAT,
          b['normalize'] ?? false,
          b['stride'] ?? 0,
          b['offset'] ?? 0,
        );
      }
    }

    createAttribSetter(int index) {
      return (dynamic b) => func2(b, index);
    }

    /// count the active attributes in program shaders.
    var numAttribs = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);

    /// For each active attribute in program shaders.
    for (var ii = 0; ii < numAttribs; ++ii) {
      var attribInfo = gl.getActiveAttrib(program, ii);
      if (attribInfo == null) {
        break;
      }
      var index = gl.getAttribLocation(program, attribInfo.name);
      attribSetters[attribInfo.name] = createAttribSetter(index);
    }

    return attribSetters;
  }

  static const defaultShaderType = [
    'VERTEX_SHADER',
    'FRAGMENT_SHADER',
  ];

  /// Loads a shader.
  /// - @param {WebGLRenderingContext} gl The WebGLRenderingContext to use.
  /// - @param {string} shaderSource The shader source.
  /// - @param {number} shaderType The type of shader.
  /// - @param {module:webgl-utils.ErrorCallback} opt_errorCallback callback for errors.
  /// - @return {WebGLShader} The created shader.
  static int loadShader(OpenGLContextES gl, String shaderSource, int shaderType, [opt_errorCallback]) {
    // const errFn = opt_errorCallback | error;
    // Create the shader object
    var shader = gl.createShader(shaderType);

    // Load the shader source
    gl.shaderSource(shader, shaderSource);

    // Compile the shader
    gl.compileShader(shader);

    // Check the compile status
    var compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (compiled == 0 || compiled == false) {
      // Something went wrong during compilation; get the error
      var lastError = gl.getShaderInfoLog(shader);
      // errFn('*** Error compiling shader \' $shader' + '\':' + lastError + '\n' + shaderSource.split('\n').map((l,i) => '${i + 1}: ${l}').join('\n'));
      print('*** Error compiling the shader, shader: $shader, lastError: $lastError');
      gl.deleteShader(shader);
      throw 'Failed to create the shader';
    }

    return shader;
  }

  /// Creates a program from 2 sources.
  ///
  /// - @param {WebGLRenderingContext} gl The WebGLRenderingContext
  ///        to use.
  /// - @param {string[]} shaderSourcess Array of sources for the
  ///        shaders. The first is assumed to be the vertex shader,
  ///        the second the fragment shader.
  /// - @param {string[]} [opt_attribs] An array of attribs names. Locations will be assigned by index if not passed in
  /// - @param {number[]} [opt_locations] The locations for the. A parallel array to opt_attribs letting you assign locations.
  /// - @param {module:webgl-utils.ErrorCallback} opt_errorCallback callback for errors. By default it just prints an error to the console
  ///        on error. If you want something else pass an callback. It's passed an error message.
  /// - @return {WebGLProgram} The created program.
  /// - @memberOf module:webgl-utils
  static createProgramFromSources(
    OpenGLContextES gl,
    List<String> shaderSources, [
    attribs,
    locations,
  ]) {
    List<int> shaders = []; // a list of shader id's.
    for (var ii = 0; ii < shaderSources.length; ++ii) {
      int shaderType = defaultShaderType[ii] == 'VERTEX_SHADER' ? gl.VERTEX_SHADER : gl.FRAGMENT_SHADER;
      var shader = loadShader(gl, shaderSources[ii], shaderType);
      shaders.add(shader);
    }
    return createProgram(gl, shaders, attribs, locations);
  }

  static createProgramInfo(
    OpenGLContextES gl,
    List<String> shaderSources, [
    attribs,
    locations,
  ]) {
    var program = createProgramFromSources(gl, shaderSources, attribs, locations);
    if (program == 0) {
      throw 'Failed the to create program from sources';
    }

    var uniformSetters = createUniformSetters(gl, program);
    var attribSetters = createAttributeSetters(gl, program);

    return {
      'program': program,
      'uniformSetters': uniformSetters,
      'attribSetters': attribSetters,
    };
  }

  static setUniforms(setters, Map<String, dynamic> values) {
    setters = setters['uniformSetters'] ?? setters;
    values.forEach((key, value) {
      var setter = setters[key];
      if (setter != null) {
        setter(values[key]); // value
      }
    });
  }
}
