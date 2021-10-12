import 'package:flgl/openGL/contexts/open_gl_context_es.dart';
import 'package:flgl_example/bfx/cameras/camera.dart';
import 'package:flgl_example/bfx/core/buffer_geometry.dart';
import 'package:flgl_example/bfx/core/object_3d.dart';
import 'package:flgl_example/bfx/materials/fbx_material.dart';
import 'package:flgl_example/bfx/math/frustum.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/math/vector4.dart';
import 'package:flgl_example/bfx/scene.dart';

import 'opengl/opengl_attributes.dart';
import 'opengl/opengl_binding_states.dart';
import 'opengl/opengl_capabilities.dart';
import 'opengl/opengl_clipping.dart';
import 'opengl/opengl_cube_maps.dart';
import 'opengl/opengl_cube_uv_maps.dart';
import 'opengl/opengl_extensions.dart';
import 'opengl/opengl_geometries.dart';
import 'opengl/opengl_info.dart';
import 'opengl/opengl_objects.dart';
import 'opengl/opengl_programs.dart';
import 'opengl/opengl_properties.dart';
import 'opengl/opengl_render_lists.dart';
import 'opengl/opengl_render_states.dart';
import 'opengl/opengl_state.dart';
import 'opengl/opengl_utils.dart';

// const LinearEncoding = 3000;
// const NoToneMapping = 0;

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

  final bool _scissorTest = false;
  final List _currentDrawBuffers = []; // frustum
  final Frustum _frustum = Frustum(); // clipping

  final bool _clippingEnabled = false;
  final bool _localClippingEnabled = false; // transmission

  final dynamic _transmissionRenderTarget = null; // camera matrices cache
  final Matrix4 _projScreenMatrix = Matrix4();
  final Vector3 _vector3 = Vector3();

  final Map _emptyScene = {
    'background': null,
    'fog': null,
    'environment': null,
    'overrideMaterial': null,
    'isScene': true,
  };

  //

  late OpenGLExtensions extensions;
  late OpenGLCapabilities capabilities;
  late OpenGLUtils utils;
  late OpenGLState state;
  late OpenGLInfo info;
  late OpenGLProperties properties;
  // late OpenGLTextures textures;
  late OpenGLCubeMaps cubemaps;
  late OpenGLCubeUVMaps cubeuvmaps;
  late OpenGLAttributes attributes;
  late OpenGLBindingStates bindingStates;
  late OpenGLGeometries geometries;
  late OpenGLObjects objects;
  // late OpenGLMorphtargets morphtargets;
  late OpenGLClipping clipping;
  late OpenGLPrograms programCache;
  late OpenGLRenderLists renderLists;
  late OpenGLRenderStates renderStates;

  late OpenGLRenderer _this;

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
    _this = this;
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
    properties = OpenGLProperties();
    // textures = new WebGLTextures(_gl, extensions, state, properties, capabilities, utils, info);
    cubemaps = OpenGLCubeMaps(_this);
    cubeuvmaps = OpenGLCubeUVMaps(_this);
    attributes = OpenGLAttributes(gl!, capabilities);
    bindingStates = OpenGLBindingStates(gl!, extensions, attributes, capabilities);
    geometries = OpenGLGeometries(gl!, attributes, info, bindingStates);
    objects = OpenGLObjects(gl!, geometries, attributes, info);
    // morphtargets = new WebGLMorphtargets(_gl, capabilities, textures);
    clipping = OpenGLClipping(properties);
    programCache = OpenGLPrograms(_this, cubemaps, cubeuvmaps, extensions, capabilities, bindingStates, clipping);
    // materials = new WebGLMaterials(properties);
    renderLists = OpenGLRenderLists(properties);
    renderStates = OpenGLRenderStates(extensions, capabilities);
    // background = new WebGLBackground(_this, cubemaps, state, objects, _premultipliedAlpha);
    // shadowMap = new WebGLShadowMap(_this, objects, capabilities);
    // bufferRenderer = new WebGLBufferRenderer(_gl, extensions, info, capabilities);
    // indexedBufferRenderer = new WebGLIndexedBufferRenderer(_gl, extensions, info, capabilities);
    // info.programs = programCache.programs;
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

    currentRenderState = renderStates.get(scene, renderStateStack.length);
    currentRenderState.init();
    renderStateStack.add(currentRenderState);

    _projScreenMatrix.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse);

    _frustum.setFromProjectionMatrix(_projScreenMatrix);

    currentRenderList = renderLists.get(scene, renderListStack.length);
    currentRenderList.init();
    renderListStack.add(currentRenderList);
    // projectObject(scene, camera, 0, _this.sortObjects);
    currentRenderList.finish();

    if (_this.sortObjects == true) {
      currentRenderList.sort(_opaqueSort, _transparentSort);
    } //

    renderScene(currentRenderList, scene, camera);
  }

  renderScene(currentRenderList, Scene scene, Camera camera, [viewport]) {
    var opaqueObjects = currentRenderList.opaque;
    // var transmissiveObjects = currentRenderList.transmissive;
    // var transparentObjects = currentRenderList.transparent;
    currentRenderState.setupLightsView(camera);
    // if (transmissiveObjects.length > 0) renderTransmissionPass(opaqueObjects, scene, camera); // not for now
    if (viewport) state.viewport(_currentViewport.copy(viewport));
    if (opaqueObjects.length > 0) renderObjects(opaqueObjects, scene, camera);
    // if (transmissiveObjects.length > 0) renderObjects(transmissiveObjects, scene, camera);
    // if (transparentObjects.length > 0) renderObjects(transparentObjects, scene, camera);
  }

  /// renderList can be:
  /// - opaqueObjects list
  /// - transmissiveObjects list
  /// - transparentObjects list
  renderObjects(renderList, Scene scene, Camera camera) {
    var overrideMaterial = scene.isScene == true ? scene.overrideMaterial : null;

    for (var i = 0, l = renderList.length; i < l; i++) {
      final renderItem = renderList[i];
      final Object3D object = renderItem.object;
      final BufferGeometry geometry = renderItem.geometry;
      final FBXMaterial material = overrideMaterial ?? renderItem.material;
      final group = renderItem.group;

      if (object.layers.test(camera.layers)) {
        renderObject(object, scene, camera, geometry, material, group);
      }
    }
  }

  renderObject(Object3D object, Scene scene, Camera camera, BufferGeometry geometry, FBXMaterial material, group) {
    // object.onBeforeRender(_this, scene, camera, geometry, material, group);
    object.modelViewMatrix.multiplyMatrices(camera.matrixWorldInverse, object.matrixWorld);
    object.normalMatrix.getNormalMatrix(object.modelViewMatrix);
    // material.onBeforeRender(_this, scene, camera, geometry, object, group);

    // if (object.isImmediateRenderObject) {
    //   var program = setProgram(camera, scene, material, object);
    //   state.setMaterial(material);
    //   bindingStates.reset();
    //   renderObjectImmediate(object, program);
    // } else {
    //   if (material.transparent == true && material.side == DoubleSide) {
    //     material.side = BackSide;
    //     material.needsUpdate = true;

    //     _this.renderBufferDirect(camera, scene, geometry, material, object, group);

    //     material.side = FrontSide;
    //     material.needsUpdate = true;

    //     _this.renderBufferDirect(camera, scene, geometry, material, object, group);

    //     material.side = DoubleSide;
    //   } else {
    //     _this.renderBufferDirect(camera, scene, geometry, material, object, group);
    //   }
    // }

    _this.renderBufferDirect(camera, scene, geometry, material, object, group);
  }

  renderBufferDirect(
    Camera camera,
    Scene scene,
    BufferGeometry geometry,
    FBXMaterial material,
    Object3D object,
    group,
  ) {
    // edo emina
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
