// class Flutter3DExamples {}

import 'package:flutter/material.dart';

class Flutter3DExamples extends StatefulWidget {
  const Flutter3DExamples({Key? key}) : super(key: key);

  @override
  _Flutter3DExamplesState createState() => _Flutter3DExamplesState();
}

class _Flutter3DExamplesState extends State<Flutter3DExamples> {
  final Map<int, Map<String, String>> _pages = {
    0: {
      "name": "flutter 3D triangle draw",
      "description": "Example of drawing a triangle with flutter 3D api",
      "route": 'triangle',
    },
    1: {
      "name": "flutter 3D plane draw",
      "description": "Example of drawing a plane with flutter 3D api",
      "route": 'plane',
    }
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
                Navigator.pushNamed(context, '/flutter3d_examples/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
