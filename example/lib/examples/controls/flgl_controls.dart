import 'package:flgl/flgl_3d.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flgl_example/examples/controls/slider_row.dart';
import 'package:flutter/material.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'camera_controls.dart';

class FLGLControls extends StatefulWidget {
  final Scene scene;
  final Camera camera;
  final Function? onChange;
  final TransformControlsManager? transformControlsManager;

  const FLGLControls({
    Key? key,
    this.transformControlsManager,
    this.onChange,
    required this.camera,
    required this.scene,
  }) : super(key: key);

  @override
  _FLGLControlsState createState() => _FLGLControlsState();
}

class _FLGLControlsState extends State<FLGLControls> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: Colors.black,
        width: 200,
        height: 600,
        padding: const EdgeInsets.all(5.0),
        child: ContainedTabBarView(
          tabs: const [
            Text('Scene'),
            Text('Camera'),
          ],
          views: [
            SceneControls(scene: widget.scene),
            CameraControls(camera: widget.camera),
          ],
          onChange: (index) => print(index),
        ),
      ),
    );
  }
}

class SceneControls extends StatefulWidget {
  final Scene scene;
  const SceneControls({Key? key, required this.scene}) : super(key: key);

  @override
  _SceneControlsState createState() => _SceneControlsState();
}

class _SceneControlsState extends State<SceneControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var obj in widget.scene.children) MeshOptionsExpansionWidget(object3d: obj),
          ],
        ),
      ),
    );
  }
}

class MeshOptionsExpansionWidget extends StatefulWidget {
  final Object3D object3d;
  const MeshOptionsExpansionWidget({Key? key, required this.object3d}) : super(key: key);

  @override
  _MeshOptionsExpansionWidgetState createState() => _MeshOptionsExpansionWidgetState();
}

class _MeshOptionsExpansionWidgetState extends State<MeshOptionsExpansionWidget> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.object3d.name,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      children: <Widget>[
        // const ExpansionTile(
        //   title: Text(
        //     'Position',
        //   ),
        //   children: <Widget>[
        //     ListTile(
        //       title: Text('more options 1'),
        //     )
        //   ],
        // ),
        MeshOptionExpansion(
          object3d: widget.object3d,
          controlName: 'position',
          attr: widget.object3d.position,
          min: -500,
          max: 500,
        ),
        MeshOptionExpansion(
          object3d: widget.object3d,
          controlName: 'rotation',
          attr: widget.object3d.rotation,
          min: -180,
          max: 180,
        ),
        MeshOptionExpansion(
          object3d: widget.object3d,
          controlName: 'scale',
          attr: widget.object3d.scale,
          min: 1,
          max: 100,
        ),
      ],
    );
  }
}

class MeshOptionExpansion extends StatefulWidget {
  final Object3D object3d;
  final String controlName;
  final Vector3 attr;
  final double min;
  final double max;
  const MeshOptionExpansion({
    Key? key,
    required this.object3d,
    required this.controlName,
    required this.attr,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  _MeshOptionExpansionState createState() => _MeshOptionExpansionState();
}

class _MeshOptionExpansionState extends State<MeshOptionExpansion> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.controlName),
      children: <Widget>[
        MeshOptionControl(
          object3d: widget.object3d,
          attr: widget.attr,
          controlName: widget.controlName,
          min: widget.min,
          max: widget.max,
        ),
      ],
    );
  }
}

class MeshOptionControl extends StatefulWidget {
  final Object3D object3d;
  final String controlName;
  final Vector3 attr;
  final double min;
  final double max;

  const MeshOptionControl({
    Key? key,
    required this.object3d,
    required this.controlName,
    required this.attr,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  _MeshOptionControlState createState() => _MeshOptionControlState();
}

class _MeshOptionControlState extends State<MeshOptionControl> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Column(
              children: [
                SliderRow(
                  name: "x:",
                  value: widget.controlName == 'rotation' ? MathUtils.radToDeg(widget.attr.x) : widget.attr.x,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.x = widget.controlName == 'rotation' ? MathUtils.degToRad(val) : val;
                      widget.object3d.updateMatrix();
                    });
                  },
                ),
                SliderRow(
                  name: "y:",
                  value: widget.controlName == 'rotation' ? MathUtils.radToDeg(widget.attr.y) : widget.attr.y,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.y = widget.controlName == 'rotation' ? MathUtils.degToRad(val) : val;
                      widget.object3d.updateMatrix();
                    });
                  },
                ),
                SliderRow(
                  name: "z:",
                  value: widget.controlName == 'rotation' ? MathUtils.radToDeg(widget.attr.z) : widget.attr.z,
                  min: widget.min,
                  max: widget.max,
                  onChange: (val) {
                    setState(() {
                      widget.attr.z = widget.controlName == 'rotation' ? MathUtils.degToRad(val) : val;
                      widget.object3d.updateMatrix();
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
