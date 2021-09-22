import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'bindings/egl_bindings.dart';
import 'bindings/gles_bindings.dart';

import 'contexts/open_gl_context_es.dart';

class OpenGLES {
  int _display = 0;
  int _surface = 0;
  int _context = 0;

  Pointer<Uint32> frameBuffer = malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);
  Pointer<Uint32> frameBufferTexture = malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);
  Pointer<Uint32> renderBuffer = malloc.allocate<Uint32>(sizeOf<Uint32>() * 1);

  int get defaultFrameBuffer => frameBuffer.value;
  int get defaultTexture => frameBufferTexture.value;

  late LibOpenGLES _libOpenGLES;
  late LibEGL _libEGL;

  dynamic _gl;
  OpenGLContextES get gl {
    _gl ??= OpenGLContextES({"gl": _libOpenGLES});
    return _gl;
  }

  LibEGL get egl => _libEGL;

  OpenGLES(Map<String, dynamic> options) {
    final DynamicLibrary? libEGL = getEglLibrary();
    final DynamicLibrary? libGLESv3 = getGLLibrary();

    _libOpenGLES = LibOpenGLES(libGLESv3!);
    _libEGL = LibEGL(libEGL!);
  }

  /// EGL provides a native platform interface via the <EGL/egl.h> and <EGL/eglext.h> headers
  /// for allocating and managing OpenGL ES contexts and surfaces.
  /// EGL allows you to perform the following operations from native code:
  /// - List supported EGL configurations.
  /// - Allocate and release OpenGL ES surfaces.
  /// - Create and destroy OpenGL ES contexts.
  /// - Swap or flip surfaces.
  DynamicLibrary? getEglLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libEGL.so");
    } else {
      return DynamicLibrary.process();
    }
  }

  /// The standard OpenGL ES headers contain the declarations necessary for OpenGL ES.
  /// To use OpenGL ES 3.x, link your native module to libGLESv3.
  DynamicLibrary? getGLLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libGLESv3.so");
    } else {
      return DynamicLibrary.process();
    }
  }

  makeCurrent(List<int> egls) {
    _display = egls[3];
    _surface = egls[4];
    _context = egls[5];

    if (Platform.isAndroid) {
      /// bind context to this thread. All following OpenGL calls from this thread will use this context
      eglMakeCurrent(_display, _surface, _surface, _context);
    } else if (Platform.isIOS) {
      var _d = egl.eglTest();
      // print("makeCurrent egl test ${_d} ");
      var _result = egl.makeCurrent(_context);
      // print("ios makeCurrent _result: ${_result} ");
    }
  }

  eglMakeCurrent(int display, int draw, int read, int context) {
    var _v = egl.eglMakeCurrent(display, draw, read, context);

    final nativeCallResult = _v == 1;

    if (nativeCallResult) {
      return;
    }

    throw ('Failed to make current using display [$display], draw [$draw], read [$read], context [$context].');
  }

  dispose() {
    eglMakeCurrent(_display, 0, 0, 0);
    print(" OpenGLES dispose .... ");
  }
}
