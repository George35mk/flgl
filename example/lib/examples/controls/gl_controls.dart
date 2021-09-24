import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/controls/slider_row.dart';
import 'package:flutter/material.dart';

class GLControls extends StatefulWidget {
  final TransformControlsManager? transformControlsManager;
  final Function? onChange;
  const GLControls({Key? key, this.transformControlsManager, this.onChange}) : super(key: key);

  @override
  _GLControlsState createState() => _GLControlsState();
}

class _GLControlsState extends State<GLControls> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          for (var item in widget.transformControlsManager!.controls.keys)
            SliderRow(
              name: widget.transformControlsManager!.controls[item]!.name,
              value: widget.transformControlsManager!.controls[item]!.value,
              min: widget.transformControlsManager!.controls[item]!.min,
              max: widget.transformControlsManager!.controls[item]!.max,
              onChange: (val) {
                setState(() {
                  widget.transformControlsManager!.controls[item]!.value = val;
                  widget.onChange!(widget.transformControlsManager!.controls[item]);
                });
              },
            )
        ],
      ),
    );
  }
}
