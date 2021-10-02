import 'package:flutter/material.dart';

class StructureAndOrganization extends StatefulWidget {
  const StructureAndOrganization({Key? key}) : super(key: key);

  @override
  _StructureAndOrganizationState createState() => _StructureAndOrganizationState();
}

class _StructureAndOrganizationState extends State<StructureAndOrganization> {
  final Map<String, dynamic> _pages = {
    '1': {
      "name": "Less Code, More Fun 1",
      "description": "Example of using Less Code, More Fun",
      "route": 'less_code_more_fun_1',
    },
    '2': {
      "name": "Drawing Multiple Things 1",
      "description": "Example of Drawing Multiple Things 1",
      "route": 'drawing_multiple_things_1',
    },
    '3': {
      "name": "Drawing Multiple Things 2",
      "description": "Example of Drawing Multiple Things 2",
      "route": 'drawing_multiple_things_2',
    },
    '4': {
      "name": "Scene graph 1",
      "description": "Example of Scene graph 1",
      "route": 'scene_graph_1',
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
            String key = _pages.keys.elementAt(index);
            var name = _pages[key]['name'];
            var route = _pages[key]['route'];
            var description = _pages[key]['description'];

            return ListTile(
              title: Text(name),
              subtitle: Text(description),
              contentPadding: const EdgeInsets.all(5.0),
              onTap: () {
                Navigator.pushNamed(context, '/structure_and_organization/$route');
              },
            );
          },
        ),
      ),
    );
  }
}
