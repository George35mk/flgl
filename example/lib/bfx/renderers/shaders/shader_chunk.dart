// ignore_for_file: non_constant_identifier_names

import 'ShaderChunk/alphamap_fragment.glsl.dart';
import 'ShaderChunk/alphamap_pars_fragment.glsl.dart';
import 'ShaderChunk/alphatest_fragment.glsl.dart';
import 'ShaderChunk/alphatest_pars_fragment.glsl.dart';
import 'ShaderChunk/aomap_fragment.glsl.dart';
import 'ShaderChunk/aomap_pars_fragment.glsl.dart';
import 'ShaderChunk/begin_vertex.glsl.dart';
import 'ShaderChunk/beginnormal_vertex.glsl.dart';
import 'ShaderChunk/bsdfs.glsl.dart';
import 'ShaderChunk/bumpmap_pars_fragment.glsl.dart';
import 'ShaderChunk/clipping_planes_fragment.glsl.dart';
import 'ShaderChunk/clipping_planes_pars_fragment.glsl.dart';
import 'ShaderChunk/clipping_planes_pars_vertex.glsl.dart';
import 'ShaderChunk/clipping_planes_vertex.glsl.dart';
import 'ShaderChunk/color_fragment.glsl.dart';
import 'ShaderChunk/color_pars_fragment.glsl.dart';
import 'ShaderChunk/color_pars_vertex.glsl.dart';
import 'ShaderChunk/color_vertex.glsl.dart';
import 'ShaderChunk/common.glsl.dart';
import 'ShaderChunk/cube_uv_reflection_fragment.glsl.dart';
import 'ShaderChunk/defaultnormal_vertex.glsl.dart';
import 'ShaderChunk/displacementmap_pars_vertex.glsl.dart';
import 'ShaderChunk/displacementmap_vertex.glsl.dart';
import 'ShaderChunk/emissivemap_fragment.glsl.dart';
import 'ShaderChunk/emissivemap_pars_fragment.glsl.dart';
import 'ShaderChunk/encodings_fragment.glsl.dart';
import 'ShaderChunk/encodings_pars_fragment.glsl.dart';
import 'ShaderChunk/envmap_common_pars_fragment.glsl.dart';
import 'ShaderChunk/envmap_fragment.glsl.dart';
import 'ShaderChunk/envmap_pars_fragment.glsl.dart';
import 'ShaderChunk/envmap_pars_vertex.glsl.dart';
import 'ShaderChunk/envmap_physical_pars_fragment.glsl.dart';
import 'ShaderChunk/envmap_vertex.glsl.dart';
import 'ShaderChunk/fog_fragment.glsl.dart';
import 'ShaderChunk/fog_pars_fragment.glsl.dart';
import 'ShaderChunk/fog_pars_vertex.glsl.dart';
import 'ShaderChunk/fog_vertex.glsl.dart';
import 'ShaderChunk/gradientmap_pars_fragment.glsl.dart';
import 'ShaderChunk/lightmap_fragment.glsl.dart';
import 'ShaderChunk/lightmap_pars_fragment.glsl.dart';
import 'ShaderChunk/lights_fragment_begin.glsl.dart';
import 'ShaderChunk/lights_fragment_end.glsl.dart';
import 'ShaderChunk/lights_fragment_maps.glsl.dart';
import 'ShaderChunk/lights_lambert_vertex.glsl.dart';
import 'ShaderChunk/lights_pars_begin.glsl.dart';
import 'ShaderChunk/lights_phong_fragment.glsl.dart';
import 'ShaderChunk/lights_phong_pars_fragment.glsl.dart';
import 'ShaderChunk/lights_physical_fragment.glsl.dart';
import 'ShaderChunk/lights_physical_pars_fragment.glsl.dart';
import 'ShaderChunk/lights_toon_fragment.glsl.dart';
import 'ShaderChunk/lights_toon_pars_fragment.glsl.dart';
import 'ShaderChunk/logdepthbuf_fragment.glsl.dart';
import 'ShaderChunk/logdepthbuf_pars_fragment.glsl.dart';
import 'ShaderChunk/logdepthbuf_pars_vertex.glsl.dart';
import 'ShaderChunk/logdepthbuf_vertex.glsl.dart';
import 'ShaderChunk/map_fragment.glsl.dart';
import 'ShaderChunk/map_pars_fragment.glsl.dart';
import 'ShaderChunk/map_particle_fragment.glsl.dart';

