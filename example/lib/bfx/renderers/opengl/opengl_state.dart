import 'dart:typed_data';

import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/math/vector4.dart';

import '../../constants.dart';
import 'opengl_capabilities.dart';
import 'opengl_extensions.dart';

class OpenGLState {
  /// The opengles context.
  OpenGLContextES gl;
  OpenGLExtensions extensions;
  OpenGLCapabilities capabilities;

  bool isWebGL2 = false;

  late ColorBuffer colorBuffer;
  late DepthBuffer depthBuffer;
  late StencilBuffer stencilBuffer;

  late Map enabledCapabilities = {};
  late dynamic xrFramebuffer;
  late Map currentBoundFramebuffers = {};

  late dynamic currentProgram;

  late bool currentBlendingEnabled = false;
  late dynamic currentBlending;
  late dynamic currentBlendEquation;
  late dynamic currentBlendSrc;
  late dynamic currentBlendDst;
  late dynamic currentBlendEquationAlpha;
  late dynamic currentBlendSrcAlpha;
  late dynamic currentBlendDstAlpha;
  late dynamic currentPremultipledAlpha = false;

  late dynamic currentFlipSided;
  late dynamic currentCullFace;

  late dynamic currentLineWidth;

  late dynamic currentPolygonOffsetFactor;
  late dynamic currentPolygonOffsetUnits;

  late dynamic maxTextures;
  bool lineWidthAvailable = false;
  int version = 0;

  late dynamic glVersion;
  late dynamic currentTextureSlot;
  late Map currentBoundTextures = {};

  late dynamic scissorParam;
  late dynamic viewportParam;
  late dynamic currentScissor;
  late dynamic currentViewport;

  late Map emptyTextures;

  late Map equationToGL;
  late Map factorToGL;

  late Map buffers;

  OpenGLState(this.gl, this.extensions, this.capabilities) {
    isWebGL2 = capabilities.isWebGL2;

    colorBuffer = ColorBuffer(gl);
    depthBuffer = DepthBuffer(gl);
    stencilBuffer = StencilBuffer(gl);

    buffers['color'] = colorBuffer;
    buffers['depth'] = depthBuffer;
    buffers['stencil'] = stencilBuffer;

    maxTextures = gl.getParameter(gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS);
    glVersion = gl.getParameter(gl.VERSION);

    if (glVersion.indexOf('WebGL') != -1) {
      // version = parseFloat( /^WebGL (\d)/.exec( glVersion )[ 1 ] );
      // lineWidthAvailable = ( version >= 1.0 );

    } else if (glVersion.indexOf('OpenGL ES') != -1) {
      // version = parseFloat( /^OpenGL ES (\d)/.exec( glVersion )[ 1 ] );
      // lineWidthAvailable = ( version >= 2.0 );

    }

    scissorParam = gl.getParameter(gl.SCISSOR_BOX);
    viewportParam = gl.getParameter(gl.VIEWPORT);

    currentScissor = Vector4().fromArray(scissorParam);
    currentViewport = Vector4().fromArray(viewportParam);

    emptyTextures = {};
    emptyTextures[gl.TEXTURE_2D] = createTexture(gl.TEXTURE_2D, gl.TEXTURE_2D, 1);
    emptyTextures[gl.TEXTURE_CUBE_MAP] = createTexture(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_CUBE_MAP_POSITIVE_X, 6);

    // init
    colorBuffer.setClear(0, 0, 0, 1);
    depthBuffer.setClear(1);
    stencilBuffer.setClear(0);

    enable(gl.DEPTH_TEST);
    depthBuffer.setFunc(LessEqualDepth);

    setFlipSided(false);
    setCullFace(CullFaceBack);
    enable(gl.CULL_FACE);

    setBlending(NoBlending);

    equationToGL = {
      [AddEquation]: gl.FUNC_ADD,
      [SubtractEquation]: gl.FUNC_SUBTRACT,
      [ReverseSubtractEquation]: gl.FUNC_REVERSE_SUBTRACT
    };

    if (isWebGL2) {
      equationToGL[MinEquation] = gl.MIN;
      equationToGL[MaxEquation] = gl.MAX;
    } else {
      var extension = extensions.get('EXT_blend_minmax');

      if (extension != null) {
        equationToGL[MinEquation] = extension.MIN_EXT;
        equationToGL[MaxEquation] = extension.MAX_EXT;
      }
    }

    factorToGL = {
      [ZeroFactor]: gl.ZERO,
      [OneFactor]: gl.ONE,
      [SrcColorFactor]: gl.SRC_COLOR,
      [SrcAlphaFactor]: gl.SRC_ALPHA,
      [SrcAlphaSaturateFactor]: gl.SRC_ALPHA_SATURATE,
      [DstColorFactor]: gl.DST_COLOR,
      [DstAlphaFactor]: gl.DST_ALPHA,
      [OneMinusSrcColorFactor]: gl.ONE_MINUS_SRC_COLOR,
      [OneMinusSrcAlphaFactor]: gl.ONE_MINUS_SRC_ALPHA,
      [OneMinusDstColorFactor]: gl.ONE_MINUS_DST_COLOR,
      [OneMinusDstAlphaFactor]: gl.ONE_MINUS_DST_ALPHA
    };
  }

