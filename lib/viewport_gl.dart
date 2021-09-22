import 'package:flgl/flgl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ViewportGL extends StatefulWidget {
  final int width;
  final int height;

  final Function? onChange;
  const ViewportGL({
    Key? key,
    this.onChange,
    this.width = 500, // default
    this.height = 500, // default
  }) : super(key: key);

  @override
  _ViewportGLState createState() => _ViewportGLState();
}

class _ViewportGLState extends State<ViewportGL> {
  num dpr = 1.0;

  dynamic defaultFramebuffer;
  dynamic defaultFramebufferTexture;

  Size? screenSize;

  late Flgl flgl;
  // late Engine engine;

  @override
  Widget build(BuildContext context) {
    initSize(context);
    return Container(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      color: Colors.pink,
      child: Builder(
        builder: (BuildContext context) {
          return flgl.isInitialized
              ? Texture(textureId: flgl.textureId!)
              : Container(
                  child: Text('Nop!!'),
                );
        },
      ),
    );
  }

  setupDefaultFBO() {
    final _gl = flgl.gl;
    int glWidth = (widget.width * dpr).toInt();
    int glHeight = (widget.height * dpr).toInt();

    defaultFramebuffer = _gl.createFramebuffer();
    defaultFramebufferTexture = _gl.createTexture();
    _gl.activeTexture(_gl.TEXTURE0);

    _gl.bindTexture(_gl.TEXTURE_2D, defaultFramebufferTexture);
    _gl.texImage2D(
        _gl.TEXTURE_2D, 0, _gl.RGBA, glWidth, glHeight, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, null);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);

    _gl.bindFramebuffer(_gl.FRAMEBUFFER, defaultFramebuffer);
    _gl.framebufferTexture2D(
        _gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, defaultFramebufferTexture, 0);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    flgl = Flgl(widget.width.toInt(), widget.height.toInt(), dpr);

    Map<String, dynamic> _options = {"antialias": true, "alpha": false};

    await flgl.initialize(options: _options);
    await flgl.prepareContext();
    setupDefaultFBO();
    flgl.sourceTexture = defaultFramebufferTexture;

    setState(() {});

    // web need wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        widget.onChange!(flgl);
      });
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mq = MediaQuery.of(context);

    screenSize = mq.size;
    dpr = mq.devicePixelRatio;

    print(" screenSize: ${screenSize} dpr: ${dpr} ");

    initPlatformState();
  }
}
