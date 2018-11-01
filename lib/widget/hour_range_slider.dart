
import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';
import 'package:intl/intl.dart';

typedef void OnChanged(double lower, double upper);

/// 時間幅入力スライダーと+/-ボタン、ラベルの複合widget
class HourRangeSlider extends StatefulWidget {
  final String label;
  final double lowerValue;
  final double upperValue;
  final double min;
  final double max;
  final int divisions;
  final double width;
  final SliderThemeData sliderTheme;
  final OnChanged onChanged;

  HourRangeSlider(
      this.lowerValue,
      this.upperValue,
      this.min,
      this.max,
      this.width,
      {
        this.label,
        this.divisions,
        this.sliderTheme,
        this.onChanged,
        Key key,
      }
  ): super(key: key) {
    assert(0 != divisions);
  }

  @override
  State<StatefulWidget> createState() => _HourRangeSlider();
}

class _HourRangeSlider extends State<HourRangeSlider> {
  double _lowerValue;
  double _upperValue;
  double _duration;
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
    _lowerValue = widget.lowerValue;
    _upperValue = widget.upperValue;
    _duration = _upperValue - _lowerValue;
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
                null != widget.label ? widget.label : '${_duration.toStringAsFixed(2)} h',
                style: TextStyle(
                  color: _getThemeColor(),
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: widget.width,
          child: _buildRangeSlider(),
        ),
        _buildButtons(),
      ],
    );
  }

  Widget _buildRangeSlider() {
    var slider = RangeSlider(
      min: widget.min,
      max: widget.max,
      lowerValue: _lowerValue,
      upperValue: _upperValue,
      divisions: widget.divisions,
      valueIndicatorMaxDecimals: 2,
      onChanged: (lower, upper) {
        setState(() {
          _lowerValue = lower;
          _upperValue = upper;
          widget.onChanged(lower, upper);
        });
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                color: _getThemeColor(),
                onPressed: () {
                  _increaseLower();
                },
              ),
              Text(
                0.0 == _duration ? '' : _convertTime(_lowerValue),
                style: TextStyle(
                    color: _getThemeColor(),
                    fontSize: 16.0
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                color: _getThemeColor(),
                onPressed: () {
                  _reduceLower();
                },
              )
            ],
          ),
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                color: _getThemeColor(),
                onPressed: () {
                  _increaseUpper();
                },
              ),
              Text(
                0.0 == _duration ? '' : _convertTime(_upperValue),
                style: TextStyle(
                    color: _getThemeColor(),
                    fontSize: 16.0
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                color: _getThemeColor(),
                onPressed: () {
                  _reduceUpper();
                },
              )
            ],
          ),
        ]
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

  String _convertTime(double value) {
    int hour = value.toInt();
    int minute = ((value - hour) * 60.0).toInt();
    return DateFormat('HH:mm').format(DateTime(2000, 1, 1, hour, minute, 0));
  }

  _increaseLower() {
    if ((_lowerValue + _step) < _upperValue) {
      setState(() {
        _lowerValue = _lowerValue + _step;
        widget.onChanged(_lowerValue, _upperValue);
      });
    }
  }

  _reduceLower() {
    if ((_lowerValue - _step) >= widget.min) {
      setState(() {
        _lowerValue = _lowerValue - _step;
        widget.onChanged(_lowerValue, _upperValue);
      });
    }
  }

  _increaseUpper() {
    if ((_upperValue + _step) <= widget.max) {
      setState(() {
        _upperValue = _upperValue + _step;
        widget.onChanged(_lowerValue, _upperValue);
      });
    }
  }

  _reduceUpper() {
    if ((_upperValue - _step) > _lowerValue) {
      setState(() {
        _upperValue = _upperValue - _step;
        widget.onChanged(_lowerValue, _upperValue);
      });
    }
  }
}