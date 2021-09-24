import 'package:flutter/material.dart';

class ExamplesPageFundamentals extends StatefulWidget {
  const ExamplesPageFundamentals({Key? key}) : super(key: key);

  @override
  _ExamplesPageFundamentalsState createState() => _ExamplesPageFundamentalsState();
}

class _ExamplesPageFundamentalsState extends State<ExamplesPageFundamentals> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Example 1", "description": "OpenGLES: Hello triangle", "route": 'example_1'},
    '2': {"name": "Example 2", "description": "OpenGLES: ", 'route': 'example_2'},
    '3': {"name": "Example 3", "description": "OpenGLES: ", 'route': 'example_3'},
    '4': {"name": "Example 4", "description": "OpenGLES: ", 'route': 'example_4'},
    '5': {"name": "Example 5", "description": "OpenGLES: ", 'route': 'example_5'},
    '6': {"name": "Example 6", "description": "OpenGLES: ", 'route': 'example_6'},
    '7': {"name": "Example 7", "description": "OpenGLES: ", 'route': 'example_7'},
    '8': {"name": "Example 8", "description": "OpenGLES: ", 'route': 'example_8'},
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
                Navigator.pushNamed(context, '/fundamentals/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