  createTexture(type, target, count) {
    Uint8List data = Uint8List(4); // 4 is required to match default unpack alignment of 4.
    final texture = gl.createTexture();

    gl.bindTexture(type, texture);
    gl.texParameteri(type, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(type, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    for (var i = 0; i < count; i++) {
      gl.texImage2D(target + i, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
    }

    return texture;
  }

  enable(id) {
    if (enabledCapabilities[id] != true) {
      gl.enable(id);
      enabledCapabilities[id] = true;
    }
  }

  disable(id) {
    if (enabledCapabilities[id] != false) {
      gl.disable(id);
      enabledCapabilities[id] = false;
    }
  }

  bindXRFramebuffer(framebuffer) {
    if (framebuffer != xrFramebuffer) {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);

      xrFramebuffer = framebuffer;
    }
  }

  bindFramebuffer(target, framebuffer) {
    if (framebuffer == null && xrFramebuffer != null)
      framebuffer = xrFramebuffer; // use active XR framebuffer if available

    if (currentBoundFramebuffers[target] != framebuffer) {
      gl.bindFramebuffer(target, framebuffer);

      currentBoundFramebuffers[target] = framebuffer;

      if (isWebGL2) {
        // gl.DRAW_FRAMEBUFFER is equivalent to gl.FRAMEBUFFER

        if (target == gl.DRAW_FRAMEBUFFER) {
          currentBoundFramebuffers[gl.FRAMEBUFFER] = framebuffer;
        }

        if (target == gl.FRAMEBUFFER) {
          currentBoundFramebuffers[gl.DRAW_FRAMEBUFFER] = framebuffer;
        }
      }

      return true;
    }

    return false;
  }

  useProgram(program) {
    if (currentProgram != program) {
      gl.useProgram(program);

      currentProgram = program;

      return true;
    }

    return false;
  }

  setBlending(blending,
      [blendEquation, blendSrc, blendDst, blendEquationAlpha, blendSrcAlpha, blendDstAlpha, premultipliedAlpha]) {
    if (blending == NoBlending) {
      if (currentBlendingEnabled == true) {
        disable(gl.BLEND);
        currentBlendingEnabled = false;
      }

      return;
    }

    if (currentBlendingEnabled == false) {
      enable(gl.BLEND);
      currentBlendingEnabled = true;
    }

    if (blending != CustomBlending) {
      if (blending != currentBlending || premultipliedAlpha != currentPremultipledAlpha) {
        if (currentBlendEquation != AddEquation || currentBlendEquationAlpha != AddEquation) {
          gl.blendEquation(gl.FUNC_ADD);

          currentBlendEquation = AddEquation;
          currentBlendEquationAlpha = AddEquation;
        }

        if (premultipliedAlpha) {
          switch (blending) {
            case NormalBlending:
              gl.blendFuncSeparate(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
              break;

            case AdditiveBlending:
              gl.blendFunc(gl.ONE, gl.ONE);
              break;

            case SubtractiveBlending:
              gl.blendFuncSeparate(gl.ZERO, gl.ZERO, gl.ONE_MINUS_SRC_COLOR, gl.ONE_MINUS_SRC_ALPHA);
              break;

            case MultiplyBlending:
              gl.blendFuncSeparate(gl.ZERO, gl.SRC_COLOR, gl.ZERO, gl.SRC_ALPHA);
              break;

            default:
              print('THREE.WebGLState: Invalid blending: $blending');
              break;
          }
        } else {
          switch (blending) {
            case NormalBlending:
              gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
              break;

            case AdditiveBlending:
              gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
              break;

            case SubtractiveBlending:
              gl.blendFunc(gl.ZERO, gl.ONE_MINUS_SRC_COLOR);
              break;

            case MultiplyBlending:
              gl.blendFunc(gl.ZERO, gl.SRC_COLOR);
              break;

            default:
              print('THREE.WebGLState: Invalid blending: $blending');
              break;
          }
        }

        currentBlendSrc = null;
        currentBlendDst = null;
        currentBlendSrcAlpha = null;
        currentBlendDstAlpha = null;

        currentBlending = blending;
        currentPremultipledAlpha = premultipliedAlpha;
      }

      return;
    }

    // custom blending

    blendEquationAlpha = blendEquationAlpha || blendEquation;
    blendSrcAlpha = blendSrcAlpha || blendSrc;
    blendDstAlpha = blendDstAlpha || blendDst;

    if (blendEquation != currentBlendEquation || blendEquationAlpha != currentBlendEquationAlpha) {
      gl.blendEquationSeparate(equationToGL[blendEquation], equationToGL[blendEquationAlpha]);

      currentBlendEquation = blendEquation;
      currentBlendEquationAlpha = blendEquationAlpha;
    }

    if (blendSrc != currentBlendSrc ||
        blendDst != currentBlendDst ||
        blendSrcAlpha != currentBlendSrcAlpha ||
        blendDstAlpha != currentBlendDstAlpha) {
      gl.blendFuncSeparate(
          factorToGL[blendSrc], factorToGL[blendDst], factorToGL[blendSrcAlpha], factorToGL[blendDstAlpha]);

      currentBlendSrc = blendSrc;
      currentBlendDst = blendDst;
      currentBlendSrcAlpha = blendSrcAlpha;
      currentBlendDstAlpha = blendDstAlpha;
    }

    currentBlending = blending;
    currentPremultipledAlpha = null;
  }

  setMaterial(material, frontFaceCW) {
    material.side == DoubleSide ? disable(gl.CULL_FACE) : enable(gl.CULL_FACE);

    var flipSided = (material.side == BackSide);
    if (frontFaceCW) flipSided = !flipSided;

    setFlipSided(flipSided);

    (material.blending == NormalBlending && material.transparent == false)
        ? setBlending(NoBlending)
        : setBlending(material.blending, material.blendEquation, material.blendSrc, material.blendDst,
            material.blendEquationAlpha, material.blendSrcAlpha, material.blendDstAlpha, material.premultipliedAlpha);

    depthBuffer.setFunc(material.depthFunc);
    depthBuffer.setTest(material.depthTest);
    depthBuffer.setMask(material.depthWrite);
    colorBuffer.setMask(material.colorWrite);

    var stencilWrite = material.stencilWrite;
    stencilBuffer.setTest(stencilWrite);
    if (stencilWrite) {
      stencilBuffer.setMask(material.stencilWriteMask);
      stencilBuffer.setFunc(material.stencilFunc, material.stencilRef, material.stencilFuncMask);
      stencilBuffer.setOp(material.stencilFail, material.stencilZFail, material.stencilZPass);
    }

    setPolygonOffset(material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits);

    material.alphaToCoverage == true ? enable(gl.SAMPLE_ALPHA_TO_COVERAGE) : disable(gl.SAMPLE_ALPHA_TO_COVERAGE);
  }

  setFlipSided(flipSided) {
    if (currentFlipSided != flipSided) {
      if (flipSided) {
        gl.frontFace(gl.CW);
      } else {
        gl.frontFace(gl.CCW);
      }

      currentFlipSided = flipSided;
    }
  }

  setCullFace(cullFace) {
    if (cullFace != CullFaceNone) {
      enable(gl.CULL_FACE);

      if (cullFace != currentCullFace) {
        if (cullFace == CullFaceBack) {
          gl.cullFace(gl.BACK);
        } else if (cullFace == CullFaceFront) {
          gl.cullFace(gl.FRONT);
        } else {
          gl.cullFace(gl.FRONT_AND_BACK);
        }
      }
    } else {
      disable(gl.CULL_FACE);
    }

    currentCullFace = cullFace;
  }

  setLineWidth(width) {
    if (width != currentLineWidth) {
      if (lineWidthAvailable) gl.lineWidth(width);

      currentLineWidth = width;
    }
  }

  setPolygonOffset(polygonOffset, factor, units) {
    if (polygonOffset) {
      enable(gl.POLYGON_OFFSET_FILL);

      if (currentPolygonOffsetFactor != factor || currentPolygonOffsetUnits != units) {
        gl.polygonOffset(factor, units);

        currentPolygonOffsetFactor = factor;
        currentPolygonOffsetUnits = units;
      }
    } else {
      disable(gl.POLYGON_OFFSET_FILL);
    }
  }

  setScissorTest(scissorTest) {
    if (scissorTest) {
      enable(gl.SCISSOR_TEST);
    } else {
      disable(gl.SCISSOR_TEST);
    }
  }

  activeTexture([webglSlot]) {
    if (webglSlot == null) webglSlot = gl.TEXTURE0 + maxTextures - 1;

    if (currentTextureSlot != webglSlot) {
      gl.activeTexture(webglSlot);
      currentTextureSlot = webglSlot;
    }
  }

  bindTexture(webglType, webglTexture) {
    if (currentTextureSlot == null) {
      activeTexture();
    }

    var boundTexture = currentBoundTextures[currentTextureSlot];

    if (boundTexture == null) {
      boundTexture = {'type': null, 'texture': null};
      currentBoundTextures[currentTextureSlot] = boundTexture;
    }

    if (boundTexture['type'] != webglType || boundTexture['texture'] != webglTexture) {
      gl.bindTexture(webglType, webglTexture || emptyTextures[webglType]);

      boundTexture['type'] = webglType;
      boundTexture['texture'] = webglTexture;
    }
  }

  unbindTexture() {
    var boundTexture = currentBoundTextures[currentTextureSlot];

    if (boundTexture != null && boundTexture['type'] != null) {
      gl.bindTexture(boundTexture['type'], null);

      boundTexture['type'] = null;
      boundTexture['texture'] = null;
    }
  }

  compressedTexImage2D() {
    try {
      // gl.compressedTexImage2D.apply( gl, arguments );

    } catch (error) {
      print('THREE.WebGLState: $error');
    }
  }

  texImage2D() {
    try {
      // gl.texImage2D.apply( gl, arguments );

    } catch (error) {
      print('THREE.WebGLState: $error');
    }
  }

  texImage3D() {
    try {
      // gl.texImage3D.apply( gl, arguments );

    } catch (error) {
      print('THREE.WebGLState: $error');
    }
  }

  scissor(scissor) {
    if (currentScissor.equals(scissor) == false) {
      gl.scissor(scissor.x, scissor.y, scissor.z, scissor.w);
      currentScissor.copy(scissor);
    }
  }

  viewport(viewport) {
    if (currentViewport.equals(viewport) == false) {
      gl.viewport(viewport.x, viewport.y, viewport.z, viewport.w);
      currentViewport.copy(viewport);
    }
  }

  reset() {
    // reset state

    gl.disable(gl.BLEND);
    gl.disable(gl.CULL_FACE);
    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.POLYGON_OFFSET_FILL);
    gl.disable(gl.SCISSOR_TEST);
    gl.disable(gl.STENCIL_TEST);
    gl.disable(gl.SAMPLE_ALPHA_TO_COVERAGE);

    gl.blendEquation(gl.FUNC_ADD);
    gl.blendFunc(gl.ONE, gl.ZERO);
    gl.blendFuncSeparate(gl.ONE, gl.ZERO, gl.ONE, gl.ZERO);

    gl.colorMask(true, true, true, true);
    gl.clearColor(0, 0, 0, 0);

    gl.depthMask(true);
    gl.depthFunc(gl.LESS);
    gl.clearDepth(1);

    gl.stencilMask(0xffffffff);
    gl.stencilFunc(gl.ALWAYS, 0, 0xffffffff);
    gl.stencilOp(gl.KEEP, gl.KEEP, gl.KEEP);
    gl.clearStencil(0);

    gl.cullFace(gl.BACK);
    gl.frontFace(gl.CCW);

    gl.polygonOffset(0, 0);

    gl.activeTexture(gl.TEXTURE0);

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    if (isWebGL2 == true) {
      gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, null);
    }

    // gl.useProgram( null );

    gl.lineWidth(1);

    // gl.scissor( 0, 0, gl.canvas.width, gl.canvas.height );
    // gl.viewport( 0, 0, gl.canvas.width, gl.canvas.height );

    // reset internals

    enabledCapabilities = {};

    currentTextureSlot = null;
    currentBoundTextures = {};

    xrFramebuffer = null;
    currentBoundFramebuffers = {};

    currentProgram = null;

    currentBlendingEnabled = false;
    currentBlending = null;
    currentBlendEquation = null;
    currentBlendSrc = null;
    currentBlendDst = null;
    currentBlendEquationAlpha = null;
    currentBlendSrcAlpha = null;
    currentBlendDstAlpha = null;
    currentPremultipledAlpha = false;

    currentFlipSided = null;
    currentCullFace = null;

    currentLineWidth = null;

    currentPolygonOffsetFactor = null;
    currentPolygonOffsetUnits = null;

    // currentScissor.set(0, 0, gl.canvas.width, gl.canvas.height);
    // currentViewport.set(0, 0, gl.canvas.width, gl.canvas.height);

    colorBuffer.reset();
    depthBuffer.reset();
    stencilBuffer.reset();
  }
}

class ColorBuffer {
  bool locked = false;

