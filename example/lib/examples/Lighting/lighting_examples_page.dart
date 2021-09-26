import 'package:flutter/material.dart';

class LightingExamplesPage extends StatefulWidget {
  const LightingExamplesPage({Key? key}) : super(key: key);

  @override
  _LightingExamplesPageState createState() => _LightingExamplesPageState();
}

class _LightingExamplesPageState extends State<LightingExamplesPage> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Lighting 1", "description": "OpenGLES: 3D Directional Lighting 1", "route": 'lighting_1'},
    '2': {"name": "Lighting 2", "description": "OpenGLES: 3D Directional Lighting 2", "route": 'lighting_2'},
    '3': {"name": "Lighting 2", "description": "OpenGLES: 3D Directional Lighting 3", "route": 'lighting_3'},
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
            String key = _pages.keys.elementAt(index);
            var name = _pages[key]['name'];
            var route = _pages[key]['route'];
            var description = _pages[key]['description'];

            return ListTile(
              title: Text(name),
              subtitle: Text(description),
              contentPadding: const EdgeInsets.all(5.0),
              onTap: () {
                Navigator.pushNamed(context, '/lighting/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
