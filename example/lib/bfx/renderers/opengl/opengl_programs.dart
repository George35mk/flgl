import 'package:flgl_example/bfx/renderers/shaders/shader_lib.dart';

import '../../constants.dart';
import '../opengl_renderer.dart';
import 'opengl_binding_states.dart';
import 'opengl_capabilities.dart';
import 'opengl_clipping.dart';
import 'opengl_cube_maps.dart';
import 'opengl_cube_uv_maps.dart';
import 'opengl_extensions.dart';

import 'dart:math' as math;

import 'opengl_program.dart';

class OpenGLPrograms {
  OpenGLRenderer renderer;
  OpenGLCubeMaps cubemaps;
  OpenGLCubeUVMaps cubeuvmaps;
  OpenGLExtensions extensions;
  OpenGLCapabilities capabilities;
  OpenGLBindingStates bindingStates;
  OpenGLClipping clipping;

  //
  List programs = [];
  bool isWebGL2 = false;
  dynamic logarithmicDepthBuffer;
  dynamic floatVertexTextures;
  dynamic maxVertexUniforms;
  dynamic vertexTextures;
  dynamic precision;

  Map shaderIDs = {
    'MeshDepthMaterial': 'depth',
    'MeshDistanceMaterial': 'distanceRGBA',
    'MeshNormalMaterial': 'normal',
    'MeshBasicMaterial': 'basic',
    'MeshLambertMaterial': 'lambert',
    'MeshPhongMaterial': 'phong',
    'MeshToonMaterial': 'toon',
    'MeshStandardMaterial': 'physical',
    'MeshPhysicalMaterial': 'physical',
    'MeshMatcapMaterial': 'matcap',
    'LineBasicMaterial': 'basic',
    'LineDashedMaterial': 'dashed',
    'PointsMaterial': 'points',
    'ShadowMaterial': 'shadow',
    'SpriteMaterial': 'sprite'
  };

  List<String> parameterNames = [
    ///
    'precision', 'isWebGL2', 'supportsVertexTextures', 'outputEncoding', 'instancing', 'instancingColor',
    'map', 'mapEncoding', 'matcap', 'matcapEncoding', 'envMap', 'envMapMode', 'envMapEncoding', 'envMapCubeUV',
    'lightMap', 'lightMapEncoding', 'aoMap', 'emissiveMap', 'emissiveMapEncoding', 'bumpMap', 'normalMap',
    'objectSpaceNormalMap', 'tangentSpaceNormalMap',
    'clearcoat', 'clearcoatMap', 'clearcoatRoughnessMap', 'clearcoatNormalMap',
    'displacementMap',
    'specularMap', 'specularIntensityMap', 'specularTintMap', 'specularTintMapEncoding', 'roughnessMap', 'metalnessMap',
    'gradientMap',
    'alphaMap', 'alphaTest', 'combine', 'vertexColors', 'vertexAlphas', 'vertexTangents', 'vertexUvs', 'uvsVertexOnly',
    'fog', 'useFog', 'fogExp2',
    'flatShading', 'sizeAttenuation', 'logarithmicDepthBuffer', 'skinning',
    'maxBones', 'useVertexTexture', 'morphTargets', 'morphNormals', 'morphTargetsCount', 'premultipliedAlpha',
    'numDirLights', 'numPointLights', 'numSpotLights', 'numHemiLights', 'numRectAreaLights',
    'numDirLightShadows', 'numPointLightShadows', 'numSpotLightShadows',
    'shadowMapEnabled', 'shadowMapType', 'toneMapping', 'physicallyCorrectLights',
    'doubleSided', 'flipSided', 'numClippingPlanes', 'numClipIntersection', 'depthPacking', 'dithering', 'format',
    'sheen', 'transmission', 'transmissionMap', 'thicknessMap'
  ];

