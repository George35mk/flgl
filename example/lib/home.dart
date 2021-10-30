import 'package:flgl_example/examples/2D/examples_page_2d.dart';
import 'package:flgl_example/examples/3D/examples_page_3d.dart';
import 'package:flgl_example/examples/Fundamentals/examples_page_fundamentals.dart';
import 'package:flgl_example/examples/Lighting/lighting_examples_page.dart';
import 'package:flgl_example/examples/Structure_and_Organization/structure_and_organization.dart';
import 'package:flgl_example/examples/drawing_objects/drawing_objects.dart';
import 'package:flutter/material.dart';

import 'examples/flutter3d_examples/flutter3d_examples.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, dynamic> _pages = {
    '1': {
      "name": "Fundamentals",
      "description": "OpenGLES: Fundamentals",
      "page": const ExamplesPageFundamentals(),
    },
    '2': {
      "name": "2D",
      "description": "OpenGLES: 2D examples",
      "page": const ExamplesPage2d(),
    },
    '3': {
      "name": "3D",
      "description": "OpenGLES: 3D examples",
      "page": const ExamplesPage3d(),
    },
    '4': {
      "name": "Lighting",
      "description": "OpenGLES: Lighting Examples",
      "page": const LightingExamplesPage(),
    },
    '5': {
      "name": "Structure And Organization",
      "description": "OpenGLES: Structure And Organization",
      "page": const StructureAndOrganization()
    },
    '6': {
      "name": "Drawing Objects",
      "description": "OpenGLES: Drawing Objects",
      "page": const DrawingObjects(),
    },
    '7': {
      "name": "Flutter3D Examples",
      "description": "OpenGLES: Drawing Objects with Flutter3D",
      "page": const Flutter3DExamples(),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin examples'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView.separated(
          itemCount: _pages.keys.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
          itemBuilder: (BuildContext context, int index) {
            String key = _pages.keys.elementAt(index);
            var name = _pages[key]['name'];
            var page = _pages[key]['page'];
            var description = _pages[key]['description'];

            return ListTile(
              title: Text(name),
              subtitle: Text(description),
              contentPadding: const EdgeInsets.all(5.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Widget examplesCard() {
  return Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const ListTile(
          leading: Icon(Icons.album),
          title: Text('The Enchanted Nightingale'),
          subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text('BUY TICKETS'),
              onPressed: () {/* ... */},
            ),
            const SizedBox(width: 8),
            TextButton(
              child: const Text('LISTEN'),
              onPressed: () {/* ... */},
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    ),
  );
}
