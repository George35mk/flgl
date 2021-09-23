import 'package:flutter/material.dart';
import 'package:flgl_example/examples/Fundamentals/example_1.dart';
import 'package:flgl_example/examples/Fundamentals/example_2.dart';
import 'package:flgl_example/examples/Fundamentals/example_3.dart';
import 'package:flgl_example/examples/Fundamentals/example_4.dart';
import 'package:flgl_example/examples/Fundamentals/example_5.dart';
import 'package:flgl_example/examples/Fundamentals/example_6.dart';
import 'package:flgl_example/examples/Fundamentals/example_7.dart';
import 'package:flgl_example/examples/Fundamentals/example_8.dart';
import 'package:flgl_example/examples/2D/example_9.dart';
import 'package:flgl_example/examples/2D/example_10.dart';
import 'package:flgl_example/examples/2D/example_11.dart';
import 'package:flgl_example/examples/2D/example_12.dart';
import 'package:flgl_example/examples/2D/example_13.dart';
import 'package:flgl_example/examples/2D/example_14.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Example 1", "description": "OpenGLES: Hello triangle", "page": const Example1()},
    '2': {"name": "Example 2", "description": "OpenGLES: ", 'page': const Example2()},
    '3': {"name": "Example 3", "description": "OpenGLES: ", 'page': const Example3()},
    '4': {"name": "Example 4", "description": "OpenGLES: ", 'page': const Example4()},
    '5': {"name": "Example 5", "description": "OpenGLES: ", 'page': const Example5()},
    '6': {"name": "Example 6", "description": "OpenGLES: ", 'page': const Example6()},
    '7': {"name": "Example 7", "description": "OpenGLES: ", 'page': const Example7()},
    '8': {"name": "Example 8", "description": "OpenGLES: ", 'page': const Example8()},
    '9': {"name": "Example 9", "description": "OpenGLES: 2D Translation", 'page': const Example9()},
    '10': {"name": "Example 10", "description": "OpenGLES: 2D Rotation", 'page': const Example10()},
    '11': {"name": "Example 11", "description": "OpenGLES: 2D Scale", 'page': const Example11()},
    '12': {"name": "Example 12", "description": "OpenGLES: 2D Matrices", 'page': const Example12()},
    '13': {
      "name": "Example 13",
      "description": "OpenGLES: 2D Matrices reducing complexity",
      'page': const Example13()
    },
    '14': {
      "name": "Example 14",
      "description": "OpenGLES: 2D Matrices Improving the matrix",
      'page': const Example14()
    },
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin examples'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
            itemCount: _pages.keys.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (BuildContext context, int index) {
              String key = _pages.keys.elementAt(index);
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
      ),
    );
  }
}
