import 'package:flutter/material.dart';

class ExamplesPage3d extends StatefulWidget {
  const ExamplesPage3d({Key? key}) : super(key: key);

  @override
  _ExamplesPage3dState createState() => _ExamplesPage3dState();
}

class _ExamplesPage3dState extends State<ExamplesPage3d> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Example 15", "description": "OpenGLES: Orthographic 3D", 'route': 'example_15'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D examples'),
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
                Navigator.pushNamed(context, '/3d/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
