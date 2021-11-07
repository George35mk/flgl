import 'dart:async';
import 'package:flutter/services.dart';
import 'openGL/contexts/open_gl_context_es.dart';
import 'openGL/open_gl_es.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class Flgl {
  /// The texture id.
  int? textureId;

  /// The disposed state.
  bool isDisposed = false;

  /// egls list? I don't know for now. find what is that.
  late List<int> egls;

  /// The texture width.
  late int width;

  /// The texture height.
  late int height;

  /// The device Pixel Ratio
  late num dpr;

  /// The openGLES.
  late OpenGLES openGLES;

  /// The source texture.
  late int sourceTexture;
  late int defaultFramebuffer;
  late int defaultFramebufferTexture;
  late int dbo;

  /// Returns true if the textureId is not set.
  bool get isInitialized => textureId != null;

  /// The openGLES context.
  OpenGLContextES get gl => openGLES.gl;

  /// The method channel.
  static const MethodChannel _channel = MethodChannel('flgl');

  Flgl(this.width, this.height, this.dpr);

  /// Initialize the flgl pluggin.
  /// returns the texture id
  Future<Map<String, dynamic>> initialize({Map<String, dynamic>? options}) async {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "dpr": dpr,
    };

    _options.addAll(options ?? {});

    // invoke the method and get the texture id.
    final res = await _channel.invokeMethod('initialize', <String, dynamic>{
      'options': _options,
      'renderToVideo': false,
    });

    textureId = res["textureId"];

    openGLES = OpenGLES(_options);

    await prepareContext();

    sourceTexture = setupFBO(gl, width, height, dpr);
    dbo = setupDBO(gl, width.toDouble(), height.toDouble(), dpr.toDouble());

    return Map<String, dynamic>.from(res);
  }

  /// Retures the EGL.
  Future<List<int>> getEgl(int textureId) async {
    final Map<String, int> args = {"textureId": textureId};
    final res = await _channel.invokeMethod('getEgl', args);
    return List<int>.from(res);
  }

  /// Updates the texture.
  /// Call this method to update the texture.
  /// Super importand.
  Future<bool> updateTexture() async {
    // check for textureId and sourceTexture if defined before updating the texture.
    final args = {"textureId": textureId, "sourceTexture": sourceTexture};
    final res = await _channel.invokeMethod('updateTexture', args);
    return res;
  }

  /// Prepares the context.
  prepareContext() async {
    egls = await getEgl(textureId!);
    openGLES.makeCurrent(egls);
  }

  /// Use this on resize.
  updateSize(Map<String, dynamic> options) async {
    final args = {
      "textureId": textureId,
      "width": options["width"],
      "height": options["height"],
    };

    final res = await _channel.invokeMethod('updateSize', args);
    return res;
  }

  /// Use this on dispose.
  /// https://www.khronos.org/registry/EGL/sdk/docs/man/html/eglDestroySurface.xhtml
  ///
  /// Description
  /// If the EGL surface surface is not current to any thread, eglDestroySurface destroys it immediately. Otherwise, surface is destroyed when it becomes not current to any thread. Furthermore, resources associated with a pbuffer surface are not released until all color buffers of that pbuffer bound to a texture object have been released.
  ///
  /// Errors
  /// EGL_FALSE is returned if destruction of the surface fails, EGL_TRUE otherwise.
  ///
  /// EGL_BAD_DISPLAY is generated if display is not an EGL display connection.
  ///
  /// EGL_NOT_INITIALIZED is generated if display has not been initialized.
  ///
  /// EGL_BAD_SURFACE is generated if surface is not an EGL surface.
  dispose() async {
    isDisposed = true;

    final args = {"textureId": textureId};
    await _channel.invokeMethod('dispose', args);

    // dispose fbo
    print('disposeFBO');
    disposeFBO(gl, defaultFramebuffer, defaultFramebufferTexture);

    // dispose dbo
    print('disposeDBO');
    disposeDBO(gl, dbo);
  }

  /// Dispose the Frame Buffer Object (FBO)
  /// #### Alse read this stackoverflow post.
  /// https://stackoverflow.com/questions/56254797/opengl-es-2-0-gldeleteframebuffers-after-drawing-to-texture
  disposeFBO(OpenGLContextES _gl, int fbo, int fboTexture) {
    _gl.deleteTexture(fboTexture);
    _gl.deleteFramebuffer(fbo);
  }

  /// Dispose the Depth Buffer Object (DBO)
  disposeDBO(OpenGLContextES _gl, int dbo) {
    // _gl.deleteTexture(dboTexture);
    _gl.deleteRenderbuffer(dbo);
  }

  /// https://stackoverflow.com/questions/24122859/glenablegl-depth-test-not-working
  /// https://www.khronos.org/opengl/wiki/Framebuffer_Object_Extension_Examples
  int setupFBO(OpenGLContextES _gl, num width, num height, num dpr) {
    int glWidth = (width * dpr).toInt();
    int glHeight = (height * dpr).toInt();

    defaultFramebuffer = _gl.createFramebuffer();
    defaultFramebufferTexture = _gl.createTexture();
    _gl.activeTexture(_gl.TEXTURE0);

    _gl.bindTexture(_gl.TEXTURE_2D, defaultFramebufferTexture);
    _gl.texImage2D(_gl.TEXTURE_2D, 0, _gl.RGBA, glWidth, glHeight, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, null);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);

    _gl.bindFramebuffer(_gl.FRAMEBUFFER, defaultFramebuffer);
    _gl.framebufferTexture2D(_gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, defaultFramebufferTexture, 0);

    return defaultFramebufferTexture;
  }

  /// Setups the Depth Buffer Object (DBO)
  /// returns the DBO id.
  int setupDBO(OpenGLContextES _gl, double width, double height, double dpr) {
    int glWidth = (width * dpr).toInt();
    int glHeight = (height * dpr).toInt();

    // ===================== Setup the Depth Buffer Object Start =====================

    var frameBufferCheck = _gl.gl.glCheckFramebufferStatus(_gl.FRAMEBUFFER);
    if (frameBufferCheck != _gl.FRAMEBUFFER_COMPLETE) {
      print("Framebuffer (color) check failed: $frameBufferCheck");
    }

    Pointer<Uint32> depthBuffer = calloc();
    _gl.gl.glGenRenderbuffers(1, depthBuffer.cast());
    _gl.gl.glBindRenderbuffer(_gl.RENDERBUFFER, depthBuffer.value);
    _gl.gl.glRenderbufferStorage(_gl.RENDERBUFFER, _gl.DEPTH_COMPONENT16, glWidth, glHeight);
    _gl.gl.glFramebufferRenderbuffer(_gl.FRAMEBUFFER, _gl.DEPTH_ATTACHMENT, _gl.RENDERBUFFER, depthBuffer.value);

    int depthBufferValue = depthBuffer.value; // just in case you need this value
    calloc.free(depthBuffer); // free

    frameBufferCheck = _gl.gl.glCheckFramebufferStatus(_gl.FRAMEBUFFER);
    if (frameBufferCheck != _gl.FRAMEBUFFER_COMPLETE) {
      print("Framebuffer (depth) check failed: $frameBufferCheck");
    }

    // ===================== Setup the Depth Buffer End =====================

    return depthBufferValue;
  }
}