  OpenGLPrograms(
    this.renderer,
    this.cubemaps,
    this.cubeuvmaps,
    this.extensions,
    this.capabilities,
    this.bindingStates,
    this.clipping,
  ) {
    isWebGL2 = capabilities.isWebGL2;
    logarithmicDepthBuffer = capabilities.logarithmicDepthBuffer;
    floatVertexTextures = capabilities.floatVertexTextures;
    maxVertexUniforms = capabilities.maxVertexUniforms;
    vertexTextures = capabilities.vertexTextures;
    precision = capabilities.precision;
  }

  getMaxBones(object) {
    final skeleton = object.skeleton;
    final List bones = skeleton.bones;

    if (floatVertexTextures) {
      return 1024;
    } else {
      // default for when object is not specified
      // ( for example when prebuilding shader to be used with multiple objects )
      //
      //  - leave some extra space for other uniforms
      //  - limit here is ANGLE's 254 max uniform vectors
      //    (up to 54 should be safe)

      final nVertexUniforms = maxVertexUniforms;
      final int nVertexMatrices = ((nVertexUniforms - 20) / 4).floor();

      final maxBones = math.min(nVertexMatrices, bones.length);

      if (maxBones < bones.length) {
        print('THREE.WebGLRenderer: Skeleton has ${bones.length} bones. This GPU supports ${maxBones}');
        return 0;
      }

      return maxBones;
    }
  }

  getTextureEncodingFromMap(map) {
    var encoding;

    if (map && map.isTexture) {
      encoding = map.encoding;
    } else if (map && map.isWebGLRenderTarget) {
      print(
          'THREE.WebGLPrograms.getTextureEncodingFromMap: don\'t use render targets as textures. Use their .texture property instead.');
      encoding = map.texture.encoding;
    } else {
      encoding = LinearEncoding;
    }

    if (isWebGL2 &&
        map &&
        map.isTexture &&
        map.format == RGBAFormat &&
        map.type == UnsignedByteType &&
        map.encoding == sRGBEncoding) {
      encoding = LinearEncoding; // disable inline decode for sRGB textures in WebGL 2

    }

    return encoding;
  }

