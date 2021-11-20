import 'dart:typed_data';

import 'package:flgl/flutter3d/managers/texture_manager.dart';
import 'package:flgl/openGL/bindings/gles_bindings.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

class Texture {
  OpenGLContextES gl;
  int m_RendererID = 0;
  Uint8List? m_LocalBuffer;
  String filePath;
  int width = 0;
  int height = 0;
  int bpp = 0; // bits per pixel.

  Texture(this.gl, this.filePath) {
    loadTexture();
  }

  loadTexture() async {
    TextureInfo textureInfo = await TextureManager.loadTexture('assets/images/a.png');

    print('width: ${textureInfo.width}');
    print('height: ${textureInfo.height}');
    print('imageData: ${textureInfo.imageData}');

    width = textureInfo.width;
    height = textureInfo.height;
    m_LocalBuffer = textureInfo.imageData;

    m_RendererID = gl.createTexture();

    gl.bindTexture(gl.TEXTURE_2D, m_RendererID);
    gl.texParameteri(gl.TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, m_LocalBuffer);
    gl.bindTexture(gl.TEXTURE_2D, 0); // unbind the texture.

    // some times you need the
    if (m_LocalBuffer != null) {
      // stbi_image_free(m_LocalBuffer); // with stb lib.
      m_LocalBuffer!.clear();
    }
  }

  getWidth() {
    return width;
  }

  getHeight() {
    return height;
  }

  bind([int slot = 0]) {
    gl.activeTexture(GL_TEXTURE0 + slot);
    gl.bindTexture(GL_TEXTURE_2D, m_RendererID);
  }

  unBind() {
    gl.bindTexture(gl.TEXTURE_2D, 0); // unbind the texture.
  }

  // On destroy call it.
  dispose() {
    gl.deleteTexture(m_RendererID);
  }
}
