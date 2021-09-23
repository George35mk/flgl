import 'package:flutter/material.dart';

class SliderRow extends StatefulWidget {
  double value;
  final double min;
  final double max;
  final String name;
  final Function? onChange;

  SliderRow({
    Key? key,
    this.name = 'Slider name',
    this.value = 0,
    this.min = 0,
    this.max = 500,
    this.onChange,
  }) : super(key: key);

  @override
  _SliderRowState createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 280,
            child: Slider(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              // divisions: widget.max <= 1 ? 1 : (widget.max / 5).toInt(),
              // label: tx.round().toString(),
              onChanged: (double value) {
                setState(() {
                  widget.value = value;
                  widget.onChange!(widget.value);
                });
              },
            ),
          ),
          Text(
            widget.value.ceil().toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