  getParameters(material, lights, shadows, scene, object) {
    final fog = scene.fog;
    final environment = material.isMeshStandardMaterial ? scene.environment : null;
    final envMap = (material.isMeshStandardMaterial ? cubeuvmaps : cubemaps).get(material.envMap || environment);
    final shaderID = shaderIDs[material.type];

    // heuristics to create shader parameters according to lights in the scene
    // (not to blow over maxLights budget)

    final maxBones = object.isSkinnedMesh ? getMaxBones(object) : 0;

    if (material.precision != null) {
      precision = capabilities.getMaxPrecision(material.precision);

      if (precision != material.precision) {
        print('THREE.WebGLProgram.getParameters: ${material.precision} not supported, using $precision instead.');
      }
    }

    var vertexShader, fragmentShader;

    if (shaderID) {
      final shader = ShaderLib[shaderID];

      vertexShader = shader.vertexShader;
      fragmentShader = shader.fragmentShader;
    } else {
      vertexShader = material.vertexShader;
      fragmentShader = material.fragmentShader;
    }

    final currentRenderTarget = renderer.getRenderTarget();

    final useAlphaTest = material.alphaTest > 0;
    final useClearcoat = material.clearcoat > 0;

    final parameters = {
      'isWebGL2': isWebGL2,
      'shaderID': shaderID,
      'shaderName': material.type,
      'vertexShader': vertexShader,
      'fragmentShader': fragmentShader,
      'defines': material.defines,
      'isRawShaderMaterial': material.isRawShaderMaterial == true,
      'glslVersion': material.glslVersion,
      'precision': precision,
      'instancing': object.isInstancedMesh == true,
      'instancingColor': object.isInstancedMesh == true && object.instanceColor != null,
      'supportsVertexTextures': vertexTextures,
      'outputEncoding': (currentRenderTarget != null)
          ? getTextureEncodingFromMap(currentRenderTarget.texture)
          : renderer.outputEncoding,
      'map': !!material.map,
      'mapEncoding': getTextureEncodingFromMap(material.map),
      'matcap': !!material.matcap,
      'matcapEncoding': getTextureEncodingFromMap(material.matcap),
      'envMap': !!envMap,
      'envMapMode': envMap && envMap.mapping,
      'envMapEncoding': getTextureEncodingFromMap(envMap),
      'envMapCubeUV':
          (!!envMap) && ((envMap.mapping == CubeUVReflectionMapping) || (envMap.mapping == CubeUVRefractionMapping)),
      'lightMap': !!material.lightMap,
      'lightMapEncoding': getTextureEncodingFromMap(material.lightMap),
      'aoMap': !!material.aoMap,
      'emissiveMap': !!material.emissiveMap,
      'emissiveMapEncoding': getTextureEncodingFromMap(material.emissiveMap),
      'bumpMap': !!material.bumpMap,
      'normalMap': !!material.normalMap,
      'objectSpaceNormalMap': material.normalMapType == ObjectSpaceNormalMap,
      'tangentSpaceNormalMap': material.normalMapType == TangentSpaceNormalMap,
      'clearcoat': useClearcoat,
      'clearcoatMap': useClearcoat && !!material.clearcoatMap,
      'clearcoatRoughnessMap': useClearcoat && !!material.clearcoatRoughnessMap,
      'clearcoatNormalMap': useClearcoat && !!material.clearcoatNormalMap,
      'displacementMap': !!material.displacementMap,
      'roughnessMap': !!material.roughnessMap,
      'metalnessMap': !!material.metalnessMap,
      'specularMap': !!material.specularMap,
      'specularIntensityMap': !!material.specularIntensityMap,
      'specularTintMap': !!material.specularTintMap,
      'specularTintMapEncoding': getTextureEncodingFromMap(material.specularTintMap),
      'alphaMap': !!material.alphaMap,
      'alphaTest': useAlphaTest,
      'gradientMap': !!material.gradientMap,
      'sheen': material.sheen > 0,
      'transmission': material.transmission > 0,
      'transmissionMap': !!material.transmissionMap,
      'thicknessMap': !!material.thicknessMap,
      'combine': material.combine,
      'vertexTangents': (!!material.normalMap && !!object.geometry && !!object.geometry.attributes.tangent),
      'vertexColors': material.vertexColors,
      'vertexAlphas': material.vertexColors == true &&
          !!object.geometry &&
          !!object.geometry.attributes.color &&
          object.geometry.attributes.color.itemSize == 4,
      'vertexUvs': !!material.map ||
          !!material.bumpMap ||
          !!material.normalMap ||
          !!material.specularMap ||
          !!material.alphaMap ||
          !!material.emissiveMap ||
          !!material.roughnessMap ||
          !!material.metalnessMap ||
          !!material.clearcoatMap ||
          !!material.clearcoatRoughnessMap ||
          !!material.clearcoatNormalMap ||
          !!material.displacementMap ||
          !!material.transmissionMap ||
          !!material.thicknessMap ||
          !!material.specularIntensityMap ||
          !!material.specularTintMap,
      'uvsVertexOnly': !(!!material.map ||
              !!material.bumpMap ||
              !!material.normalMap ||
              !!material.specularMap ||
              !!material.alphaMap ||
              !!material.emissiveMap ||
              !!material.roughnessMap ||
              !!material.metalnessMap ||
              !!material.clearcoatNormalMap ||
              material.transmission > 0 ||
              !!material.transmissionMap ||
              !!material.thicknessMap ||
              !!material.specularIntensityMap ||
              !!material.specularTintMap) &&
          !!material.displacementMap,
      'fog': !!fog,
      'useFog': material.fog,
      'fogExp2': (fog && fog.isFogExp2),
      'flatShading': !!material.flatShading,
      'sizeAttenuation': material.sizeAttenuation,
      'logarithmicDepthBuffer': logarithmicDepthBuffer,
      'skinning': object.isSkinnedMesh == true && maxBones > 0,
      'maxBones': maxBones,
      'useVertexTexture': floatVertexTextures,
      'morphTargets': !!object.geometry && !!object.geometry.morphAttributes.position,
      'morphNormals': !!object.geometry && !!object.geometry.morphAttributes.normal,
      'morphTargetsCount': (!!object.geometry && !!object.geometry.morphAttributes.position)
          ? object.geometry.morphAttributes.position.length
          : 0,
      'numDirLights': lights.directional.length,
      'numPointLights': lights.point.length,
      'numSpotLights': lights.spot.length,
      'numRectAreaLights': lights.rectArea.length,
      'numHemiLights': lights.hemi.length,
      'numDirLightShadows': lights.directionalShadowMap.length,
      'numPointLightShadows': lights.pointShadowMap.length,
      'numSpotLightShadows': lights.spotShadowMap.length,
      'numClippingPlanes': clipping.numPlanes,
      'numClipIntersection': clipping.numIntersection,
      'format': material.format,
      'dithering': material.dithering,
      'shadowMapEnabled': renderer.shadowMap.enabled && shadows.length > 0,
      'shadowMapType': renderer.shadowMap.type,
      'toneMapping': material.toneMapped ? renderer.toneMapping : NoToneMapping,
      'physicallyCorrectLights': renderer.physicallyCorrectLights,
      'premultipliedAlpha': material.premultipliedAlpha,
      'doubleSided': material.side == DoubleSide,
      'flipSided': material.side == BackSide,
      'depthPacking': (material.depthPacking != null) ? material.depthPacking : false,
      'index0AttributeName': material.index0AttributeName,
      'extensionDerivatives': material.extensions && material.extensions.derivatives,
      'extensionFragDepth': material.extensions && material.extensions.fragDepth,
      'extensionDrawBuffers': material.extensions && material.extensions.drawBuffers,
      'extensionShaderTextureLOD': material.extensions && material.extensions.shaderTextureLOD,
      'rendererExtensionFragDepth': isWebGL2 || extensions.has('EXT_frag_depth'),
      'rendererExtensionDrawBuffers': isWebGL2 || extensions.has('WEBGL_draw_buffers'),
      'rendererExtensionShaderTextureLod': isWebGL2 || extensions.has('EXT_shader_texture_lod'),
      'customProgramCacheKey': material.customProgramCacheKey()
    };

    return parameters;
  }

