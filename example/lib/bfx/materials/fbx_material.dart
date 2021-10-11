import 'package:flgl_example/bfx/constants.dart';
import 'package:flgl_example/bfx/math/math_utils.dart';

var materialId = 0;

class FBXMaterial {
  int id = materialId++;
  String uuid = MathUtils.generateUUID();
  String name = '';
  String type = 'Material';
  bool fog = true;
  int blending = NormalBlending;
  int side = FrontSide;
  bool vertexColors = false;

  int opacity = 1;
  int format = RGBAFormat;
  bool transparent = false;

  int blendSrc = SrcAlphaFactor;
  int blendDst = OneMinusSrcAlphaFactor;
  int blendEquation = AddEquation;
  dynamic blendSrcAlpha;
  dynamic blendDstAlpha;
  dynamic blendEquationAlpha;

  int depthFunc = LessEqualDepth;
  bool depthTest = true;
  bool depthWrite = true;

  int stencilWriteMask = 0xff;
  int stencilFunc = AlwaysStencilFunc;
  int stencilRef = 0;
  int stencilFuncMask = 0xff;
  int stencilFail = KeepStencilOp;
  int stencilZFail = KeepStencilOp;
  int stencilZPass = KeepStencilOp;
  bool stencilWrite = false;

  dynamic clippingPlanes;
  bool clipIntersection = false;
  bool clipShadows = false;

  dynamic shadowSide;

  bool colorWrite = true;

  dynamic precision; // override the renderer's default precision for this material

  bool polygonOffset = false;
  int polygonOffsetFactor = 0;
  int polygonOffsetUnits = 0;

  bool dithering = false;
  bool alphaToCoverage = false;
  bool premultipliedAlpha = false;

  bool visible = true;
  bool toneMapped = true;

  Map userData = {};

  int version = 0;
  int _alphaTest = 0;

  dynamic flatShading;

  FBXMaterial();

  operator [](String key) {
    return this[key];
  }

  operator []=(String key, dynamic value) {
    this[key] = value;
  }

  get alphaTest {
    return _alphaTest;
  }

  set alphaTest(value) {
    if (_alphaTest > 0 != value > 0) {
      version++;
    }

    _alphaTest = value;
  }

  onBuild(/* shaderobject, renderer */) {}

  onBeforeRender(/* renderer, scene, camera, geometry, object, group */) {}

  onBeforeCompile(/* shaderobject, renderer */) {}

  customProgramCacheKey() {
    return onBeforeCompile.toString();
  }

  setValues(values) {
    if (values == null) return;

    for (const key in values) {
      final newValue = values[key];

      if (newValue == null) {
        print('THREE.Material: \'' + key + '\' parameter is undefined.');
        continue;
      }

      // for backward compatability if shading is set in the constructor
      if (key == 'shading') {
        print('THREE.' + type + ': .shading has been removed. Use the boolean .flatShading instead.');
        flatShading = (newValue == FlatShading) ? true : false;
        continue;
      }

      final currentValue = this[key];

      if (currentValue == null) {
        print('THREE.$type : $key  is not a property of this material.');
        continue;
      }

      if (currentValue && currentValue.isColor) {
        currentValue.set(newValue);
      } else if ((currentValue && currentValue.isVector3) && (newValue && newValue.isVector3)) {
        currentValue.copy(newValue);
      } else {
        this[key] = newValue;
      }
    }
  }

  clone() {
    return FBXMaterial().copy(this);
  }

  FBXMaterial copy(FBXMaterial source) {
    name = source.name;
    fog = source.fog;

    blending = source.blending;
    side = source.side;
    vertexColors = source.vertexColors;

    opacity = source.opacity;
    format = source.format;
    transparent = source.transparent;

    blendSrc = source.blendSrc;
    blendDst = source.blendDst;
    blendEquation = source.blendEquation;
    blendSrcAlpha = source.blendSrcAlpha;
    blendDstAlpha = source.blendDstAlpha;
    blendEquationAlpha = source.blendEquationAlpha;

    depthFunc = source.depthFunc;
    depthTest = source.depthTest;
    depthWrite = source.depthWrite;

    stencilWriteMask = source.stencilWriteMask;
    stencilFunc = source.stencilFunc;
    stencilRef = source.stencilRef;
    stencilFuncMask = source.stencilFuncMask;
    stencilFail = source.stencilFail;
    stencilZFail = source.stencilZFail;
    stencilZPass = source.stencilZPass;
    stencilWrite = source.stencilWrite;

    final srcPlanes = source.clippingPlanes;
    var dstPlanes;

    if (srcPlanes != null) {
      final n = srcPlanes.length;
      dstPlanes = List.filled(n, 0);

      for (var i = 0; i != n; ++i) {
        dstPlanes[i] = srcPlanes[i].clone();
      }
    }

    clippingPlanes = dstPlanes;
    clipIntersection = source.clipIntersection;
    clipShadows = source.clipShadows;

    shadowSide = source.shadowSide;
    colorWrite = source.colorWrite;
    precision = source.precision;

    polygonOffset = source.polygonOffset;
    polygonOffsetFactor = source.polygonOffsetFactor;
    polygonOffsetUnits = source.polygonOffsetUnits;

    dithering = source.dithering;

    alphaTest = source.alphaTest;
    alphaToCoverage = source.alphaToCoverage;
    premultipliedAlpha = source.premultipliedAlpha;

    visible = source.visible;
    toneMapped = source.toneMapped;

    // userData = JSON.parse(JSON.stringify(source.userData));

    return this;
  }

  dispose() {
    // this.dispatchEvent({type: 'dispose'});
  }

  set needsUpdate(bool value) {
    if (value == true) version++;
  }
}
