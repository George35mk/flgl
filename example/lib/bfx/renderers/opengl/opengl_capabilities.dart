import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import 'opengl_extensions.dart';

class OpenGLCapabilities {
  /// The opengles context.
  OpenGLContextES gl;

  /// The OpenGLExtensions.
  OpenGLExtensions extensions;

  /// The renderer parameters.
  Map<String, dynamic> parameters;

  bool isWebGL2 = false;

  late dynamic maxAnisotropy;
  late String precision;
  late dynamic maxPrecision;
  late dynamic drawBuffers;
  late dynamic logarithmicDepthBuffer;
  late dynamic maxTextures;
  late dynamic maxVertexTextures;
  late dynamic maxTextureSize;
  late dynamic maxCubemapSize;
  late dynamic maxAttributes;
  late dynamic maxVertexUniforms;
  late dynamic maxVaryings;
  late dynamic maxFragmentUniforms;
  late dynamic vertexTextures;
  late dynamic floatFragmentTextures;
  late dynamic floatVertexTextures;
  late dynamic maxSamples;

  OpenGLCapabilities(this.gl, this.extensions, this.parameters) {
    precision = parameters['precision'] ?? 'highp';
    dynamic maxPrecision = getMaxPrecision(precision);

    if (maxPrecision != precision) {
      print('THREE.WebGLRenderer: $precision not supported, using $maxPrecision instead.');
      precision = maxPrecision;
    }

    drawBuffers = isWebGL2 || extensions.has('WEBGL_draw_buffers');

    logarithmicDepthBuffer = parameters['logarithmicDepthBuffer'] == true;

    maxTextures = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
    maxVertexTextures = gl.getParameter(gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
    maxTextureSize = gl.getParameter(gl.MAX_TEXTURE_SIZE);
    maxCubemapSize = gl.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);

    maxAttributes = gl.getParameter(gl.MAX_VERTEX_ATTRIBS);
    maxVertexUniforms = gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS);
    maxVaryings = gl.getParameter(gl.MAX_VARYING_VECTORS);
    maxFragmentUniforms = gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS);

    vertexTextures = maxVertexTextures > 0;
    floatFragmentTextures = isWebGL2 || extensions.has('OES_texture_float');
    floatVertexTextures = vertexTextures && floatFragmentTextures;

    maxSamples = isWebGL2 ? gl.getParameter(gl.MAX_SAMPLES) : 0;
  }

  getMaxAnisotropy() {
    if (maxAnisotropy != null) return maxAnisotropy;

    if (extensions.has('EXT_texture_filter_anisotropic') == true) {
      var extension = extensions.get('EXT_texture_filter_anisotropic');

      maxAnisotropy = gl.getParameter(extension.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
    } else {
      maxAnisotropy = 0;
    }

    return maxAnisotropy;
  }

  getMaxPrecision(precision) {
    if (precision == 'highp') {
      if (gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.HIGH_FLOAT).precision > 0 &&
          gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.HIGH_FLOAT).precision > 0) {
        return 'highp';
      }

      precision = 'mediump';
    }

    if (precision == 'mediump') {
      if (gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.MEDIUM_FLOAT).precision > 0 &&
          gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.MEDIUM_FLOAT).precision > 0) {
        return 'mediump';
      }
    }

    return 'lowp';
  }
}