  Vector4 color = Vector4();
  dynamic currentColorMask;
  Vector4 currentColorClear = Vector4(0, 0, 0, 0);

  OpenGLContextES gl;

  ColorBuffer(this.gl);

  setMask(colorMask) {
    if (currentColorMask != colorMask && !locked) {
      gl.colorMask(colorMask, colorMask, colorMask, colorMask);
      currentColorMask = colorMask;
    }
  }

  setLocked(lock) {
    locked = lock;
  }

  setClear(r, g, b, a, [premultipliedAlpha]) {
    if (premultipliedAlpha == true) {
      r *= a;
      g *= a;
      b *= a;
    }

    color.set(r, g, b, a);

    if (currentColorClear.equals(color) == false) {
      gl.clearColor(r, g, b, a);
      currentColorClear.copy(color);
    }
  }

  reset() {
    locked = false;

    currentColorMask = null;
    currentColorClear.set(-1, 0, 0, 0); // set to invalid state
  }
}

class DepthBuffer {
  bool locked = false;

  dynamic currentDepthMask;
  dynamic currentDepthFunc;
  dynamic currentDepthClear;

  OpenGLContextES gl;
  late dynamic enabledCapabilities;

  DepthBuffer(this.gl, [this.enabledCapabilities]);

  // added the enable and the disable from the parent class.
  enable(id) {
    if (enabledCapabilities[id] != true) {
      gl.enable(id);
      enabledCapabilities[id] = true;
    }
  }

