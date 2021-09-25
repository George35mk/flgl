import 'package:flgl_example/examples/2D/examples_page_2d.dart';
import 'package:flgl_example/examples/3D/examples_page_3d.dart';
import 'package:flgl_example/examples/Fundamentals/examples_page_fundamentals.dart';
import 'package:flgl_example/home.dart';
import 'package:flutter/material.dart';

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
      title: 'Named Routes Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/fundamentals': (context) => const ExamplesPageFundamentals(),
        '/fundamentals/example_1': (context) => const Example1(),
        '/fundamentals/example_2': (context) => const Example2(),
        '/fundamentals/example_3': (context) => const Example3(),
        '/fundamentals/example_4': (context) => const Example4(),
        '/fundamentals/example_5': (context) => const Example5(),
        '/fundamentals/example_6': (context) => const Example6(),
        '/fundamentals/example_7': (context) => const Example7(),
        '/fundamentals/example_8': (context) => const Example8(),
        '/2d': (context) => const ExamplesPage2d(),
        '/2d/example_9': (context) => const Example9(),
        '/2d/example_10': (context) => const Example10(),
        '/2d/example_11': (context) => const Example11(),
        '/2d/example_12': (context) => const Example12(),
        '/2d/example_13': (context) => const Example13(),
        '/2d/example_14': (context) => const Example14(),
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
      },
    );
  }
}
