import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import '../constants/open_gl_30_constant.dart';
import '../bindings/gles_bindings.dart';

class OpenGLContextES extends OpenGL30Constant {
  // ignore: todo
  /// TODO need free memory
  // List<Pointer<Uint32>> _uint32pointers = [];

  // late LibOpenGLES gl; // use this.
  late LibOpenGLES gl;
  // late dynamic gl;

  OpenGLContextES(Map<String, dynamic> parameters) {
    gl = parameters["gl"];
  }

  scissor(x, y, z, w) {
    return gl.glScissor(x, y, z, w);
  }

  void viewport(int x, int y, int width, int height) {
    return gl.glViewport(x, y, width, height);
  }

  ShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype) {
    // old code
    // return {'rangeMin': 1, 'rangeMax': 1, 'precision': 1};

    // new code
    Pointer<Int32> range = calloc<Int32>();
    Pointer<Int32> precision = calloc<Int32>();
    gl.glGetShaderPrecisionFormat(shadertype, precisiontype, range, precision);

    int _range = range.value;
    int _precision = precision.value;

    calloc.free(range);
    calloc.free(precision);

    return ShaderPrecisionFormat(_range, _precision);
  }

  getExtension(String key) {
    Pointer _v = gl.glGetString(EXTENSIONS);
    // print("OpenGLES getExtension key: ${key} _v: ${_v} ");

    String _vstr = _v.cast<Utf8>().toDartString();
    List<String> _extensions = _vstr.split(" ");

    // on iOS crash ...
    // calloc.free(_v);

    return _extensions;
  }

  getParameter(key) {
    List<int> _intValues = [
      MAX_TEXTURE_IMAGE_UNITS,
      MAX_VERTEX_TEXTURE_IMAGE_UNITS,
      MAX_TEXTURE_SIZE,
      MAX_CUBE_MAP_TEXTURE_SIZE,
      MAX_VERTEX_ATTRIBS,
      MAX_VERTEX_UNIFORM_VECTORS,
      MAX_VARYING_VECTORS,
      MAX_FRAGMENT_UNIFORM_VECTORS,
      MAX_SAMPLES,
      MAX_COMBINED_TEXTURE_IMAGE_UNITS,
      GL_SCISSOR_BOX,
      GL_VIEWPORT,
      CULL_FACE,
      DEPTH_TEST,
      VERSION,
      SHADING_LANGUAGE_VERSION,
      VENDOR,
      ACTIVE_TEXTURE
    ];

    if (_intValues.indexOf(key) >= 0) {
      final v = calloc<Int32>(4);
      gl.glGetIntegerv(key, v);
      return v.value;
    } else {
      throw ("OpenGL getParameter key: $key is not support");
    }
  }

  int createTexture() {
    final vPointer = calloc<Uint32>();
    gl.glGenTextures(1, vPointer);
    int _v = vPointer.value;
    calloc.free(vPointer);
    return _v;
  }

  void genTextures(v0, v1) {
    gl.glGenTextures(v0, v1);
  }

  void bindTexture(int target, int texture) {
    gl.glBindTexture(target, texture);
  }

  void bindTexture2(texture) {
    gl.glBindTexture(TEXTURE_2D, texture);
  }

  void bindSampler(int unit, int sampler) {
    gl.glBindSampler(unit, sampler);
  }

  void activeTexture(int texture) {
    gl.glActiveTexture(texture);
  }

  void texParameteri(int target, int pname, int param) {
    gl.glTexParameteri(target, pname, param);
  }

  texImage2D(
    int target,
    int level,
    int internalformat,
    int width,
    int height,
    int border,
    int format,
    int type,
    data,
  ) {
    Pointer<Int8> nativeBuffer;

    if (data != null) {
      nativeBuffer = calloc<Int8>(data.length);
      nativeBuffer.asTypedList(data.length).setAll(0, data);
      gl.glTexImage2D(
        target,
        level,
        internalformat,
        width,
        height,
        border,
        format,
        type,
        nativeBuffer.cast<Void>(),
      );
      calloc.free(nativeBuffer);
    } else {
      gl.glTexImage2D(target, level, internalformat, width, height, border, format, type, nullptr);
    }
  }

  // texImage2D_NOSIZE(target, level, internalformat, format, type, data) {
  //   return gl.texImage2D(target, level, internalformat, format, type, data);
  // }

  texImage3D(int target, int level, int internalformat, int width, int height, int depth, int border, int format,
      int type, data) {
    Pointer<Int8> nativeBuffer;
    if (data != null) {
      nativeBuffer = calloc<Int8>(data.length);
      nativeBuffer.asTypedList(data.length).setAll(0, data);
      gl.glTexImage3D(
          target, level, internalformat, width, height, depth, border, format, type, nativeBuffer.cast<Void>());
      calloc.free(nativeBuffer);
    } else {
      gl.glTexImage3D(target, level, internalformat, width, height, depth, border, format, type, nullptr);
    }
  }

  depthFunc(v0) {
    return gl.glDepthFunc(v0);
  }

  depthMask(bool v0) {
    return gl.glDepthMask(v0 ? 1 : 0);
  }

  /// ### enable or disable server-side GL capabilities
  /// #### Parameters
  ///
  /// - [cap] Specifies a symbolic constant indicating a GL capability.
  void enable(int cap) {
    return gl.glEnable(cap);
  }

  disable(v0) {
    return gl.glDisable(v0);
  }

  blendEquation(v0) {
    return gl.glBlendEquation(v0);
  }

  useProgram(int program) {
    return gl.glUseProgram(program);
  }

  void detachShader(int program, int shader) {
    gl.glDetachShader(program, shader);
  }

  blendFuncSeparate(v0, v1, v2, v3) {
    return gl.glBlendFuncSeparate(v0, v1, v2, v3);
  }

  blendFunc(v0, v1) {
    return gl.glBlendFunc(v0, v1);
  }

  blendEquationSeparate(var0, var1) {
    // print(" OpenGL blendEquationSeparate ...  ");
  }

  frontFace(v0) {
    return gl.glFrontFace(v0);
  }

  cullFace(v0) {
    return gl.glCullFace(v0);
  }

  lineWidth(num v0) {
    return gl.glLineWidth(v0.toDouble());
  }

  polygonOffset(v0, v1) {
    return gl.glPolygonOffset(v0, v1);
  }

  stencilMask(v0) {
    // print(" OpenGL stencilMask ...  ");
  }

  stencilFunc(v0, v1, v2) {
    // print(" OpenGL stencilFunc ...  ");
  }

  stencilOp(v0, v1, v2) {
    // print(" OpenGL stencilOp ...  ");
  }

  clearStencil(v0) {
    return gl.glClearStencil(v0);
  }

  clearDepth(num v0) {
    return gl.glClearDepthf(v0.toDouble());
  }

  colorMask(bool v0, bool v1, bool v2, bool v3) {
    return gl.glColorMask(v0 ? 1 : 0, v1 ? 1 : 0, v2 ? 1 : 0, v3 ? 1 : 0);
  }

  clearColor(num r, num g, num b, num a) {
    return gl.glClearColor(r.toDouble(), g.toDouble(), b.toDouble(), a.toDouble());
  }

  compressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data) {
    return gl.glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
  }

  generateMipmap(v0) {
    return gl.glGenerateMipmap(v0);
  }

  deleteTexture(int v0) {
    var _texturesList = [v0];
    final ptr = calloc<Int32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteTextures(1, ptr);
    calloc.free(ptr);
  }

  deleteFramebuffer(int v0) {
    var _list = [v0];
    final ptr = calloc<Int32>(_list.length);
    ptr.asTypedList(1).setAll(0, _list);
    gl.glDeleteFramebuffers(1, ptr);
    calloc.free(ptr);
  }

  deleteRenderbuffer(int v0) {
    var _list = [v0];
    final ptr = calloc<Int32>(_list.length);
    ptr.asTypedList(1).setAll(0, _list);
    gl.glDeleteRenderbuffers(1, ptr);
    calloc.free(ptr);
  }

  texParameterf(v0, v1, v2) {
    return gl.glTexParameterf(v0, v1, v2);
  }

  pixelStorei(v0, v1) {
    return gl.glPixelStorei(v0, v1);
  }

  // getContextAttributes() {
  //   return gl.getContextAttributes();
  // }

  int getProgramParameter(int program, int pname) {
    Pointer<Int32> status = calloc<Int32>();
    gl.glGetProgramiv(program, pname, status);
    int _v = status.value;
    calloc.free(status);
    return _v;
  }

  ActiveInfo getActiveUniform(int program, int index) {
    Pointer<Int32> length = calloc<Int32>();
    Pointer<Int32> size = calloc<Int32>();
    Pointer<Uint32> type = calloc<Uint32>();
    Pointer<Int8> name = calloc<Int8>(100);

    gl.glGetActiveUniform(program, index, 99, length, size, type, name);

    int _type = type.value;
    String _name = name.cast<Utf8>().toDartString();
    int _size = size.value;

    calloc.free(type);
    calloc.free(name);
    calloc.free(size);
    calloc.free(length);

    return ActiveInfo(_type, _name, _size);
  }

  getActiveAttrib(v0, v1) {
    var length = calloc<Int32>();
    var size = calloc<Int32>();
    var type = calloc<Uint32>();
    var name = calloc<Int8>(100);

    gl.glGetActiveAttrib(v0, v1, 99, length, size, type, name);

    int _type = type.value;
    String _name = name.cast<Utf8>().toDartString();
    int _size = size.value;

    calloc.free(type);
    calloc.free(name);
    calloc.free(size);
    calloc.free(length);

    return ActiveInfo(_type, _name, _size);
  }

  /// Returns the location of a uniform variable
  /// - [program] Specifies the program object to be queried.
  /// - [name] Points to a null terminated string containing the name of the uniform variable whose location is to be
  ///   queried.
  int getUniformLocation(int program, String name) {
    final locationName = name.toNativeUtf8();
    final location = gl.glGetUniformLocation(program, locationName.cast<Int8>());
    calloc.free(locationName);
    return location;
  }

  clear(int mask) {
    return gl.glClear(mask);
  }

  /// Generates buffer's
  Buffer genBuffers(int n) {
    Pointer<Uint32> bufferId = calloc<Uint32>();
    gl.glGenBuffers(n, bufferId);
    int _v = bufferId.value;
    calloc.free(bufferId);
    return Buffer._create(_v);
  }

  Buffer createBuffer() {
    Pointer<Uint32> bufferId = calloc<Uint32>();
    gl.glGenBuffers(1, bufferId);
    int _v = bufferId.value;
    calloc.free(bufferId);
    return Buffer._create(_v);
  }

  deleteBuffer(Buffer v0) {
    var _buffersList = [v0.bufferId];
    final ptr = calloc<Uint32>(_buffersList.length);
    ptr.asTypedList(1).setAll(0, _buffersList);
    gl.glDeleteBuffers(1, ptr);
    calloc.free(ptr);
  }

  bindBuffer(int target, Buffer buffer) {
    // added the correct type on the second param, replace dynamic with Buffer.
    return gl.glBindBuffer(target, buffer.bufferId);
  }

  // bufferData(int target, int size, data, int usage) {
  //   gl.glBufferData(target, size, data.cast<Void>(), usage);
  // }

  /// ### Creates and initializes a buffer object's data store
  ///
  /// #### Parameters
  /// - target
  ///
  ///   Specifies the target buffer object. The symbolic constant must be
  ///   - GL_ARRAY_BUFFER, GL_ATOMIC_COUNTER_BUFFER, GL_COPY_READ_BUFFER,
  ///   - GL_COPY_WRITE_BUFFER, GL_DRAW_INDIRECT_BUFFER,
  ///   - GL_DISPATCH_INDIRECT_BUFFER, GL_ELEMENT_ARRAY_BUFFER,
  ///   - GL_PIXEL_PACK_BUFFER, GL_PIXEL_UNPACK_BUFFER,
  ///   - GL_SHADER_STORAGE_BUFFER, GL_TRANSFORM_FEEDBACK_BUFFER, or
  ///   - GL_UNIFORM_BUFFER.
  ///
  /// - data
  ///
  ///   Specifies a pointer to data that will be copied into the data store for initialization,
  ///   or NULL if no data is to be copied.
  ///
  /// - usage
  ///
  ///   Specifies the expected usage pattern of the data store. The symbolic constant must be
  ///   GL_STREAM_DRAW, GL_STREAM_READ, GL_STREAM_COPY, GL_STATIC_DRAW, GL_STATIC_READ,
  ///   GL_STATIC_COPY, GL_DYNAMIC_DRAW, GL_DYNAMIC_READ, or GL_DYNAMIC_COPY.
  void bufferData(int target, dynamic data, int usage) {
    late Pointer<Void> nativeData;
    late int size;
    if (data is List<double> || data is Float32List) {
      nativeData = floatListToArrayPointer(data as List<double>).cast();
      size = data.length * sizeOf<Float>();
    } else if (data is Uint8List) {
      nativeData = uint8ListToArrayPointer(data).cast();
      size = data.length * sizeOf<Uint8>();
    } else if (data is Int32List) {
      nativeData = int32ListToArrayPointer(data).cast();
      size = data.length * sizeOf<Int32>();
    } else if (data is Uint16List) {
      nativeData = uInt16ListToArrayPointer(data).cast();
      size = data.length * sizeOf<Uint16>();
    } else if (data is Uint32List) {
      nativeData = uInt32ListToArrayPointer(data).cast();
      size = data.length * sizeOf<Uint32>();
    } else {
      throw ('bufferData: unsupported native type ${data.runtimeType}');
    }
    gl.glBufferData(target, size, nativeData, usage);
    calloc.free(nativeData);
  }

  bufferSubData(target, offset, data, srcOffset, length) {
    // int size = length * 4;
    int size = length;
    gl.glBufferSubData(target, offset, size, data.cast<Void>());
  }

  vertexAttribPointer(int index, int size, int type, bool normalized, int stride, int offset) {
    Pointer<Void> offsetPointer = Pointer<Void>.fromAddress(offset);
    gl.glVertexAttribPointer(index, size, type, normalized ? 1 : 0, stride, offsetPointer.cast<Void>());
  }

  void drawArrays(int mode, int first, int count) {
    gl.glDrawArrays(mode, first, count);
  }

  void bindFramebuffer(int target, int framebuffer) {
    // return gl.glBindFramebuffer(target, framebuffer ?? 0); // original code
    gl.glBindFramebuffer(target, framebuffer);
  }

  int checkFramebufferStatus(v0) {
    return gl.glCheckFramebufferStatus(v0);
  }

  // int target,
  // int attachment,
  // int textarget,
  // int texture,
  // int level,
  framebufferTexture2D(target, attachment, textarget, texture, level) {
    return gl.glFramebufferTexture2D(target, attachment, textarget, texture, level);
  }

  readPixels(int x, int y, int width, int height, int format, int type, Uint8List data) {
    final dataPtr = uint8ListToArrayPointer(data);
    gl.glReadPixels(x, y, width, height, format, type, dataPtr);
    Uint8List _data = dataPtr.asTypedList(data.length);
    data.setAll(0, _data);
    calloc.free(dataPtr);
  }

  copyTexImage2D(v0, v1, v2, v3, v4, v5, v6, v7) {
    // print(" OpenGL copyTexImage2D ...  ");
  }

  texSubImage2D(target, level, x, y, width, height, format, type, Uint8List data) {
    final dataPtr = uint8ListToArrayPointer(data);
    gl.glTexSubImage2D(target, level, x, y, width, height, format, type, dataPtr.cast<Void>());
    calloc.free(dataPtr);
  }

  texSubImage2D2(x, y, width, height, Uint8List data) {
    final dataPtr = uint8ListToArrayPointer(data);
    gl.glTexSubImage2D(TEXTURE_2D, 0, x, y, width, height, RGBA, UNSIGNED_BYTE, dataPtr);
    calloc.free(dataPtr);
  }

  compressedTexSubImage2D(v0, v1, v2, v3, v4, v5, v6, v7) {
    // print(" OpenGL compressedTexSubImage2D ...  ");
  }

  bindRenderbuffer(v0, v1) {
    return gl.glBindRenderbuffer(v0, v1 ?? 0);
  }

  renderbufferStorageMultisample(target, samples, internalformat, width, height) {
    return gl.glRenderbufferStorageMultisample(target, samples, internalformat, width, height);
  }

  renderbufferStorage(v0, v1, v2, v3) {
    return gl.glRenderbufferStorage(v0, v1, v2, v3);
  }

  framebufferRenderbuffer(v0, v1, v2, v3) {
    return gl.glFramebufferRenderbuffer(v0, v1, v2, v3);
  }

  createRenderbuffer() {
    final v = calloc<Uint32>();
    gl.glGenRenderbuffers(1, v);
    int _v = v.value;
    calloc.free(v);
    return _v;
  }

  genRenderbuffers(v0, v1) {
    return gl.glGenRenderbuffers(v0, v1);
  }

  int createFramebuffer() {
    final v = calloc<Uint32>();
    gl.glGenFramebuffers(1, v);
    int _v = v.value;
    calloc.free(v);
    return _v;
  }

  genFramebuffers(v0, v1) {
    return gl.glGenFramebuffers(v0, v1);
  }

  blitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter) {
    return gl.glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
  }

  int createVertexArray() {
    final v = calloc<Uint32>();
    gl.glGenVertexArrays(1, v);
    int _v = v.value;
    calloc.free(v);
    return _v;
  }

  /// ### Creates a program object
  ///
  /// #### Description
  /// glCreateProgram creates an empty program object and returns a non-zero
  /// value by which it can be referenced. A program object is an object to
  /// which shader objects can be attached. This provides a mechanism to
  /// specify the shader objects that will be linked to create a program.
  /// It also provides a means for checking the compatibility of the shaders
  /// that will be used to create a program (for instance, checking the
  /// compatibility between a vertex shader and a fragment shader).
  /// When no longer needed as part of a program object, shader objects can
  /// be detached.
  /// - Returns [int]
  int createProgram() {
    return gl.glCreateProgram();
  }

  /// Attaches a shader object to a program object
  /// - [program] Specifies the program object to which a shader object will be attached.
  /// - [shader] Specifies the shader object that is to be attached
  attachShader(int program, int shader) {
    return gl.glAttachShader(program, shader);
  }

  isProgram(int program) {
    return gl.glIsProgram(program);
  }

  bindAttribLocation(int program, int index, name) {
    return gl.glBindAttribLocation(program, index, name);
  }

  /// Links a program object
  /// - [program] Specifies the handle of the program object to be linked.
  void linkProgram(int program) {
    return gl.glLinkProgram(program);
  }

  void validateProgram(int program) {
    gl.glValidateProgram(program);
  }

  /// Returns the information log for a program object
  /// - [program] pecifies the program object whose information log is to be queried.
  getProgramInfoLog(int program) {
    var infoLen = calloc<Int32>();

    gl.glGetProgramiv(program, INFO_LOG_LENGTH, infoLen);

    int _len = infoLen.value;
    calloc.free(infoLen);

    String message = '';

    if (infoLen.value > 0) {
      final infoLog = calloc<Int8>(_len);
      gl.glGetProgramInfoLog(program, _len, nullptr, infoLog);

      message = "\nError compiling shader:\n${infoLog.cast<Utf8>().toDartString()}";
      calloc.free(infoLog);
      return message;
    } else {
      return;
    }
  }

  /// Returns the information log for a shader object
  /// - [shader] Specifies the shader object whose information log is to be queried.
  getShaderInfoLog(int shader) {
    final infoLen = calloc<Int32>();
    gl.glGetShaderiv(shader, INFO_LOG_LENGTH, infoLen);

    int _len = infoLen.value;
    calloc.free(infoLen);

    String message = '';
    if (infoLen.value > 1) {
      final infoLog = calloc<Int8>(_len);

      gl.glGetShaderInfoLog(shader, _len, nullptr, infoLog);
      message = "\nError compiling shader:\n${infoLog.cast<Utf8>().toDartString()}";

      calloc.free(infoLog);
      return message;
    }
  }

  int getError() {
    return gl.glGetError();
  }

  /// Deletes a shader object
  /// - [shader] Specifies the shader object to be deleted.
  void deleteShader(int shader) {
    gl.glDeleteShader(shader);
  }

  /// Deletes a program object
  /// - [program] Specifies the program object to be deleted.
  void deleteProgram(int program) {
    gl.glDeleteProgram(program);
  }

  // Accepts int value type,
  // but I need to pass a null value to unbind the VAO.
  void bindVertexArray(int array) {
    gl.glBindVertexArray(array);
  }

  /// Delete vertex array object
  deleteVertexArray(int v0) {
    var _list = [v0];
    final ptr = calloc<Uint32>(_list.length);
    ptr.asTypedList(1).setAll(0, _list);
    gl.glDeleteVertexArrays(1, ptr);
    calloc.free(ptr);
  }

  enableVertexAttribArray(v0) {
    return gl.glEnableVertexAttribArray(v0);
  }

  disableVertexAttribArray(v0) {
    return gl.glDisableVertexAttribArray(v0);
  }

  vertexAttribIPointer(v0, v1, v2, v3, v4) {
    return gl.glVertexAttribIPointer(v0, v1, v2, v3, v4);
  }

  vertexAttrib2fv(v0, v1) {
    return gl.glVertexAttrib2fv(v0, v1);
  }

  vertexAttrib3fv(v0, v1) {
    return gl.glVertexAttrib3fv(v0, v1);
  }

  vertexAttrib4fv(v0, v1) {
    return gl.glVertexAttrib4fv(v0, v1);
  }

  vertexAttrib1fv(v0, v1) {
    return gl.glVertexAttrib1fv(v0, v1);
  }

  drawElements(int mode, int count, int type, int offset) {
    var offSetPointer = Pointer<Void>.fromAddress(offset);
    gl.glDrawElements(mode, count, type, offSetPointer.cast<Void>());
    calloc.free(offSetPointer);
    return;
  }

  drawBuffers(buffers) {
    final ptr = calloc<Uint32>(buffers.length);
    ptr.asTypedList(buffers.length).setAll(0, List<int>.from(buffers));

    gl.glDrawBuffers(buffers.length, ptr);

    calloc.free(ptr);
    return;
  }

  drawElementsInstanced(mode, count, type, offset, instanceCount) {
    var offSetPointer = Pointer<Void>.fromAddress(offset);
    gl.glDrawElementsInstanced(mode, count, type, offSetPointer, instanceCount);
    calloc.free(offSetPointer);
    return;
  }

  /// Creates a shader object
  /// - [type] the shader type
  int createShader(int type) {
    return gl.glCreateShader(type);
  }

  /// Replaces the source code in a shader object
  /// - [shader] Specifies the handle of the shader object whose source code is to be replaced.
  /// - [shaderSource] Specifies an array of pointers to strings containing the source code to be loaded into the shader.
  void shaderSource(int shader, String shaderSource) {
    var sourceString = shaderSource.toNativeUtf8();
    var arrayPointer = calloc<Pointer<Int8>>();
    arrayPointer.value = Pointer.fromAddress(sourceString.address);
    gl.glShaderSource(shader, 1, arrayPointer, nullptr);
    calloc.free(arrayPointer);
    calloc.free(sourceString);
  }

  /// Compiles a shader object
  /// - Specifies the [shader] object to be compiled.
  compileShader(int shader) {
    return gl.glCompileShader(shader);
  }

  /// Returns a parameter from a shader object
  getShaderParameter(int shader, int pname) {
    var params = calloc<Int32>();
    gl.glGetShaderiv(shader, pname, params);

    final value = params.value;
    calloc.free(params);

    return value;
  }

  // getShaderSource(v0) {
  //   return gl.glGetShaderSource(v0);
  // }

  uniformMatrix4fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 16;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix4fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix2x3fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 6;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix2x3fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix3x2fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 6;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix3x2fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix2x4fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 8;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix2x4fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix4x2fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 8;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix4x2fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix3x4fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 12;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix3x4fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix4x3fv(int location, bool transpose, List<double> value) {
    var count = value.length ~/ 12;
    var arrayPointer = floatListToArrayPointer(value);
    gl.glUniformMatrix4x3fv(location, count, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniform1i(int location, v0) {
    return gl.glUniform1i(location, v0);
  }

  uniform3f(int location, num v1, num v2, num v3) {
    return gl.glUniform3f(location, v1.toDouble(), v2.toDouble(), v3.toDouble());
  }

  uniform1fv(int location, List<num> value) {
    List<double> _list = value.map((e) => e.toDouble()).toList();
    var arrayPointer = floatListToArrayPointer(_list);
    gl.glUniform1fv(location, value.length ~/ 1, arrayPointer);
    calloc.free(arrayPointer);
    return;
  }

  uniform3fv(location, List<num> value) {
    List<double> _list = value.map((e) => e.toDouble()).toList();
    var arrayPointer = floatListToArrayPointer(_list);
    gl.glUniform3fv(location, value.length ~/ 3, arrayPointer);
    calloc.free(arrayPointer);
    return;
  }

  uniform1f(int location, num v0) {
    return gl.glUniform1f(location, v0.toDouble());
  }

  uniformMatrix2fv(location, bool transpose, List<num> value) {
    List<double> _list = value.map((e) => e.toDouble()).toList();
    var arrayPointer = floatListToArrayPointer(_list);
    gl.glUniformMatrix2fv(location, value.length ~/ 6, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  uniformMatrix3fv(location, bool transpose, List<num> value) {
    List<double> _list = value.map((e) => e.toDouble()).toList();
    var arrayPointer = floatListToArrayPointer(_list);
    gl.glUniformMatrix3fv(location, value.length ~/ 9, transpose ? 1 : 0, arrayPointer);
    calloc.free(arrayPointer);
  }

  /// Returns the location of an attribute variable.
  /// - [program] Specifies the program object to be queried.
  /// - [name] Points to a null terminated string containing the name of the attribute variable whose location is to be
  ///   queried.
  int getAttribLocation(int program, String name) {
    final locationName = name.toNativeUtf8();
    final location = gl.glGetAttribLocation(program, locationName.cast<Int8>());
    calloc.free(locationName);
    return location;
  }

  void uniform2fv(int location, List<double> value) {
    int count = value.length;
    final valuePtr = calloc<Float>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform2fv(location, count ~/ 2, valuePtr);
    calloc.free(valuePtr); // free memory
  }

  uniform2f(v0, num v1, num v2) {
    return gl.glUniform2f(v0, v1.toDouble(), v2.toDouble());
  }

  uniform1iv(location, value) {
    int count = value.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform1iv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform2iv(int location, value) {
    int count = value.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform2iv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform3iv(int location, value) {
    int count = value.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform3iv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform4iv(int location, value) {
    int count = value.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform4iv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform1ui(int location, int value) {
    gl.glUniform1ui(location, value);
  }

  uniform1uiv(int location, Uint32List value) {
    int count = value.length;
    final valuePtr = calloc<Uint32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform1uiv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform2uiv(int location, Uint32List value) {
    int count = value.length;
    final valuePtr = calloc<Uint32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform2uiv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform3uiv(int location, Uint32List value) {
    int count = value.length;
    final valuePtr = calloc<Uint32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform3uiv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform4uiv(int location, Uint32List value) {
    int count = value.length;
    final valuePtr = calloc<Uint32>(count);
    valuePtr.asTypedList(count).setAll(0, value);
    gl.glUniform4uiv(location, count, valuePtr);
    calloc.free(valuePtr);
  }

  uniform4fv(location, List<num> value) {
    int count = value.length;
    final valuePtr = calloc<Float>(count);
    List<double> _values = value.map((e) => e.toDouble()).toList().cast();
    valuePtr.asTypedList(count).setAll(0, _values);
    gl.glUniform4fv(location, count ~/ 4, valuePtr.cast<Void>());
    calloc.free(valuePtr);
  }

  uniform4f(location, num v0, num v1, num v2, num v3) {
    return gl.glUniform4f(location, v0.toDouble(), v1.toDouble(), v2.toDouble(), v3.toDouble());
  }

  vertexAttribDivisor(index, divisor) {
    return gl.glVertexAttribDivisor(index, divisor);
  }

  flush() {
    return gl.glFlush();
  }

  finish() {
    return gl.glFinish();
  }

  // GLint x,
  // GLint y,
  // GLsizei width,
  // GLsizei height,
  // GLenum format,
  // GLenum type,
  // void * data
  Uint8List readCurrentPixels(int x, int y, int width, int height) {
    int _len = width * height * 4;
    Pointer<Uint8> ptr = malloc.allocate<Uint8>(sizeOf<Uint8>() * _len);
    gl.glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, ptr);

    final res = ptr.asTypedList(_len);

    calloc.free(ptr);

    return res;
  }

  getIntegerv(int v0) {
    Pointer<Int32> ptr = calloc<Int32>();
    gl.glGetIntegerv(v0, ptr);

    int _v = ptr.value;
    calloc.free(ptr);

    return _v;
  }
}

class Buffer {
  final int bufferId;
  Buffer._create(this.bufferId);
}

class ActiveInfo {
  String name;
  int size;
  int type;
  ActiveInfo(this.type, this.name, this.size);
}

Pointer<Float> floatListToArrayPointer(List<double> list) {
  final ptr = calloc<Float>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Int32> int32ListToArrayPointer(List<int> list) {
  final ptr = calloc<Int32>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Uint16> uInt16ListToArrayPointer(List<int> list) {
  final ptr = calloc<Uint16>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Uint32> uInt32ListToArrayPointer(List<int> list) {
  final ptr = calloc<Uint32>(list.length);
  ptr.asTypedList(list.length).setAll(0, list);
  return ptr;
}

Pointer<Uint8> uint8ListToArrayPointer(Uint8List list) {
  final ptr = calloc<Uint8>(list.length);
  ptr.asTypedList(list.length).setAll(0, list.map((e) => e));
  return ptr;
}

class ShaderPrecisionFormat {
  dynamic range; // fix the types
  dynamic precision; // fix the types
  ShaderPrecisionFormat(this.range, this.precision);
}
