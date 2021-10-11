import 'package:flgl_example/bfx/math/color.dart';
import 'package:flgl_example/bfx/math/matrix4.dart';
import 'package:flgl_example/bfx/math/vector2.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/renderers/shaders/uniforms_lib.dart';

import 'opengl_capabilities.dart';
import 'opengl_extensions.dart';

import 'dart:math' as math;

var nextVersion = 0;

class OpenGLLights {
  OpenGLExtensions extensions;
  OpenGLCapabilities capabilities;

  UniformsCache cache = UniformsCache();
  ShadowUniformsCache shadowCache = ShadowUniformsCache();

  Map<dynamic, dynamic> state = {};

  Vector3 vector3 = Vector3();
  Matrix4 matrix4 = Matrix4();
  Matrix4 matrix42 = Matrix4();

  OpenGLLights(this.extensions, this.capabilities) {
    state = {
      'version': 0,
      'hash': {
        'directionalLength': -1,
        'pointLength': -1,
        'spotLength': -1,
        'rectAreaLength': -1,
        'hemiLength': -1,
        'numDirectionalShadows': -1,
        'numPointShadows': -1,
        'numSpotShadows': -1
      },
      'ambient': [0, 0, 0],
      'probe': [],
      'directional': [],
      'directionalShadow': [],
      'directionalShadowMap': [],
      'directionalShadowMatrix': [],
      'spot': [],
      'spotShadow': [],
      'spotShadowMap': [],
      'spotShadowMatrix': [],
      'rectArea': [],
      'rectAreaLTC1': null,
      'rectAreaLTC2': null,
      'point': [],
      'pointShadow': [],
      'pointShadowMap': [],
      'pointShadowMatrix': [],
      'hemi': []
    };

    for (var i = 0; i < 9; i++) {
      state['probe'].add(Vector3());
    }
  }

