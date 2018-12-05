
import 'package:flutter/material.dart';
import 'package:working/db/working.dart';
import 'package:working/settings/settings.dart';
import 'package:working/widget/bar_chart.dart';
import 'package:working/widget/difference.dart';

/// 月間データ集計画面の日別リスト用項目widget
class DailyItem extends StatefulWidget {
  final Working working;

  DailyItem({
    @required this.working
  }) : super (key: ObjectKey(working));

  @override
  State<StatefulWidget> createState() => _DailyItem();
}

class _DailyItem extends State<DailyItem> {
  final Settings _settings = Settings();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      height: 20.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 40.0,
            child: Center(
              child: Text(
                '${widget.working.day}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: widget.working.estimated ? Colors.black26 : Colors.black87,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              BarChart(
                value: widget.working.duration,
                border: _settings.hoursPerDay,
                max: 16.0,
                inactivated: widget.working.estimated
              ),
            ],
          ),
          Container(
            width: 50.0,
            child: Center(
              child: Difference(
                value: (widget.working.duration - _settings.hoursPerDay),
                inactivated: widget.working.estimated
              ),
            ),
          ),
          Container(
            width: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${widget.working.duration.toStringAsFixed(2)} h',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: widget.working.estimated ? Colors.black26 : Colors.black87,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}