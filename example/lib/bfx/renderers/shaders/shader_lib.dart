import 'package:flgl_example/bfx/math/color.dart';
import 'package:flgl_example/bfx/math/vector3.dart';
import 'package:flgl_example/bfx/renderers/shaders/uniforms_lib.dart';

import 'shader_chunk.dart';
import 'uniforms_utils.dart';

class ShaderLib {
  ShaderLib();

  Map<String, dynamic> basic = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.common,
      UniformsLib.specularmap,
      UniformsLib.envmap,
      UniformsLib.aomap,
      UniformsLib.lightmap,
      UniformsLib.fog
    ]),
    'vertexShader': ShaderChunk.meshbasic_vert,
    'fragmentShader': ShaderChunk.meshbasic_frag
  };

  Map<String, dynamic> lambert = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.common,
      UniformsLib.specularmap,
      UniformsLib.envmap,
      UniformsLib.aomap,
      UniformsLib.lightmap,
      UniformsLib.emissivemap,
      UniformsLib.fog,
      UniformsLib.lights,
      {
        'emissive': {'value': Color(0x000000)}
      }
    ]),
    'vertexShader': ShaderChunk.meshlambert_vert,
    'fragmentShader': ShaderChunk.meshlambert_frag
  };

  Map<String, dynamic> phong = {
        'uniforms': UniformsUtils.mergeUniforms([
          UniformsLib.common,
          UniformsLib.specularmap,
          UniformsLib.envmap,
          UniformsLib.aomap,
          UniformsLib.lightmap,
          UniformsLib.emissivemap,
          UniformsLib.bumpmap,
          UniformsLib.normalmap,
          UniformsLib.displacementmap,
          UniformsLib.fog,
          UniformsLib.lights,
          {
            'emissive': {'value': new Color(0x000000)},
            'specular': {'value': new Color(0x111111)},
            'shininess': {'value': 30}
          }
        ]),
        'vertexShader': ShaderChunk.meshphong_vert,
        'fragmentShader': ShaderChunk.meshphong_frag
      },
      standard = {
        'uniforms': UniformsUtils.mergeUniforms([
          UniformsLib.common,
          UniformsLib.envmap,
          UniformsLib.aomap,
          UniformsLib.lightmap,
          UniformsLib.emissivemap,
          UniformsLib.bumpmap,
          UniformsLib.normalmap,
          UniformsLib.displacementmap,
          UniformsLib.roughnessmap,
          UniformsLib.metalnessmap,
          UniformsLib.fog,
          UniformsLib.lights,
          {
            'emissive': {'value': Color(0x000000)},
            'roughness': {'value': 1.0},
            'metalness': {'value': 0.0},
            'envMapIntensity': {'value': 1} // temporary
          }
        ]),
        'vertexShader': ShaderChunk.meshphysical_vert,
        'fragmentShader': ShaderChunk.meshphysical_frag
      },
      toon = {
        'uniforms': UniformsUtils.mergeUniforms([
          UniformsLib.common,
          UniformsLib.aomap,
          UniformsLib.lightmap,
          UniformsLib.emissivemap,
          UniformsLib.bumpmap,
          UniformsLib.normalmap,
          UniformsLib.displacementmap,
          UniformsLib.gradientmap,
          UniformsLib.fog,
          UniformsLib.lights,
          {
            'emissive': {'value': Color(0x000000)}
          }
        ]),
        'vertexShader': ShaderChunk.meshtoon_vert,
        'fragmentShader': ShaderChunk.meshtoon_frag
      },
      matcap = {
        'uniforms': UniformsUtils.mergeUniforms([
          UniformsLib.common,
          UniformsLib.bumpmap,
          UniformsLib.normalmap,
          UniformsLib.displacementmap,
          UniformsLib.fog,
          {
            'matcap': {'value': null}
          }
        ]),
        'vertexShader': ShaderChunk.meshmatcap_vert,
        'fragmentShader': ShaderChunk.meshmatcap_frag
      },
      points = {
        'uniforms': UniformsUtils.mergeUniforms([UniformsLib.points, UniformsLib.fog]),
        'vertexShader': ShaderChunk.points_vert,
        'fragmentShader': ShaderChunk.points_frag
      },
      dashed = {
        'uniforms': UniformsUtils.mergeUniforms([
          UniformsLib.common,
          UniformsLib.fog,
          {
            'scale': {'value': 1},
            'dashSize': {'value': 1},
            'totalSize': {'value': 2}
          }
        ]),
        'vertexShader': ShaderChunk.linedashed_vert,
        'fragmentShader': ShaderChunk.linedashed_frag
      },
      depth = {
        'uniforms': UniformsUtils.mergeUniforms([UniformsLib.common, UniformsLib.displacementmap]),
        'vertexShader': ShaderChunk.depth_vert,
        'fragmentShader': ShaderChunk.depth_frag
      };

  Map normal = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.common,
      UniformsLib.bumpmap,
      UniformsLib.normalmap,
      UniformsLib.displacementmap,
      {
        'opacity': {'value': 1.0}
      }
    ]),
    'vertexShader': ShaderChunk.meshnormal_vert,
    'fragmentShader': ShaderChunk.meshnormal_frag
  };

  Map sprite = {
    'uniforms': UniformsUtils.mergeUniforms([UniformsLib.sprite, UniformsLib.fog]),
    'vertexShader': ShaderChunk.sprite_vert,
    'fragmentShader': ShaderChunk.sprite_frag
  };

  Map background = {
    'uniforms': {
      'uvTransform': {'value': new Matrix3()},
      't2D': {'value': null},
    },
    'vertexShader': ShaderChunk.background_vert,
    'fragmentShader': ShaderChunk.background_frag
  };

  /* -------------------------------------------------------------------------
	//	Cube map shader
  ------------------------------------------------------------------------- */

  Map cube = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.envmap,
      {
        'opacity': {'value': 1.0}
      }
    ]),
    'vertexShader': ShaderChunk.cube_vert,
    'fragmentShader': ShaderChunk.cube_frag
  };

  Map equirect = {
    'uniforms': {
      'tEquirect': {'value': null},
    },
    'vertexShader': ShaderChunk.equirect_vert,
    'fragmentShader': ShaderChunk.equirect_frag
  };

  Map distanceRGBA = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.common,
      UniformsLib.displacementmap,
      {
        'referencePosition': {'value': Vector3()},
        'nearDistance': {'value': 1},
        'farDistance': {'value': 1000}
      }
    ]),
    'vertexShader': ShaderChunk.distanceRGBA_vert,
    'fragmentShader': ShaderChunk.distanceRGBA_frag
  };

  Map shadow = {
    'uniforms': UniformsUtils.mergeUniforms([
      UniformsLib.lights,
      UniformsLib.fog,
      {
        'color': {'value': new Color(0x00000)},
        'opacity': {'value': 1.0}
      },
    ]),
    'vertexShader': ShaderChunk.shadow_vert,
    'fragmentShader': ShaderChunk.shadow_frag
  };
}
