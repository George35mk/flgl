import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;

class TextureManager {
  TextureManager();

  /// Helper function that helps to load textures
  /// from assets.
  ///
  /// - [url] `assets/images/a.png`
  static Future<TextureInfo> loadTexture(String url) async {
    ByteData bytes = await rootBundle.load(url);
    // Uint8List imageData = Uint8List.view(bytes.buffer);

    var decodedImage = await decodeImageFromList(bytes.buffer.asUint8List());
    int imgWidth = decodedImage.width;
    int imgHeight = decodedImage.height;
    var finalImageData = await decodedImage.toByteData(format: ImageByteFormat.rawRgba);

    return TextureInfo(
      imgWidth,
      imgHeight,
      Uint8List.view(finalImageData!.buffer),
    );
  }
}

class TextureInfo {
  int width;
  int height;
  Uint8List imageData;
  TextureInfo(this.width, this.height, this.imageData);
}


//. this also works but I need the image package
// import 'package:image/image.dart' as image;
// final Uint8List inputImg = (await rootBundle.load("assets/images/a.png")).buffer.asUint8List();
// final decoder = image.JpegDecoder();
// final decodedImg = decoder.decodeImage(inputImg);
// final decodedBytes = decodedImg.getBytes(format: image.Format.rgba);