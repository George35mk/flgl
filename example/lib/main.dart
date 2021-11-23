import 'package:flgl_example/examples/geometries/flutter3d_box.dart';
import 'package:flgl_example/examples/geometries/flutter3d_cone.dart';
import 'package:flgl_example/examples/geometries/flutter3d_cylinder.dart';
import 'package:flgl_example/examples/geometries/flutter3d_triangle.dart';
import 'package:flgl_example/examples/neon_examples/neon_batch_rendering_colors_example.dart';
import 'package:flgl_example/examples/neon_examples/neon_batch_rendering_textures_example.dart';
import 'package:flgl_example/examples/neon_examples/neon_examples.dart';
import 'package:flgl_example/examples/neon_examples/neon_quad_texture_example.dart';
import 'package:flgl_example/examples/neon_examples/neon_texture_example.dart';
import 'package:flgl_example/examples/neon_examples/neon_quad_example.dart';
import 'package:flgl_example/examples/textures/flutter3d_assets_texture.dart';
import 'package:flgl_example/examples/edge_geometry/flutter3d_box_edges_example.dart';
import 'package:flgl_example/examples/flutter3d_examples.dart';
import 'package:flgl_example/examples/geometries/flutter3d_multiple_geometries.dart';
import 'package:flgl_example/examples/geometries/flutter3d_plane.dart';
import 'package:flgl_example/examples/textures/flutter3d_plane_with_texture.dart';
import 'package:flgl_example/examples/geometries/flutter3d_sphere.dart';
import 'package:flutter/material.dart';
import 'package:flgl_example/home.dart';

import 'examples/neon_examples/neon_quad_example_2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Named Routes Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),

        // flutter3D examples
        '/flutter3d_examples': (context) => const Flutter3DExamples(),
        '/flutter3d_examples/triangle': (context) => const Flutter3DTriangle(),
        '/flutter3d_examples/plane': (context) => const Flutter3DPlane(),
        '/flutter3d_examples/box': (context) => const Flutter3DBox(),
        '/flutter3d_examples/sphere': (context) => const Flutter3DSphere(),
        '/flutter3d_examples/cone': (context) => const Flutter3DCone(),
        '/flutter3d_examples/cylinder': (context) => const Flutter3DCylinder(),
        '/flutter3d_examples/multiple_geometries': (context) => const Flutter3DMultipleGeometries(),
        '/flutter3d_examples/plane_geometry_with_texture': (context) => const Flutter3DPlaneWithTexture(),
        '/flutter3d_examples/plane_assets_texture': (context) => const Flutter3DAssetsTexture(),
        '/flutter3d_examples/box_edges_example': (context) => const Flutter3DBoxEdgesExample(),

        // Examples using the Neon API
        '/neon': (context) => const NeonExamples(),
        '/neon/quad': (context) => const NeonQuadExample(),
        '/neon/quad2': (context) => const NeonQuadExample2(),
        '/neon/quad_texture': (context) => const NeonQuadTextureExample(),
        '/neon/texture': (context) => const NeonTextureExample(),
        '/neon/batch_rendering_colors': (context) => const NeonBatchRenderingColorsExample(),
        '/neon/batch_rendering_textures': (context) => const NeonBatchRenderingTexturesExample(),
      },
    );
  }
}
