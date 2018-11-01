
import 'package:flutter/material.dart';

/// 符号付き時間表示用widget
class Difference extends StatefulWidget {
  final double value;
  final bool inactivated;

  Difference(this.value, {this.inactivated = false, Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _Difference();
}

class _Difference extends State<Difference> {
  @override
  Widget build(BuildContext context) {
    if (0.0 < widget.value) {
      return Text(
          '+${widget.value.toStringAsFixed(2)}',
          style: TextStyle(
              color: widget.inactivated ? Colors.black26 : Colors.cyan,
              fontSize: 16.0
          )
      );
    } else if (0.0 > widget.value) {
      return Text(
          '${widget.value.toStringAsFixed(2)}',
          style: TextStyle(
              color: widget.inactivated ? Colors.black26 : Colors.orange,
              fontSize: 16.0
          )
      );
    } else {
      return Text('');
    }
  }
}