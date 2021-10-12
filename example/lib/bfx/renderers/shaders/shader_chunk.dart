import 'ShaderChunk/alphamap_fragment.glsl.dart';
import 'ShaderChunk/alphamap_pars_fragment.glsl.dart';
import 'ShaderChunk/alphatest_fragment.glsl.dart';
import 'ShaderChunk/alphatest_pars_fragment.glsl.dart';
import 'ShaderChunk/aomap_fragment.glsl.dart';

class ShaderChunk {
  static String alphamapFragment = alphamap_fragment;
  static String alphamapParsFragment = alphamap_pars_fragment;
  static String alphatestFragment = alphatest_fragment;
  static String alphatestParsFragment = alphatest_pars_fragment;
  static String aomapFragment = aomap_fragment;
  static String aomapParsFragment = aomap_pars_fragment;
  static String beginVertex = begin_vertex;
  static String beginnormalVertex = beginnormal_vertex;
  static String bsdfs = bsdfs;
}