  setup(lights, physicallyCorrectLights) {
    double r = 0, g = 0, b = 0;

    for (var i = 0; i < 9; i++) {
      state['probe'][i].set(0, 0, 0);
    }

    var directionalLength = 0;
    var pointLength = 0;
    var spotLength = 0;
    var rectAreaLength = 0;
    var hemiLength = 0;

    var numDirectionalShadows = 0;
    var numPointShadows = 0;
    var numSpotShadows = 0;

    lights.sort(shadowCastingLightsFirst);

    // artist-friendly light intensity scaling factor
    final scaleFactor = (physicallyCorrectLights != true) ? math.pi : 1;

    for (var i = 0, l = lights.length; i < l; i++) {
      final light = lights[i];

      final Color color = light.color;
      final intensity = light.intensity;
      final distance = light.distance;

      final shadowMap = (light.shadow && light.shadow.map) ? light.shadow.map.texture : null;

      if (light.isAmbientLight) {
        r += color.r * intensity * scaleFactor;
        g += color.g * intensity * scaleFactor;
        b += color.b * intensity * scaleFactor;
      } else if (light.isLightProbe) {
        for (var j = 0; j < 9; j++) {
          state['probe'][j].addScaledVector(light.sh.coefficients[j], intensity);
        }
      } else if (light.isDirectionalLight) {
        final uniforms = cache.get(light);

        uniforms.color.copy(light.color).multiplyScalar(light.intensity * scaleFactor);

        if (light.castShadow) {
          final shadow = light.shadow;

          final shadowUniforms = shadowCache.get(light);

          shadowUniforms.shadowBias = shadow.bias;
          shadowUniforms.shadowNormalBias = shadow.normalBias;
          shadowUniforms.shadowRadius = shadow.radius;
          shadowUniforms.shadowMapSize = shadow.mapSize;

          state['directionalShadow'][directionalLength] = shadowUniforms;
          state['directionalShadowMap'][directionalLength] = shadowMap;
          state['directionalShadowMatrix'][directionalLength] = light.shadow.matrix;

          numDirectionalShadows++;
        }

        state['directional'][directionalLength] = uniforms;

        directionalLength++;
      } else if (light.isSpotLight) {
        final uniforms = cache.get(light);

        uniforms.position.setFromMatrixPosition(light.matrixWorld);

        uniforms.color.copy(color).multiplyScalar(intensity * scaleFactor);
        uniforms.distance = distance;

        uniforms.coneCos = math.cos(light.angle);
        uniforms.penumbraCos = math.cos(light.angle * (1 - light.penumbra));
        uniforms.decay = light.decay;

        if (light.castShadow) {
          final shadow = light.shadow;

          final shadowUniforms = shadowCache.get(light);

          shadowUniforms.shadowBias = shadow.bias;
          shadowUniforms.shadowNormalBias = shadow.normalBias;
          shadowUniforms.shadowRadius = shadow.radius;
          shadowUniforms.shadowMapSize = shadow.mapSize;

          state['spotShadow'][spotLength] = shadowUniforms;
          state['spotShadowMap'][spotLength] = shadowMap;
          state['spotShadowMatrix'][spotLength] = light.shadow.matrix;

          numSpotShadows++;
        }

        state['spot'][spotLength] = uniforms;

        spotLength++;
      } else if (light.isRectAreaLight) {
        final uniforms = cache.get(light);

        // (a) intensity is the total visible light emitted
        //uniforms.color.copy( color ).multiplyScalar( intensity / ( light.width * light.height * Math.PI ) );

        // (b) intensity is the brightness of the light
        uniforms.color.copy(color).multiplyScalar(intensity);

        uniforms.halfWidth.set(light.width * 0.5, 0.0, 0.0);
        uniforms.halfHeight.set(0.0, light.height * 0.5, 0.0);

        state['rectArea'][rectAreaLength] = uniforms;

        rectAreaLength++;
      } else if (light.isPointLight) {
        final uniforms = cache.get(light);

        uniforms.color.copy(light.color).multiplyScalar(light.intensity * scaleFactor);
        uniforms.distance = light.distance;
        uniforms.decay = light.decay;

        if (light.castShadow) {
          final shadow = light.shadow;

          final shadowUniforms = shadowCache.get(light);

          shadowUniforms.shadowBias = shadow.bias;
          shadowUniforms.shadowNormalBias = shadow.normalBias;
          shadowUniforms.shadowRadius = shadow.radius;
          shadowUniforms.shadowMapSize = shadow.mapSize;
          shadowUniforms.shadowCameraNear = shadow.camera.near;
          shadowUniforms.shadowCameraFar = shadow.camera.far;

          state['pointShadow'][pointLength] = shadowUniforms;
          state['pointShadowMap'][pointLength] = shadowMap;
          state['pointShadowMatrix'][pointLength] = light.shadow.matrix;

          numPointShadows++;
        }

        state['point'][pointLength] = uniforms;

        pointLength++;
      } else if (light.isHemisphereLight) {
        final uniforms = cache.get(light);

        uniforms.skyColor.copy(light.color).multiplyScalar(intensity * scaleFactor);
        uniforms.groundColor.copy(light.groundColor).multiplyScalar(intensity * scaleFactor);

        state['hemi'][hemiLength] = uniforms;

        hemiLength++;
      }
    }

    if (rectAreaLength > 0) {
      if (capabilities.isWebGL2) {
        // WebGL 2

        // state['rectAreaLTC1'] = UniformsLib.LTC_FLOAT_1;
        // state['rectAreaLTC2'] = UniformsLib.LTC_FLOAT_2;
      } else {
        // WebGL 1

        if (extensions.has('OES_texture_float_linear') == true) {
          // state['rectAreaLTC1'] = UniformsLib.LTC_FLOAT_1;
          // state['rectAreaLTC2'] = UniformsLib.LTC_FLOAT_2;
        } else if (extensions.has('OES_texture_half_float_linear') == true) {
          // state['rectAreaLTC1'] = UniformsLib.LTC_HALF_1;
          // state['rectAreaLTC2'] = UniformsLib.LTC_HALF_2;
        } else {
          print('THREE.WebGLRenderer: Unable to use RectAreaLight. Missing WebGL extensions.');
        }
      }
    }

    state['ambient'][0] = r;
    state['ambient'][1] = g;
    state['ambient'][2] = b;

    final hash = state['hash'];

    if (hash['directionalLength'] != directionalLength ||
        hash['pointLength'] != pointLength ||
        hash['spotLength'] != spotLength ||
        hash['rectAreaLength'] != rectAreaLength ||
        hash['hemiLength'] != hemiLength ||
        hash['numDirectionalShadows'] != numDirectionalShadows ||
        hash['numPointShadows'] != numPointShadows ||
        hash['numSpotShadows'] != numSpotShadows) {
      state['directional'].length = directionalLength;
      state['spot'].length = spotLength;
      state['rectArea'].length = rectAreaLength;
      state['point'].length = pointLength;
      state['hemi'].length = hemiLength;

      state['directionalShadow'].length = numDirectionalShadows;
      state['directionalShadowMap'].length = numDirectionalShadows;
      state['pointShadow'].length = numPointShadows;
      state['pointShadowMap'].length = numPointShadows;
      state['spotShadow'].length = numSpotShadows;
      state['spotShadowMap'].length = numSpotShadows;
      state['directionalShadowMatrix'].length = numDirectionalShadows;
      state['pointShadowMatrix'].length = numPointShadows;
      state['spotShadowMatrix'].length = numSpotShadows;

      hash['directionalLength'] = directionalLength;
      hash['pointLength'] = pointLength;
      hash['spotLength'] = spotLength;
      hash['rectAreaLength'] = rectAreaLength;
      hash['hemiLength'] = hemiLength;

      hash['numDirectionalShadows'] = numDirectionalShadows;
      hash['numPointShadows'] = numPointShadows;
      hash['numSpotShadows'] = numSpotShadows;

      state['version'] = nextVersion++;
    }
  }

