const fog_vertex_glsl = '''
#ifdef USE_FOG

	vFogDepth = - mvPosition.z;

#endif
''';
