import 'dart:async';
import 'package:flutter/services.dart';
import 'openGL/contexts/open_gl_context_es.dart';
import 'openGL/open_gl_es.dart';

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
  dynamic sourceTexture;

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
  /// Super importand,
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
  dispose() async {
    isDisposed = true;

    final args = {"textureId": textureId};
    await _channel.invokeMethod('dispose', args);
  }
}