  setupView(lights, camera) {
    var directionalLength = 0;
    var pointLength = 0;
    var spotLength = 0;
    var rectAreaLength = 0;
    var hemiLength = 0;

    final viewMatrix = camera.matrixWorldInverse;

    for (var i = 0, l = lights.length; i < l; i++) {
      final light = lights[i];

      if (light.isDirectionalLight) {
        final uniforms = state['directional'][directionalLength];

        uniforms.direction.setFromMatrixPosition(light.matrixWorld);
        vector3.setFromMatrixPosition(light.target.matrixWorld);
        uniforms.direction.sub(vector3);
        uniforms.direction.transformDirection(viewMatrix);

        directionalLength++;
      } else if (light.isSpotLight) {
        final uniforms = state['spot'][spotLength];

        uniforms.position.setFromMatrixPosition(light.matrixWorld);
        uniforms.position.applyMatrix4(viewMatrix);

        uniforms.direction.setFromMatrixPosition(light.matrixWorld);
        vector3.setFromMatrixPosition(light.target.matrixWorld);
        uniforms.direction.sub(vector3);
        uniforms.direction.transformDirection(viewMatrix);

        spotLength++;
      } else if (light.isRectAreaLight) {
        final uniforms = state['rectArea'][rectAreaLength];

        uniforms.position.setFromMatrixPosition(light.matrixWorld);
        uniforms.position.applyMatrix4(viewMatrix);

        // extract local rotation of light to derive width/height half vectors
        matrix42.identity();
        matrix4.copy(light.matrixWorld);
        matrix4.premultiply(viewMatrix);
        matrix42.extractRotation(matrix4);

        uniforms.halfWidth.set(light.width * 0.5, 0.0, 0.0);
        uniforms.halfHeight.set(0.0, light.height * 0.5, 0.0);

        uniforms.halfWidth.applyMatrix4(matrix42);
        uniforms.halfHeight.applyMatrix4(matrix42);

        rectAreaLength++;
      } else if (light.isPointLight) {
        final uniforms = state['point'][pointLength];

        uniforms.position.setFromMatrixPosition(light.matrixWorld);
        uniforms.position.applyMatrix4(viewMatrix);

        pointLength++;
      } else if (light.isHemisphereLight) {
        final uniforms = state['hemi'][hemiLength];

        uniforms.direction.setFromMatrixPosition(light.matrixWorld);
        uniforms.direction.transformDirection(viewMatrix);
        uniforms.direction.normalize();

        hemiLength++;
      }
    }
  }
}

class ShadowUniformsCache {
  Map lights = {};
  ShadowUniformsCache();

  get(light) {
    if (lights[light.id] != null) {
      return lights[light.id];
    }

    var uniforms;

    switch (light.type) {
      case 'DirectionalLight':
        uniforms = {
          'shadowBias': 0,
          'shadowNormalBias': 0,
          'shadowRadius': 1,
          'shadowMapSize': Vector2(),
        };
        break;

      case 'SpotLight':
        uniforms = {
          'shadowBias': 0,
          'shadowNormalBias': 0,
          'shadowRadius': 1,
          'shadowMapSize': Vector2(),
        };
        break;

      case 'PointLight':
        uniforms = {
          'shadowBias': 0,
          'shadowNormalBias': 0,
          'shadowRadius': 1,
          'shadowMapSize': Vector2(),
          'shadowCameraNear': 1,
          'shadowCameraFar': 1000,
        };
        break;

      // ignore: todo
      // TODO (abelnation): set RectAreaLight shadow uniforms

    }

    lights[light.id] = uniforms;

    return uniforms;
  }
}

class UniformsCache {
  var lights = {};

  UniformsCache();

  get(light) {
    if (lights[light.id] != null) {
      return lights[light.id];
    }

    var uniforms;

    switch (light.type) {
      case 'DirectionalLight':
        uniforms = {'direction': Vector3(), 'color': Color()};
        break;

      case 'SpotLight':
        uniforms = {
          'position': Vector3(),
          'direction': Vector3(),
          'color': Color(),
          'distance': 0,
          'coneCos': 0,
          'penumbraCos': 0,
          'decay': 0
        };
        break;

      case 'PointLight':
        uniforms = {
          'position': Vector3(),
          'color': Color(),
          'distance': 0,
          'decay': 0,
        };
        break;

      case 'HemisphereLight':
        uniforms = {
          'direction': Vector3(),
          'skyColor': Color(),
          'groundColor': Color(),
        };
        break;

      case 'RectAreaLight':
        uniforms = {
          'color': Color(),
          'position': Vector3(),
          'halfWidth': Vector3(),
          'halfHeight': Vector3(),
        };
        break;
    }

    lights[light.id] = uniforms;

    return uniforms;
  }
}

shadowCastingLightsFirst(lightA, lightB) {
  return (lightB.castShadow ? 1 : 0) - (lightA.castShadow ? 1 : 0);
}