  disable(id) {
    if (enabledCapabilities[id] != false) {
      gl.disable(id);
      enabledCapabilities[id] = false;
    }
  }

  setTest(depthTest) {
    if (depthTest) {
      enable(gl.DEPTH_TEST);
    } else {
      disable(gl.DEPTH_TEST);
    }
  }

  setMask(depthMask) {
    if (currentDepthMask != depthMask && !locked) {
      gl.depthMask(depthMask);
      currentDepthMask = depthMask;
    }
  }

  setFunc(depthFunc) {
    if (currentDepthFunc != depthFunc) {
      if (depthFunc) {
        switch (depthFunc) {
          case NeverDepth:
            gl.depthFunc(gl.NEVER);
            break;

          case AlwaysDepth:
            gl.depthFunc(gl.ALWAYS);
            break;

          case LessDepth:
            gl.depthFunc(gl.LESS);
            break;

          case LessEqualDepth:
            gl.depthFunc(gl.LEQUAL);
            break;

          case EqualDepth:
            gl.depthFunc(gl.EQUAL);
            break;

          case GreaterEqualDepth:
            gl.depthFunc(gl.GEQUAL);
            break;

          case GreaterDepth:
            gl.depthFunc(gl.GREATER);
            break;

          case NotEqualDepth:
            gl.depthFunc(gl.NOTEQUAL);
            break;

          default:
            gl.depthFunc(gl.LEQUAL);
        }
      } else {
        gl.depthFunc(gl.LEQUAL);
      }

      currentDepthFunc = depthFunc;
    }
  }

