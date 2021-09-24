import 'package:flutter/material.dart';

class ExamplesPage2d extends StatefulWidget {
  const ExamplesPage2d({Key? key}) : super(key: key);

  @override
  _ExamplesPage2dState createState() => _ExamplesPage2dState();
}

class _ExamplesPage2dState extends State<ExamplesPage2d> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Example 9", "description": "OpenGLES: 2D Translation", 'route': 'example_9'},
    '2': {"name": "Example 10", "description": "OpenGLES: 2D Rotation", 'route': 'example_10'},
    '3': {"name": "Example 11", "description": "OpenGLES: 2D Scale", 'route': 'example_11'},
    '4': {"name": "Example 12", "description": "OpenGLES: 2D Matrices", 'route': 'example_12'},
    '5': {
      "name": "Example 13",
      "description": "OpenGLES: 2D Matrices reducing complexity",
      'route': 'example_13'
    },
    '6': {
      "name": "Example 14",
      "description": "OpenGLES: 2D Matrices Improving the matrix",
      'route': 'example_14'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2D examples'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView.separated(
          itemCount: _pages.keys.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
          itemBuilder: (BuildContext context, int index) {
            String key = _pages.keys.elementAt(index);
            var name = _pages[key]['name'];
            var route = _pages[key]['route'];
            var description = _pages[key]['description'];

            return ListTile(
              title: Text(name),
              subtitle: Text(description),
              contentPadding: const EdgeInsets.all(5.0),
              onTap: () {
                Navigator.pushNamed(context, '/2d/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
