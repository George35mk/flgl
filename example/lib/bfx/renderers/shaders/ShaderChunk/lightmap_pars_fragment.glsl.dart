const lightmap_pars_fragment_glsl = '''
#ifdef USE_LIGHTMAP

	uniform sampler2D lightMap;
	uniform float lightMapIntensity;

#endif
''';
