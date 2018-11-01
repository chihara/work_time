
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:working/db/working.dart';
import 'package:working/screen/monthly_screen.dart';
import 'package:working/screen/setting_screen.dart';
import 'package:working/settings/settings.dart';
import 'package:working/util/calendar_util.dart';
import 'package:working/widget/hour_range_slider.dart';
import 'package:working/widget/hour_slider.dart';

/// メイン画面
class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  Settings _settings = Settings();
  WorkingProvider _provider = WorkingProvider();
  DateTime _date;
  Working _working;
  List<Working> _list;
  Map<String, double> _defaultTime;

  @override
  void initState() {
    super.initState();
    _defaultTime = <String, double>{
      columnStart: _settings.start,
      columnEnd: _settings.end,
      columnRest: _settings.rest,
    };
    _date = DateTime.now();
    _working = Working.fromDate(_date, time: _defaultTime);
    getDatabasesPath().then((path) {
      _provider.open(join(path, 'workind.db')).then((dynamic) {
        _refresh();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WorkTime'),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyScreen(_date, _list, _provider)
                )
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final event = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingScreen()
                )
              );
              if (null != event && 'saved' == event) {
                _defaultTime = <String, double>{
                  columnStart: _settings.start,
                  columnEnd: _settings.end,
                  columnRest: _settings.rest,
                };
                _refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Calendar(
              onDateSelected: (date) {
                _date = date;
                _refresh();
              }
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHolidayRibbon(),
              _buildInputPane(context),
            ],
          ),
        ],
      ),
    );
  }

  // 入力ペインwidgetを構築する
  Widget _buildInputPane(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.white70,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildInputDurationSlider(),
              _buildInputRestSlider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          color: Colors.black38
                      ),
                    ),
                    onPressed: () {
                      _provider.delete(_date);
                      _refresh();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Holiday',
                      style: TextStyle(
                        color: Colors.orange
                      ),
                    ),
                    onPressed: () {
                      _working = Working.fromDate(_date);
                      _working.holiday = true;
                      _provider.insert(_working);
                      _refresh();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      (_working.id == null ? 'Submit' : 'Update'),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor
                      ),
                    ),
                    onPressed: () {
                      _provider.insert(_working);
                      _refresh();
                    },
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  // 勤務時間入力スライダーwidgetを構築する
  Widget _buildInputDurationSlider() {
    if (_working.holiday) {
      return Container();
    } else {
      return HourRangeSlider(
        _working.start,
        _working.end,
        8.0,
        24.0,
        340.0,
        label: 'Work ${_working.duration.toStringAsFixed(2)} h',
        divisions: 64,
        onChanged: (lower, upper) {
          setState(() {
            _working.setTime(start: lower, end: upper);
          });
        },
      );
    }
  }

  // 休憩時間入力スライダーwidgetを構築する
  Widget _buildInputRestSlider() {
    if (_working.holiday) {
      return Container();
    } else {
      return HourSlider(
        _working.rest,
        0.0,
        3.0,
        230.0,
        label: 'Rest ${_working.rest.toStringAsFixed(2)} h',
        divisions: 12,
        sliderTheme: SliderThemeData.fromPrimaryColors(
          primaryColor: Color.fromARGB(0xff, 0x80, 0x80, 0x80),
          primaryColorDark: Color.fromARGB(0xff, 0x60, 0x60, 0x60),
          primaryColorLight: Color.fromARGB(0xff, 0xa0, 0xa0, 0xa0),
          valueIndicatorTextStyle: TextStyle(color: Colors.white)
        ),
        onChanged: (v) {
          setState(() {
            _working.setTime(rest: v);
          });
        },
      );
    }
  }

  // 種別ごとの休日帯widgetを構築する
  Widget _buildHolidayRibbon() {
    if (_working.holiday) {
      return _buildLabel("User's Holiday", Colors.orange);
    } else if (CalendarUtil.isNationalHoliday(_date)) {
      return _buildLabel('National Holiday', Colors.deepOrange);
    } else if (DateTime.sunday == _date.weekday) {
      return _buildLabel('Sunday', Colors.deepOrange);
    } else if (DateTime.saturday == _date.weekday) {
      return _buildLabel('Saturday', Colors.deepOrange);
    } else {
      return Container();
    }
  }

  // 休日帯widget本体を構築する
  Widget _buildLabel(String label, Color color) {
    return Material(
      elevation: 2.0,
      child: Container(
        height: 24.0,
        color: color,
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      ),
    );
  }

  // 描画内容を更新する
  _refresh() {
    _provider.get(_date).then((value) {
      setState(() {
        if (null == value) {
          _working = Working.fromDate(_date, time: _defaultTime);
        } else {
          _working = value;
        }
      });
    });
    _provider.list(_date).then((list) {
      _list = list;
    });
  }
}