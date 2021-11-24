import 'package:flutter/material.dart';

class NeonExamples extends StatefulWidget {
  const NeonExamples({Key? key}) : super(key: key);

  @override
  _NeonExamplesState createState() => _NeonExamplesState();
}

class _NeonExamplesState extends State<NeonExamples> {
  final Map<int, Map<String, String>> _pages = {
    0: {
      "name": "Neon quad example",
      "description": "Quad example with Neon",
      "route": 'quad',
    },
    1: {
      "name": "Neon texture example",
      "description": "Texture example with Neon",
      "route": 'texture',
    },
    2: {
      "name": "batch rendering colors example",
      "description": "batch rendering colors example with Neon",
      "route": 'batch_rendering_colors',
    },
    3: {
      "name": "batch rendering textures example",
      "description": "batch rendering textures example with Neon",
      "route": 'batch_rendering_textures',
    },
    4: {
      "name": "Neon quad example 2",
      "description": "Neon quad example 2",
      "route": 'quad2',
    },
    5: {
      "name": "Neon quad texture",
      "description": "Neon quad texture example",
      "route": 'quad_texture',
    },
    6: {
      "name": "Neon cube example",
      "description": "Neon cube example",
      "route": 'cube',
    },
    7: {
      "name": "Neon sphere example",
      "description": "Neon sphere example",
      "route": 'sphere',
    },
    8: {
      "name": "Neon cylinder example",
      "description": "Neon cylinder example",
      "route": 'cylinder',
    },
    9: {
      "name": "Neon cone example",
      "description": "Neon cone example",
      "route": 'cone',
    },
    10: {
      "name": "Neon scene example",
      "description": "Neon scene example",
      "route": 'scene',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundamentals examples'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView.separated(
          itemCount: _pages.keys.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
          itemBuilder: (BuildContext context, int index) {
            int key = _pages.keys.elementAt(index);
            var name = _pages[key]!['name'];
            var route = _pages[key]!['route'];
            var description = _pages[key]!['description'];

            return ListTile(
              title: Text(name!),
              subtitle: Text(description!),
              contentPadding: const EdgeInsets.all(5.0),
              onTap: () {
                Navigator.pushNamed(context, '/neon/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
