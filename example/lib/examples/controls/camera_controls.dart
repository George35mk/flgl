import 'package:flutter/material.dart';
import 'package:flgl/flgl_3d.dart';

import 'slider_row.dart';

class CameraControls extends StatefulWidget {
  final Camera camera;

  const CameraControls({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraControlsState createState() => _CameraControlsState();
}

class _CameraControlsState extends State<CameraControls> {
  Map<String, dynamic> controls = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Camera controls'),
            const SizedBox(height: 10),
            CameraControl(
              camera: widget.camera,
              controlName: 'position',
              attr: widget.camera.position,
              min: -500,
              max: 500,
            ),
            const SizedBox(height: 10),
            CameraControl(
              camera: widget.camera,
              controlName: 'target',
              attr: widget.camera.target,
              min: -500,
              max: 500,
            ),
            const SizedBox(height: 10),
            CameraControl(
              camera: widget.camera,
              controlName: 'up',
              attr: widget.camera.up,
              min: 0,
              max: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class CameraControl extends StatefulWidget {
  final Camera camera;
  final String controlName;
  final Vector3 attr;
  final double min;
  final double max;

  const CameraControl({
    Key? key,
    required this.camera,
    required this.controlName,
    required this.attr,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  _CameraControlState createState() => _CameraControlState();
}

class _CameraControlState extends State<CameraControl> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.controlName),
          SizedBox(
            child: Column(
              children: [
                SliderRow(
                  name: "x:",
                  value: widget.attr.x,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.x = val;
                      widget.camera.updateCameraMatrix();
                    });
                  },
                ),
                SliderRow(
                  name: "y:",
                  value: widget.attr.y,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.y = val;
                      widget.camera.updateCameraMatrix();
                    });
                  },
                ),
                SliderRow(
                  name: "z:",
                  value: widget.attr.z,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.z = val;
                      widget.camera.updateCameraMatrix();
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
