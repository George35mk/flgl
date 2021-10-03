import 'package:flutter/material.dart';

class DrawingObjects extends StatefulWidget {
  const DrawingObjects({Key? key}) : super(key: key);

  @override
  _DrawingObjectsState createState() => _DrawingObjectsState();
}

class _DrawingObjectsState extends State<DrawingObjects> {
  final Map<int, Map<String, String>> _pages = {
    0: {
      "name": "Drawing a cube",
      "description": "Example of drawing a cube",
      "route": 'cube_example',
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
                Navigator.pushNamed(context, '/drawing_objects/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
