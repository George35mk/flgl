import 'package:flgl_example/examples/controls/controls_manager.dart';
import 'package:flgl_example/examples/controls/slider_row.dart';
import 'package:flutter/material.dart';

class GLControls extends StatefulWidget {
  final ControlsManager? controlsManager;
  final Function? onChange;
  const GLControls({Key? key, this.controlsManager, this.onChange}) : super(key: key);

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
          for (var item in widget.controlsManager!.controls.keys)
            SliderRow(
              name: widget.controlsManager!.controls[item]!.name,
              value: widget.controlsManager!.controls[item]!.value,
              min: widget.controlsManager!.controls[item]!.min,
              max: widget.controlsManager!.controls[item]!.max,
              onChange: (val) {
                setState(() {
                  widget.controlsManager!.controls[item]!.value = val;
                  widget.onChange!(widget.controlsManager!.controls[item]);
                });
              },
            )
        ],
      ),
    );
  }
}
