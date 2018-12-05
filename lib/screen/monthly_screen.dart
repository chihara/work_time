
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:working/db/working.dart';
import 'package:working/settings/settings.dart';
import 'package:working/util/calendar_util.dart';
import 'package:working/widget/difference.dart';
import 'package:working/widget/monthly_list.dart';

/// 月間データ集計画面
class MonthlyScreen extends StatefulWidget {
  final DateTime date;
  final List<Working> list;
  final List<String> companyHolidays;
  final WorkingProvider provider;

  MonthlyScreen(
    this.date,
    this.list,
    this.companyHolidays,
    this.provider
  ): super(key: ObjectKey(date));

  @override
  State<StatefulWidget> createState() => _MonthlyScreen();
}

class _MonthlyScreen extends State<MonthlyScreen> {
  final GlobalKey<AnimatedCircularChartState> _chartKey = GlobalKey();
  final GlobalKey<MonthlyListState> _monthlyListKey = GlobalKey();
  final Settings _settings = Settings();
  DateTime _date;
  List<Working> _list;
  List<DateTime> _weekdays;
  double _sum;
  double _surplus;
  List<Working> _estimations = [];

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.date.year, widget.date.month, 1);
    _list = widget.list;
    _weekdays = CalendarUtil.getWeekdays(_date, customHolidays: widget.companyHolidays);
    _calculate();
    _createEstimations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Spreadsheet'),
      ),
      body: Column(
        children: <Widget>[
          _buildAggregatePane(),
          Expanded(
            child: MonthlyList(
              key: _monthlyListKey,
              list: _list,
              estimations: _estimations,
            ),
          )
        ]
      ),
    );
  }

  // 集計ペインwidgetを構築する
  Widget _buildAggregatePane() {
    return Material(
      elevation: 4.0,
      child: Container(
        height: 150.0,
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: <Widget>[
            Text(
              CalendarUtil.getYearAndMonth(_date),
              style: TextStyle(
                fontSize: 18.0
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${_list.length} / ${_weekdays.length} days',
                  style: TextStyle(
                    fontSize: 18.0
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Difference(
                      value: _surplus
                    ),
                    Text(
                      '$_sum h',
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      color: Colors.black45,
                      onPressed: () {
                        _date = DateTime(_date.year, _date.month - 1, _date.day);
                        widget.provider.list(_date).then((v) {
                          setState(() {
                            _list = v;
                            _weekdays = CalendarUtil.getWeekdays(_date, customHolidays: widget.companyHolidays);
                            _calculate();
                            _createEstimations();
                            _monthlyListKey.currentState.update(_list, _estimations);
                            _monthlyListKey.currentState.scrollToTop();
                          });
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      color: Colors.black45,
                      onPressed: () {
                        _date = DateTime(_date.year, _date.month + 1, _date.day);
                        widget.provider.list(_date).then((v) {
                          setState(() {
                            _list = v;
                            _weekdays = CalendarUtil.getWeekdays(_date, customHolidays: widget.companyHolidays);
                            _calculate();
                            _createEstimations();
                            _monthlyListKey.currentState.update(_list, _estimations);
                            _monthlyListKey.currentState.scrollToTop();
                          });
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
            Center(
              child: _buildCircularChart(),
            ),
          ],
        ),
      ),
    );
  }

  // 実績時間の合計値を求める
  double _sumWorkingTime(List<Working> list) {
    double sum = 0.0;
    list.forEach((w) {
      sum += w.duration;
    });
    return sum;
  }

  // 未入力の平日データを予測データで生成する
  _createEstimations() {
    _estimations = [];
    if (0.0 < (_settings.hoursPerMonth - _sum)) {
      double needDuration = (_settings.hoursPerMonth - _sum) / (_weekdays.length - _list.length);
      _weekdays.forEach((date) {
        bool exist = false;
        for (Working working in _list) {
          if (date.year == working.year && date.month == working.month &&
              date.day == working.day) {
            exist = true;
            break;
          }
        }
        if (!exist) {
          Working estimation = Working(date.year, date.month, date.day, _settings.start, _settings.end, _settings.rest);
          estimation.duration = needDuration;
          estimation.estimated = true;
          _estimations.add(estimation);
        }
      });
    }
  }

  _calculate() {
    _sum = _sumWorkingTime(_list);
    _surplus = _sum + ((_weekdays.length - _list.length) * _settings.hoursPerDay) - _settings.hoursPerMonth;
  }

  // 円グラフwidgetの構築する
  Widget _buildCircularChart() {
    List<CircularStackEntry> data = _createChartData();
    _chartKey.currentState?.updateData(data);
    return AnimatedCircularChart(
      key: _chartKey,
      size: Size(120.0, 120.0),
      chartType: CircularChartType.Radial,
      edgeStyle: SegmentEdgeStyle.round,
      percentageValues: true,
      initialChartData: data,
      holeLabel: '${(_sum / _settings.hoursPerMonth * 100).toStringAsFixed(2)} %',
      labelStyle: TextStyle(
        color: Colors.black87,
        fontSize: 16.0
      ),
    );
  }

  // 円グラフに渡すデータを生成する
  // stackに追加した順に上から重なる、最初に追加したデータがtopになるので注意
  List<CircularStackEntry> _createChartData() {
    double progressActual = _sum / _settings.hoursPerMonth * 100;
    double progressSurplus = (_surplus / _settings.hoursPerMonth * 100).abs();
    List<CircularSegmentEntry> stack = [];
    stack.add(CircularSegmentEntry(
      progressActual,
      Theme.of(context).primaryColor
    ));
    if (100.0 > progressActual) {
      stack.add(CircularSegmentEntry(
        progressSurplus,
        0.0 > _surplus ? Colors.orange : Colors.cyan,
      ));
    }
    if (100.0 > (progressActual + progressSurplus)) {
      stack.add(CircularSegmentEntry(
        100.0 - progressActual - progressSurplus,
        Colors.black12
      ));
    }
    return <CircularStackEntry>[CircularStackEntry(stack)];
  }
}