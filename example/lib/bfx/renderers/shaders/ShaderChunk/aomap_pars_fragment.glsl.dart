const aomap_pars_fragment_glsl = '''
#ifdef USE_AOMAP

	uniform sampler2D aoMap;
	uniform float aoMapIntensity;

#endif
''';
