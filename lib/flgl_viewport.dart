import 'package:flgl/flgl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FLGLViewport extends StatefulWidget {
  /// The viewport width.
  final int width;

  /// The viewport height.
  final int height;

  /// Use this method to get the gl context.
  final Function? onInit;

  const FLGLViewport({
    Key? key,
    required this.onInit,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _FLGLViewportState createState() => _FLGLViewportState();
}

class _FLGLViewportState extends State<FLGLViewport> {
  /// The device pixel ratio
  num dpr = 1.0;

  /// The screen size.
  Size? screenSize;

  late Flgl flgl;

  @override
  void dispose() {
    super.dispose();
    // flgl.dispose();
    // print('Dispose...');
  }

  @override
  Widget build(BuildContext context) {
    initSize(context);
    return Container(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      color: Colors.white,
      child: Builder(
        builder: (BuildContext context) {
          return flgl.isInitialized ? Texture(textureId: flgl.textureId!) : Container();
        },
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    flgl = Flgl(widget.width.toInt(), widget.height.toInt(), dpr);

    Map<String, dynamic> _options = {"antialias": true, "alpha": false};

    await flgl.initialize(options: _options);

    setState(() {
      widget.onInit!(flgl);
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mq = MediaQuery.of(context);

    screenSize = mq.size;
    dpr = mq.devicePixelRatio;

    initPlatformState();
  }
}
