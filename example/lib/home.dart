import 'package:flutter/material.dart';
import 'package:flgl_example/examples/example_1.dart';
import 'package:flgl_example/examples/example_2.dart';
import 'package:flgl_example/examples/example_3.dart';
import 'package:flgl_example/examples/example_4.dart';
import 'package:flgl_example/examples/example_5.dart';
import 'package:flgl_example/examples/example_6.dart';
import 'package:flgl_example/examples/example_7.dart';
import 'package:flgl_example/examples/example_8.dart';
import 'package:flgl_example/examples/example_9.dart';
import 'package:flgl_example/examples/example_10.dart';
import 'package:flgl_example/examples/example_11.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, dynamic> _pages = {
    '1': {"name": "Open example 1", "page": const Example1()},
    '2': {"name": "Open example 2", 'page': const Example2()},
    '3': {"name": "Open example 3", 'page': const Example3()},
    '4': {"name": "Open example 4", 'page': const Example4()},
    '5': {"name": "Open example 5", 'page': const Example5()},
    '6': {"name": "Open example 6", 'page': const Example6()},
    '7': {"name": "Open example 7", 'page': const Example7()},
    '8': {"name": "Open example 8", 'page': const Example8()},
    '9': {"name": "Open example 9 (2D Translation)", 'page': const Example9()},
    '10': {"name": "Open example 10 (2D Rotation)", 'page': const Example10()},
    '11': {"name": "Open example 11 (2D Scale)", 'page': const Example11()},
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
            itemCount: 10,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
            itemBuilder: (BuildContext context, int index) {
              String key = _pages.keys.elementAt(index);
              var name = _pages[key]['name'];
              var page = _pages[key]['page'];

              return ListTile(
                title: Text(name),
                subtitle: const Text('OpenGLES'),
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
