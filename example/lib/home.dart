import 'package:flgl_example/examples/neon_examples/neon_examples.dart';
import 'package:flutter/material.dart';
import 'examples/flutter3d_examples.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<int, dynamic> _pages = {
    0: {
      "name": "Flutter3D Examples",
      "description": "OpenGLES: Drawing Objects with Flutter3D",
      "page": const Flutter3DExamples(),
    },
    1: {
      "name": "Neon Examples",
      "description": "Examples using the new API (Neon)",
      "page": const NeonExamples(),
    }, // dont forget the coma, i get some errors because of that.
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
            int key = _pages.keys.elementAt(index);
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
