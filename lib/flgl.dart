import 'dart:async';
import 'package:flutter/services.dart';

import 'openGL/contexts/open_gl_context_es.dart';
import 'openGL/open_gl_es.dart';

class Flgl {
  int? textureId;
  bool isDisposed = false;
  late OpenGLES openGLES;
  late List<int> egls;
  late int width;
  late int height;
  late num dpr;
  dynamic sourceTexture;

  /// Returns true if the textureId is set
  bool get isInitialized => textureId != null;
  OpenGLContextES get gl => openGLES.gl;

  static const MethodChannel _channel = MethodChannel('flgl');

  Flgl(this.width, this.height, this.dpr);

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

  Future<List<int>> getEgl(int textureId) async {
    final Map<String, int> args = {"textureId": textureId};
    final res = await _channel.invokeMethod('getEgl', args);
    return List<int>.from(res);
  }

  Future<bool> updateTexture() async {
    // check for textureId and sourceTexture if defined before updating the texture.
    final args = {"textureId": textureId, "sourceTexture": sourceTexture};
    final res = await _channel.invokeMethod('updateTexture', args);
    return res;
  }

  prepareContext() async {
    egls = await getEgl(textureId!);
    openGLES.makeCurrent(egls);
  }

  updateSize(Map<String, dynamic> options) async {
    final args = {
      "textureId": textureId,
      "width": options["width"],
      "height": options["height"],
    };

    final res = await _channel.invokeMethod('updateSize', args);
    return res;
  }

  dispose() {
    isDisposed = true;

    final args = {"textureId": textureId};
    _channel.invokeMethod('dispose', args);
  }
}
