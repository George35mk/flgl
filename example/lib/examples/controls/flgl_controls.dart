import 'package:flgl/flgl_3d.dart';
import 'package:flgl_example/examples/controls/transform_controls_manager.dart';
import 'package:flutter/material.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'camera_controls.dart';
import 'scene_controls.dart';

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
