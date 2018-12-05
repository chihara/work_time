
import 'package:flutter/material.dart';

typedef void OnChanged(double value);

/// 時間入力スライダーと+/-ボタン、ラベルの複合widget
class HourSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final double width;
  final SliderThemeData sliderTheme;
  final OnChanged onChanged;

  HourSlider({
    Key key,
    @required this.value,
    @required this.min,
    @required this.max,
    @required this.width,
    this.label,
    this.divisions,
    this.sliderTheme,
    this.onChanged,
  }) : assert(0 != divisions),
       super(key: key);

  @override
  State<StatefulWidget> createState() => _HourSlider();
}

class _HourSlider extends State<HourSlider> {
  double _value;
  double _step;

  @override
  void initState() {
    super.initState();
    if (null != widget.divisions) {
      _step = (widget.max - widget.min) / widget.divisions;
    }
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.value;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox.fromSize(
          size: Size(widget.width, 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                  null != widget.label ? widget.label : '${_value.toStringAsFixed(2)} h',
                  style: TextStyle(
                    color: _getThemeColor(),
                    fontSize: 16.0,
                  )
              ),
            ],
          ),
        ),
        Container(
          width: null != widget.divisions ? widget.width - 70.0 : widget.width,
          child: _buildSlider(),
        ),
        _buildButtons(),
      ],
    );
  }

  Widget _buildSlider() {
    var slider = Slider(
      min: widget.min,
      max: widget.max,
      value: _value,
      divisions: widget.divisions,
      onChanged: (v) {
        setState(() {
          _value = v;
        });
        if (null != widget.onChanged) {
          widget.onChanged(v);
        }
      },
    );
    if (null == widget.sliderTheme) {
      return slider;
    } else {
      return SliderTheme(
        data: widget.sliderTheme,
        child: slider,
      );
    }
  }

  Widget _buildButtons() {
    if (null == widget.divisions) {
      return Container();
    } else {
      return Container(
        width: widget.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove),
              color: _getThemeColor(),
              onPressed: () {
                _reduce();
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              color: _getThemeColor(),
              onPressed: () {
                _increase();
              },
            ),
          ],
        ),
      );
    }
  }

  Color _getThemeColor() {
    if (null == widget.sliderTheme) {
      return Theme.of(context).primaryColor;
    } else {
      return widget.sliderTheme.thumbColor;
    }
  }

  _increase() {
    if ((_value + _step) <= widget.max) {
      setState(() {
        _value = _value + _step;
        if (null != widget.onChanged) {
          widget.onChanged(_value);
        }
      });
    }
  }

  _reduce() {
    if ((_value - _step) >= widget.min) {
      setState(() {
        _value = _value - _step;
        if (null != widget.onChanged) {
          widget.onChanged(_value);
        }
      });
    }
  }
}