  setLocked(lock) {
    locked = lock;
  }

  setClear(depth) {
    if (currentDepthClear != depth) {
      gl.clearDepth(depth);
      currentDepthClear = depth;
    }
  }

  reset() {
    locked = false;

    currentDepthMask = null;
    currentDepthFunc = null;
    currentDepthClear = null;
  }
}

class StencilBuffer {
  bool locked = false;

  dynamic currentStencilMask;
  dynamic currentStencilFunc;
  dynamic currentStencilRef;
  dynamic currentStencilFuncMask;
  dynamic currentStencilFail;
  dynamic currentStencilZFail;
  dynamic currentStencilZPass;
  dynamic currentStencilClear;

  OpenGLContextES gl;
  late dynamic enabledCapabilities;

  StencilBuffer(this.gl, [this.enabledCapabilities]);

  // added the enable and the disable from the parent class.
  enable(id) {
    if (enabledCapabilities[id] != true) {
      gl.enable(id);
      enabledCapabilities[id] = true;
    }
  }

  disable(id) {
    if (enabledCapabilities[id] != false) {
      gl.disable(id);
      enabledCapabilities[id] = false;
    }
  }

  setTest(stencilTest) {
    if (!locked) {
      if (stencilTest) {
        enable(gl.STENCIL_TEST);
      } else {
        disable(gl.STENCIL_TEST);
      }
    }
  }