class ShaderChunk {
  static String alphamap_fragment = alphamap_fragment_glsl;
  static String alphamap_pars_fragment = alphamap_pars_fragment_glsl;
  static String alphatest_fragment = alphatest_fragment_glsl;
  static String alphatest_pars_fragment = alphatest_pars_fragment_glsl;
  static String aomap_fragment = aomap_fragment_glsl;
  static String aomap_pars_fragment = aomap_pars_fragment_glsl;
  static String begin_vertex = begin_vertex_glsl;
  static String beginnormal_vertex = beginnormal_vertex_glsl;
  static String bsdfs = bsdfs_glsl;
  static String bumpmap_pars_fragment = bumpmap_pars_fragment_glsl;
  static String clipping_planes_fragment = clipping_planes_fragment_glsl;
  static String clipping_planes_pars_fragment = clipping_planes_pars_fragment_glsl;
  static String clipping_planes_pars_vertex = clipping_planes_pars_vertex_glsl;
  static String clipping_planes_vertex = clipping_planes_vertex_glsl;
  static String color_fragment = color_fragment_glsl;
  static String color_pars_fragment = color_pars_fragment_glsl;
  static String color_pars_vertex = color_pars_vertex_glsl;
  static String color_vertex = color_vertex_glsl;
  static String common = common_glsl;
  static String cube_uv_reflection_fragment = cube_uv_reflection_fragment_glsl;
  static String defaultnormal_vertex = defaultnormal_vertex_glsl;
  static String displacementmap_pars_vertex = displacementmap_pars_vertex_glsl;
  static String displacementmap_vertex = displacementmap_vertex_glsl;
  static String emissivemap_fragment = emissivemap_fragment_glsl;
  static String emissivemap_pars_fragment = emissivemap_pars_fragment_glsl;
  static String encodings_fragment = encodings_fragment_glsl;
  static String encodings_pars_fragment = encodings_pars_fragment_glsl;
  static String envmap_fragment = envmap_fragment_glsl;
  static String envmap_common_pars_fragment = envmap_common_pars_fragment_glsl;
  static String envmap_pars_fragment = envmap_pars_fragment_glsl;
  static String envmap_pars_vertex = envmap_pars_vertex_glsl;
  static String envmap_physical_pars_fragment = envmap_physical_pars_fragment_glsl;
  static String envmap_vertex = envmap_vertex_glsl;
  static String fog_vertex = fog_vertex_glsl;
  static String fog_pars_vertex = fog_pars_vertex_glsl;
  static String fog_fragment = fog_fragment_glsl;
  static String fog_pars_fragment = fog_pars_fragment_glsl;
  static String gradientmap_pars_fragment = gradientmap_pars_fragment_glsl;
  static String lightmap_fragment = lightmap_fragment_glsl;
  static String lightmap_pars_fragment = lightmap_pars_fragment_glsl;
  static String lights_lambert_vertex = lights_lambert_vertex_glsl;
  static String lights_pars_begin = lights_pars_begin_glsl;
  static String lights_toon_fragment = lights_toon_fragment_glsl;
  static String lights_toon_pars_fragment = lights_toon_pars_fragment_glsl;
  static String lights_phong_fragment = lights_phong_fragment_glsl;
  static String lights_phong_pars_fragment = lights_phong_pars_fragment_glsl;
  static String lights_physical_fragment = lights_physical_fragment_glsl;
  static String lights_physical_pars_fragment = lights_physical_pars_fragment_glsl;
  static String lights_fragment_begin = lights_fragment_begin_glsl;
  static String lights_fragment_maps = lights_fragment_maps_glsl;
  static String lights_fragment_end = lights_fragment_end_glsl;
  static String logdepthbuf_fragment = logdepthbuf_fragment_glsl;
  static String logdepthbuf_pars_fragment = logdepthbuf_pars_fragment_glsl;
  static String logdepthbuf_pars_vertex = logdepthbuf_pars_vertex_glsl;
  static String logdepthbuf_vertex = logdepthbuf_vertex_glsl;
  static String map_fragment = map_fragment_glsl;
  static String map_pars_fragment = map_pars_fragment_glsl;
  static String map_particle_fragment = map_particle_fragment_glsl;
  static String map_particle_pars_fragment = map_particle_pars_fragment_glsl; //
  static String metalnessmap_fragment = metalnessmap_fragment_glsl;
  static String metalnessmap_pars_fragment = metalnessmap_pars_fragment_glsl;
  static String morphnormal_vertex = morphnormal_vertex_glsl;
  static String morphtarget_pars_vertex = morphtarget_pars_vertex_glsl;
  static String morphtarget_vertex = morphtarget_vertex_glsl;
  static String normal_fragment_begin = normal_fragment_begin_glsl;
  static String normal_fragment_maps = normal_fragment_maps_glsl;
  static String normal_pars_fragment = normal_pars_fragment_glsl;
  static String normal_pars_vertex = normal_pars_vertex_glsl;
  static String normal_vertex = normal_vertex_glsl;
  static String normalmap_pars_fragment = normalmap_pars_fragment_glsl;
  static String clearcoat_normal_fragment_begin = clearcoat_normal_fragment_begin_glsl;
  static String clearcoat_normal_fragment_maps = clearcoat_normal_fragment_maps_glsl;
  static String clearcoat_pars_fragment = clearcoat_pars_fragment_glsl;
  static String output_fragment = output_fragment_glsl;
  static String packing = packing_glsl;
  static String premultiplied_alpha_fragment = premultiplied_alpha_fragment_glsl;
  static String project_vertex = project_vertex_glsl;
  static String dithering_fragment = dithering_fragment_glsl;
  static String dithering_pars_fragment = dithering_pars_fragment_glsl;
  static String roughnessmap_fragment = roughnessmap_fragment_glsl;
  static String roughnessmap_pars_fragment = roughnessmap_pars_fragment_glsl;
  static String shadowmap_pars_fragment = shadowmap_pars_fragment_glsl;
  static String shadowmap_pars_vertex = shadowmap_pars_vertex_glsl;
  static String shadowmap_vertex = shadowmap_vertex_glsl;
  static String shadowmask_pars_fragment = shadowmask_pars_fragment_glsl;
  static String skinbase_vertex = skinbase_vertex_glsl;
  static String skinning_pars_vertex = skinning_pars_vertex_glsl;
  static String skinning_vertex = skinning_vertex_glsl;
  static String skinnormal_vertex = skinnormal_vertex_glsl;
  static String specularmap_fragment = specularmap_fragment_glsl;
  static String specularmap_pars_fragment = specularmap_pars_fragment_glsl;
  static String tonemapping_fragment = tonemapping_fragment_glsl;
  static String tonemapping_pars_fragment = tonemapping_pars_fragment_glsl;
  static String transmission_fragment = transmission_fragment_glsl;
  static String transmission_pars_fragment = transmission_pars_fragment_glsl;
  static String uv_pars_fragment = uv_pars_fragment_glsl;
  static String uv_pars_vertex = uv_pars_vertex_glsl;
  static String uv_vertex = uv_vertex_glsl;
  static String uv2_pars_fragment = uv2_pars_fragment_glsl;
  static String uv2_pars_vertex = uv2_pars_vertex_glsl;
  static String uv2_vertex = uv2_vertex_glsl;
  static String worldpos_vertex = worldpos_vertex_glsl;

