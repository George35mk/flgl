import 'package:flutter/material.dart';
import 'package:flgl_example/examples/example_1.dart';
import 'package:flgl_example/examples/example_2.dart';
import 'package:flgl_example/examples/example_3.dart';
import 'package:flgl_example/examples/example_4.dart';
import 'package:flgl_example/examples/example_5.dart';
import 'package:flgl_example/examples/example_6.dart';
import 'package:flgl_example/examples/example_7.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin examples'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ElevatedButton(
                child: const Text('Open example 1'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example1()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 2'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example2()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 3'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example3()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 4'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example4()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 5'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example5()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 6'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example6()),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Open example 7'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Example7()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
