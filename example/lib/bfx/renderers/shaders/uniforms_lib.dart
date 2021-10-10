import 'package:flgl_example/bfx/math/color.dart';
import 'package:flgl_example/bfx/math/matrix3.dart';
import 'package:flgl_example/bfx/math/vector2.dart';

class UniformsLib {
  UniformsLib();

  Map common = {
    'diffuse': {'value': Color(0xffffff)},
    'opacity': {'value': 1.0},
    'map': {'value': null},
    'uvTransform': {'value': Matrix3()},
    'uv2Transform': {'value': Matrix3()},
    'alphaMap': {'value': null},
    'alphaTest': {'value': 0}
  };

  Map specularmap = {
    'specularMap': {'value': null},
  };

  Map envmap = {
    'envMap': {'value': null},
    'flipEnvMap': {'value': -1},
    'reflectivity': {'value': 1.0}, // basic, lambert, phong
    'ior': {'value': 1.5}, // standard, physical
    'refractionRatio': {'value': 0.98},
    'maxMipLevel': {'value': 0}
  };

  Map aomap = {
    'aoMap': {'value': null},
    'aoMapIntensity': {'value': 1}
  };

  Map lightmap = {
    'lightMap': {'value': null},
    'lightMapIntensity': {'value': 1}
  };

  Map emissivemap = {
    'emissiveMap': {'value': null}
  };

  Map bumpmap = {
    'bumpMap': {'value': null},
    'bumpScale': {'value': 1}
  };

  Map normalmap = {
    'normalMap': {'value': null},
    'normalScale': {'value': Vector2(1, 1)}
  };

  Map displacementmap = {
    'displacementMap': {'value': null},
    'displacementScale': {'value': 1},
    'displacementBias': {'value': 0}
  };

  Map roughnessmap = {
    'roughnessMap': {'value': null}
  };

  Map metalnessmap = {
    'metalnessMap': {'value': null}
  };

  Map gradientmap = {
    'gradientMap': {'value': null}
  };

  Map fog = {
    'fogDensity': {'value': 0.00025},
    'fogNear': {'value': 1},
    'fogFar': {'value': 2000},
    'fogColor': {'value': Color(0xffffff)}
  };

  Map lights = {
        'ambientLightColor': {'value': []},
        'lightProbe': {'value': []},
        'directionalLights': {
          'value': [],
          'properties': {
            'direction': {},
            'color': {},
          },
        },

        'directionalLightShadows': {
          'value': [],
          'properties': {
            'shadowBias': {},
            'shadowNormalBias': {},
            'shadowRadius': {},
            'shadowMapSize': {},
          }
        },

        'directionalShadowMap': {
          'value': [],
        },
        'directionalShadowMatrix': {
          'value': [],
        },

        'spotLights': {
          'value': [],
          'properties': {
            'color': {},
            'position': {},
            'direction': {},
            'distance': {},
            'coneCos': {},
            'penumbraCos': {},
            'decay': {}
          }
        },

        'spotLightShadows': {
          'value': [],
          'properties': {
            'shadowBias': {},
            'shadowNormalBias': {},
            'shadowRadius': {},
            'shadowMapSize': {},
          }
        },

        'spotShadowMap': {'value': []},
        'spotShadowMatrix': {'value': []},

        'pointLights': {
          'value': [],
          'properties': {
            'color': {},
            'position': {},
            'decay': {},
            'distance': {},
          }
        },

        'pointLightShadows': {
          'value': [],
          'properties': {
            'shadowBias': {},
            'shadowNormalBias': {},
            'shadowRadius': {},
            'shadowMapSize': {},
            'shadowCameraNear': {},
            'shadowCameraFar': {}
          }
        },

        'pointShadowMap': {'value': []},
        'pointShadowMatrix': {'value': []},

        'hemisphereLights': {
          'value': [],
          'properties': {
            'direction': {},
            'skyColor': {},
            'groundColor': {},
          }
        },

        // TODO (abelnation): RectAreaLight BRDF data needs to be moved from example to main src
        'rectAreaLights': {
          'value': [],
          'properties': {
            'color': {},
            'position': {},
            'width': {},
            'height': {},
          }
        },

        'ltc_1': {'value': null},
        'ltc_2': {'value': null}
      },
      points = {
        'diffuse': {'value': Color(0xffffff)},
        'opacity': {'value': 1.0},
        'size': {'value': 1.0},
        'scale': {'value': 1.0},
        'map': {'value': null},
        'alphaMap': {'value': null},
        'alphaTest': {'value': 0},
        'uvTransform': {'value': Matrix3()}
      };

  Map sprite = {
    'diffuse': {'value': Color(0xffffff)},
    'opacity': {'value': 1.0},
    'center': {'value': Vector2(0.5, 0.5)},
    'rotation': {'value': 0.0},
    'map': {'value': null},
    'alphaMap': {'value': null},
    'alphaTest': {'value': 0},
    'uvTransform': {'value': Matrix3()}
  };
}