  static String background_vert = background.vertex;
  static String background_frag = background.fragment;
  static String cube_vert = cube.vertex;
  static String cube_frag = cube.fragment;
  static String depth_vert = depth.vertex;
  static String depth_frag = depth.fragment;
  static String distanceRGBA_vert = distanceRGBA.vertex;
  static String distanceRGBA_frag = distanceRGBA.fragment;
  static String equirect_vert = equirect.vertex;
  static String equirect_frag = equirect.fragment;
  static String linedashed_vert = linedashed.vertex;
  static String linedashed_frag = linedashed.fragment;
  static String meshbasic_vert = meshbasic.vertex;
  static String meshbasic_frag = meshbasic.fragment;
  static String meshlambert_vert = meshlambert.vertex;
  static String meshlambert_frag = meshlambert.fragment;
  static String meshmatcap_vert = meshmatcap.vertex;
  static String meshmatcap_frag = meshmatcap.fragment;
  static String meshnormal_vert = meshnormal.vertex;
  static String meshnormal_frag = meshnormal.fragment;
  static String meshphong_vert = meshphong.vertex;
  static String meshphong_frag = meshphong.fragment;
  static String meshphysical_vert = meshphysical.vertex;
  static String meshphysical_frag = meshphysical.fragment;
  static String meshtoon_vert = meshtoon.vertex;
  static String meshtoon_frag = meshtoon.fragment;
  static String points_vert = points.vertex;
  static String points_frag = points.fragment;
  static String shadow_vert = shadow.vertex;
  static String shadow_frag = shadow.fragment;
  static String sprite_vert = sprite.vertex;
  static String sprite_frag = sprite.fragment;
}
