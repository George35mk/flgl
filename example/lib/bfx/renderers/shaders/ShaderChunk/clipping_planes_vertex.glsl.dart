const clipping_planes_vertex_glsl = '''
#if NUM_CLIPPING_PLANES > 0

	vClipPosition = - mvPosition.xyz;

#endif
''';
