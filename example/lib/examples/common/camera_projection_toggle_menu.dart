import 'package:flutter/material.dart';

class CameraProjectionToggleMenu extends StatefulWidget {

  final List<bool> options;
  final Function onChange;
  const CameraProjectionToggleMenu({ Key? key, required this.options, required this.onChange }) : super(key: key);

  @override
  _CameraProjectionToggleMenuState createState() => _CameraProjectionToggleMenuState();
}

class _CameraProjectionToggleMenuState extends State<CameraProjectionToggleMenu> {
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      color: Colors.red,
      children: const <Widget>[
        // Icon(Icons.videocam_outlined),
        TextButton(
          child: Text('Orthographic', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          onPressed: null,
        ),
        TextButton(
          child: Text('Perspective', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          onPressed: null,
        )
      ],
      onPressed: (int index) {
        setState(() {
          int selectedIndex = 0;
          for (int buttonIndex = 0; buttonIndex < widget.options.length; buttonIndex++) {
            if (buttonIndex == index) {
              widget.options[buttonIndex] = !widget.options[buttonIndex];
              selectedIndex = buttonIndex;
            } else {
              widget.options[buttonIndex] = false;
            }
          }
          widget.onChange(selectedIndex);
        });
      },
      isSelected: widget.options,
    );
  }
}