  setMask(stencilMask) {
    if (currentStencilMask != stencilMask && !locked) {
      gl.stencilMask(stencilMask);
      currentStencilMask = stencilMask;
    }
  }

  setFunc(stencilFunc, stencilRef, stencilMask) {
    if (currentStencilFunc != stencilFunc || currentStencilRef != stencilRef || currentStencilFuncMask != stencilMask) {
      gl.stencilFunc(stencilFunc, stencilRef, stencilMask);

      currentStencilFunc = stencilFunc;
      currentStencilRef = stencilRef;
      currentStencilFuncMask = stencilMask;
    }
  }

  setOp(stencilFail, stencilZFail, stencilZPass) {
    if (currentStencilFail != stencilFail ||
        currentStencilZFail != stencilZFail ||
        currentStencilZPass != stencilZPass) {
      gl.stencilOp(stencilFail, stencilZFail, stencilZPass);

      currentStencilFail = stencilFail;
      currentStencilZFail = stencilZFail;
      currentStencilZPass = stencilZPass;
    }
  }

  setLocked(lock) {
    locked = lock;
  }

  setClear(stencil) {
    if (currentStencilClear != stencil) {
      gl.clearStencil(stencil);
      currentStencilClear = stencil;
    }
  }

  reset() {
    locked = false;

    currentStencilMask = null;
    currentStencilFunc = null;
    currentStencilRef = null;
    currentStencilFuncMask = null;
    currentStencilFail = null;
    currentStencilZFail = null;
    currentStencilZPass = null;
    currentStencilClear = null;
  }
}
