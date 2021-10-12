const alphatest_fragment_glsl = '''
#ifdef USE_ALPHATEST

	if ( diffuseColor.a < alphaTest ) discard;

#endif
''';