  getProgramCacheKey(parameters) {
    final array = [];

    if (parameters.shaderID) {
      array.add(parameters.shaderID);
    } else {
      array.add(parameters.fragmentShader);
      array.add(parameters.vertexShader);
    }

    if (parameters.defines != null) {
      for (const name in parameters.defines) {
        array.add(name);
        array.add(parameters.defines[name]);
      }
    }

    if (parameters.isRawShaderMaterial == false) {
      for (var i = 0; i < parameterNames.length; i++) {
        array.add(parameters[parameterNames[i]]);
      }

      array.add(renderer.outputEncoding);
      array.add(renderer.gammaFactor);
    }

    array.add(parameters.customProgramCacheKey);

    return array.join();
  }

  getUniforms(material) {
    final String shaderID = shaderIDs[material.type];
    var uniforms;

    if (shaderID != null) {
      final shader = ShaderLib[shaderID];
      uniforms = UniformsUtils.clone(shader.uniforms);
    } else {
      uniforms = material.uniforms;
    }

    return uniforms;
  }

  acquireProgram(parameters, cacheKey) {
    var program;

    // Check if code has been already compiled
    for (var p = 0, pl = programs.length; p < pl; p++) {
      final preexistingProgram = programs[p];

      if (preexistingProgram.cacheKey == cacheKey) {
        program = preexistingProgram;
        ++program.usedTimes;

        break;
      }
    }

    if (program == null) {
      program = OpenGLProgram(renderer, cacheKey, parameters, bindingStates);
      programs.add(program);
    }

    return program;
  }

  releaseProgram(program) {
    if (--program.usedTimes == 0) {
      // Remove from unordered set
      final i = programs.indexOf(program);
      programs[i] = programs[programs.length - 1];
      // programs.pop();
      programs.removeLast();

      // Free WebGL resources
      program.destroy();
    }
  }
}
