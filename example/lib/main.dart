import 'package:flgl_example/examples/flutter3d_examples/flutter3d_box.dart';
import 'package:flgl_example/examples/flutter3d_examples/flutter3d_examples.dart';
import 'package:flgl_example/examples/flutter3d_examples/flutter3d_plane.dart';
import 'package:flgl_example/examples/flutter3d_examples/flutter3d_sphere.dart';
import 'package:flutter/material.dart';
import 'package:flgl_example/home.dart';
import 'package:flgl_example/examples/Fundamentals/examples_page_fundamentals.dart';
import 'package:flgl_example/examples/2D/examples_page_2d.dart';
import 'package:flgl_example/examples/3D/examples_page_3d.dart';
import 'package:flgl_example/examples/Lighting/lighting_examples_page.dart';
import 'package:flgl_example/examples/Structure_and_Organization/structure_and_organization.dart';
import 'package:flgl_example/examples/drawing_objects/drawing_objects.dart';

import 'examples/Fundamentals/example_1.dart';
import 'examples/Fundamentals/example_2.dart';
import 'examples/Fundamentals/example_3.dart';
import 'examples/Fundamentals/example_4.dart';
import 'examples/Fundamentals/example_5.dart';
import 'examples/Fundamentals/example_6.dart';
import 'examples/Fundamentals/example_7.dart';
import 'examples/Fundamentals/example_8.dart';

import 'examples/2D/example_9.dart';
import 'examples/2D/example_10.dart';
import 'examples/2D/example_11.dart';
import 'examples/2D/example_12.dart';
import 'examples/2D/example_13.dart';
import 'examples/2D/example_14.dart';

import 'examples/3D/example_15.dart';
import 'examples/3D/example_16.dart';
import 'examples/3D/example_17.dart';
import 'examples/3D/example_18.dart';
import 'examples/3D/example_19.dart';
import 'examples/3D/example_20.dart';
import 'examples/3D/example_21.dart';
import 'examples/3D/example_22.dart';
import 'examples/3D/example_23.dart';
import 'examples/3D/example_24.dart';
import 'examples/3D/example_25.dart';
import 'examples/3D/example_26.dart';

import 'examples/Lighting/directional_lighting_1.dart';
import 'examples/Lighting/directional_lighting_2.dart';
import 'examples/Lighting/directional_lighting_3.dart';
import 'examples/Lighting/point_light_1.dart';
import 'examples/Lighting/point_light_2.dart';
import 'examples/Lighting/point_light_3.dart';
import 'examples/Lighting/point_light_4.dart';
import 'examples/Lighting/spot_lighting_1.dart';
import 'examples/Lighting/spot_lighting_2.dart';

import 'examples/Structure_and_Organization/less_code_more_fun_1.dart';
import 'examples/Structure_and_Organization/drawing_multiple_things_1.dart';
import 'examples/Structure_and_Organization/drawing_multiple_things_2.dart';
import 'examples/Structure_and_Organization/scene_graph_1.dart';
import 'examples/Structure_and_Organization/scene_graph_2.dart';
import 'examples/Structure_and_Organization/scene_graph_3.dart';
import 'examples/Structure_and_Organization/scene_graph_4.dart';

import 'package:flgl_example/examples/drawing_objects/cube_example.dart';

import 'examples/flutter3d_examples/flutter3d_cone.dart';
import 'examples/flutter3d_examples/flutter3d_triangle.dart';

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

        // fundamentals
        '/fundamentals': (context) => const ExamplesPageFundamentals(),
        '/fundamentals/example_1': (context) => const Example1(),
        '/fundamentals/example_2': (context) => const Example2(),
        '/fundamentals/example_3': (context) => const Example3(),
        '/fundamentals/example_4': (context) => const Example4(),
        '/fundamentals/example_5': (context) => const Example5(),
        '/fundamentals/example_6': (context) => const Example6(),
        '/fundamentals/example_7': (context) => const Example7(),
        '/fundamentals/example_8': (context) => const Example8(),

        // 2d
        '/2d': (context) => const ExamplesPage2d(),
        '/2d/example_9': (context) => const Example9(),
        '/2d/example_10': (context) => const Example10(),
        '/2d/example_11': (context) => const Example11(),
        '/2d/example_12': (context) => const Example12(),
        '/2d/example_13': (context) => const Example13(),
        '/2d/example_14': (context) => const Example14(),

        // 3d
        '/3d': (context) => const ExamplesPage3d(),
        '/3d/example_15': (context) => const Example15(),
        '/3d/example_16': (context) => const Example16(),
        '/3d/example_17': (context) => const Example17(),
        '/3d/example_18': (context) => const Example18(),
        '/3d/example_19': (context) => const Example19(),
        '/3d/example_20': (context) => const Example20(),
        '/3d/example_21': (context) => const Example21(),
        '/3d/example_22': (context) => const Example22(),
        '/3d/example_23': (context) => const Example23(),
        '/3d/example_24': (context) => const Example24(),
        '/3d/example_25': (context) => const Example25(),
        '/3d/example_26': (context) => const Example26(),

        // lighting
        '/lighting': (context) => const LightingExamplesPage(),
        '/lighting/directional_lighting_1': (context) => const DirectionalLighting1(),
        '/lighting/directional_lighting_2': (context) => const DirectionalLighting2(),
        '/lighting/directional_lighting_3': (context) => const DirectionalLighting3(),
        '/lighting/point_light_1': (context) => const PointLight1(),
        '/lighting/point_light_2': (context) => const PointLight2(),
        '/lighting/point_light_3': (context) => const PointLight3(),
        '/lighting/point_light_4': (context) => const PointLight4(),
        '/lighting/spot_light_1': (context) => const SpotLight1(),
        '/lighting/spot_light_2': (context) => const SpotLight2(),

        // structure_and_organization
        '/structure_and_organization': (context) => const StructureAndOrganization(),
        '/structure_and_organization/less_code_more_fun_1': (context) => const LessCodeMoreFun1(),
        '/structure_and_organization/drawing_multiple_things_1': (context) => const DrawingMultipleThings1(),
        '/structure_and_organization/drawing_multiple_things_2': (context) => const DrawingMultipleThings2(),
        '/structure_and_organization/scene_graph_1': (context) => const SceneGraph1(),
        '/structure_and_organization/scene_graph_2': (context) => const SceneGraph2(),
        '/structure_and_organization/scene_graph_3': (context) => const SceneGraph3(),
        '/structure_and_organization/scene_graph_4': (context) => const SceneGraph4(),

        // drawing_objects
        '/drawing_objects': (context) => const DrawingObjects(),
        '/drawing_objects/cube_example': (context) => const CubeExample(),

        // flutter3D examples
        '/flutter3d_examples': (context) => const Flutter3DExamples(),
        '/flutter3d_examples/triangle': (context) => const Flutter3DTriangle(),
        '/flutter3d_examples/plane': (context) => const Flutter3DPlane(),
        '/flutter3d_examples/box': (context) => const Flutter3DBox(),
        '/flutter3d_examples/sphere': (context) => const Flutter3DSphere(),
        '/flutter3d_examples/cone': (context) => const Flutter3DCone(),
      },
    );
  }
}
