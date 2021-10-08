import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/math/vector4.dart';
import 'package:flgl_example/bfx/scene.dart';

import 'opengl/opengl_info.dart';
import 'opengl/opengl_capabilities.dart';
import 'opengl/opengl_extensions.dart';
import 'opengl/opengl_state.dart';
import 'opengl/opengl_utils.dart';

const LinearEncoding = 3000;
const NoToneMapping = 0;

class OpenGLRenderer {
  late Scene scene;
  late Camera camera;
  OpenGLContextES? gl;

  Map<String, dynamic> parameters = {};

  bool alpha;
  bool depth;
  bool stencil;
  bool antialias;
  bool premultipliedAlpha;
  bool preserveDrawingBuffer;
  String powerPreference;
  bool failIfMajorPerformanceCaveat;

  var currentRenderList;
  var currentRenderState;

  var renderListStack = [];
  var renderStateStack = [];

  Map debug = {'checkShaderErrors': true};

  // clearing
  bool autoClear = true;
  bool autoClearColor = true;
  bool autoClearDepth = true;
  bool autoClearStencil = true;

  // scene graph
  bool sortObjects = true;

  // user-defined clipping
  List clippingPlanes = [];
  bool localClippingEnabled = false;

  // physically based shading
  double gammaFactor = 2.0; // for backwards compatibility
  int outputEncoding = LinearEncoding;

  // physical lights
  bool physicallyCorrectLights = false;

  // tone mapping
  int toneMapping = NoToneMapping;
  double toneMappingExposure = 1.0;

  // internal properties
  final bool _isContextLost = false;

  // internal state cache
  final int _currentActiveCubeFace = 0;
  final int _currentActiveMipmapLevel = 0;
  final dynamic _currentRenderTarget = null;
  final int _currentMaterialId = -1;

  final dynamic _currentCamera = null;

  final Vector4 _currentViewport = Vector4();
  final Vector4 _currentScissor = Vector4();
  final dynamic _currentScissorTest = null;

  //

  // final double _width = _canvas.width;
  // final double _height = _canvas.height;
  final double _width = 500;
  final double _height = 500;

  final dynamic _pixelRatio = 1;
  final dynamic _opaqueSort = null;
  final dynamic _transparentSort = null;

  late Vector4 _viewport;
  late Vector4 _scissor;
  dynamic _scissorTest = false;

  //

  final List _currentDrawBuffers = [];

  late OpenGLExtensions extensions;
  late OpenGLCapabilities capabilities;
  late OpenGLUtils utils;
  late OpenGLState state;
  late OpenGLInfo info;

  // OpenGLContextES gl
  OpenGLRenderer({
    this.gl,
    this.alpha = false,
    this.depth = true,
    this.stencil = true,
    this.antialias = false,
    this.premultipliedAlpha = true,
    this.preserveDrawingBuffer = false,
    this.powerPreference = 'default',
    this.failIfMajorPerformanceCaveat = false,
  }) {
    _viewport = Vector4(0, 0, _width, _height);
    _scissor = Vector4(0, 0, _width, _height);

    initGLContext();
  }

  initGLContext() {
    extensions = OpenGLExtensions(gl!);
    capabilities = OpenGLCapabilities(gl!, extensions, parameters);
    extensions.init(capabilities);

    utils = OpenGLUtils(gl!, extensions, capabilities);
    state = OpenGLState(gl!, extensions, capabilities);
    _currentDrawBuffers[0] = gl!.BACK;

    info = OpenGLInfo(gl!);
  }

  /// on render init you must:
  /// - compile and link the shaders
  /// - create a program from vertex shader & fragment shader.
  /// - create attribute setters
  /// - create uniform setters.
  /// for each object in scene get the geometry and material
  /// from geometry get the:
  /// - indices
  /// - positions
  /// - normals
  /// - and uv's
  /// From material get the color and compute the color vertices. for now.
  ///
  init() {
    // ensure you have gl
    print('gl runtimeType: ${gl.runtimeType}');

    /// get gl capabilities.
  }

  render(Scene scene, Camera camera) {
    print('Render');

    /// update scene matrix world
    /// update camera matrix world
    ///
    /// then make 3 lists of:
    /// - opaque objects
    ///
    /// - transparent objects are the last

    if (scene.autoUpdate) {
      scene.updateMatrixWorld();
    }
    if (camera.parent == null) camera.updateMatrixWorld();
  }

  renderScene() {
    // renderObjects()
  }

  renderObjects() {
    /// For each object in render list call renderObject()
  }

  renderObject() {
    // renderBufferDirect()
  }

  renderBufferDirect() {
    //
  }
}

class WebGLBufferRenderer {
  dynamic gl;
  dynamic extensions;
  dynamic info;
  dynamic capabilities;
  dynamic mode;

  WebGLBufferRenderer(this.gl, this.extensions, this.info, this.capabilities);

  // setMode(gl.TRIANGLES);
  setMode() {
    //
  }

  render(start, count) {
    gl.drawArrays(mode, start, count);
    info.update(count, mode, 1);
  }
}

class WebGLIndexedBufferRenderer {
  WebGLIndexedBufferRenderer();
}
