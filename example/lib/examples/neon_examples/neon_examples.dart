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
      "route": 'triangle',
    },
    1: {
      "name": "flutter 3D texture example",
      "description": "Example of drawing a triangle using flutter 3D",
      "route": 'texture',
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
