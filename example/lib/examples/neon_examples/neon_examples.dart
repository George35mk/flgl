import 'package:flutter/material.dart';

class NeonExamples extends StatefulWidget {
  const NeonExamples({Key? key}) : super(key: key);

  @override
  _NeonExamplesState createState() => _NeonExamplesState();
}

class _NeonExamplesState extends State<NeonExamples> {
  final Map<int, Map<String, String>> _pages = {
    0: {
      "name": "flutter 3D triangle geometry",
      "description": "Example of drawing a triangle using flutter 3D",
      "route": 'quad',
    },
    1: {
      "name": "neon texture example",
      "description": "Example of drawing a triangle using flutter 3D",
      "route": 'texture',
    },
    2: {
      "name": "batch rendering colors example",
      "description": "Example of drawing a triangle using flutter 3D",
      "route": 'batch_rendering_colors',
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
