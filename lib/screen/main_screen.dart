
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:working/db/database_provider.dart';
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
  WorkingProvider _workingProvider;
  DateTime _date;
  Working _working;
  List<Working> _list;
  List<String> _companyHolidays;
  Map<String, double> _defaultTime;

  @override
  void initState() {
    super.initState();
    _defaultTime = <String, double>{
      Working.START: _settings.start,
      Working.END: _settings.end,
      Working.REST: _settings.rest,
    };
    _date = DateTime.now();
    _working = Working.fromDateTime(_date, time: _defaultTime);
    DatabaseProvider.open(onOpened: () {
      _workingProvider = DatabaseProvider.getWorkingProvider();
      _refresh();
      _getCompanyHolidays();
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
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MonthlyScreen(_date, _list, _companyHolidays, _workingProvider)
              ));
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
                  Working.START: _settings.start,
                  Working.END: _settings.end,
                  Working.REST: _settings.rest,
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
            padding: EdgeInsets.only(top: 30.0),
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
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildInputDurationSlider(),
              _buildInputRestSlider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlineButton(
                    child: Icon(Icons.delete, color: Colors.black38,),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(0.0),
                    highlightedBorderColor: Colors.black54,
                    onPressed: () {
                      _workingProvider?.delete(_date);
                      _refresh();
                      _getCompanyHolidays();
                    },
                  ),
                  OutlineButton(
                    child: Icon(Icons.business, color: _working.companyHoliday ? Colors.orange : Colors.black38,),
                    shape: CircleBorder(),
                    textColor: _working.holiday ? Colors.orange : Colors.black38,
                    highlightColor: Colors.orange.withAlpha(40),
                    highlightedBorderColor: Colors.orange,
                    onPressed: () {
                      _working = Working.fromDateTime(_date);
                      _working.companyHoliday = true;
                      _workingProvider?.insert(_working);
                      _refresh();
                      _getCompanyHolidays();
                    },
                  ),
                  OutlineButton(
                    child: Icon(Icons.beach_access, color: _working.holiday ? Colors.orange : Colors.black38,),
                    shape: CircleBorder(),
                    highlightColor: Colors.orange.withAlpha(40),
                    highlightedBorderColor: Colors.orange,
                    onPressed: () {
                      _working = Working.fromDateTime(_date);
                      _working.holiday = true;
                      _workingProvider?.insert(_working);
                      _refresh();
                      _getCompanyHolidays();
                    },
                  ),
                  _buildSubmitButton(),
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
    if (_working.holiday || _working.companyHoliday) {
      return Container();
    } else {
      final theme = SliderThemeData.fromPrimaryColors(
          primaryColor: Colors.cyan,
          primaryColorDark: Colors.cyan[700],
          primaryColorLight: Colors.cyan[300],
          valueIndicatorTextStyle: TextStyle(color: Colors.white)
      );
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: HourRangeSlider(
          lowerValue: _working.start,
          upperValue: _working.end,
          min: 8.0,
          max: 24.0,
          width: 340.0,
          label: 'Work ${_working.duration.toStringAsFixed(2)} h',
          divisions: 64,
          sliderTheme: _working.id == null ? null : theme,
          onChanged: (lower, upper) {
            setState(() {
              _working.setTime(start: lower, end: upper);
            });
          },
        ),
      );
    }
  }

  // 休憩時間入力スライダーwidgetを構築する
  Widget _buildInputRestSlider() {
    if (_working.holiday || _working.companyHoliday) {
      return Container();
    } else {
      return HourSlider(
        value: _working.rest,
        min: 0.0,
        max: 4.0,
        width: 230.0,
        label: 'Rest ${_working.rest.toStringAsFixed(2)} h',
        divisions: 16,
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

  Widget _buildSubmitButton() {
    if (_working.holiday || _working.companyHoliday) {
      return Container(
        width: 88.0,
      );
    } else {
      return OutlineButton(
        child: Icon(Icons.check, color: _working.id == null ? Theme.of(context).primaryColor : Colors.cyan),
        shape: CircleBorder(),
        highlightColor: _working.id == null ? Theme.of(context).primaryColor.withAlpha(40) : Colors.cyan.withAlpha(40),
        highlightedBorderColor: _working.id == null ? Theme.of(context).primaryColor : Colors.cyan,
        onPressed: () {
          _workingProvider?.insert(_working);
          _refresh();
        },
      );
    }
  }

  // 種別ごとの休日帯widgetを構築する
  Widget _buildHolidayRibbon() {
    if (_working.holiday) {
      return _buildLabel("User's Holiday", Colors.orange);
    } else if (_working.companyHoliday) {
      return _buildLabel("Company Holiday", Colors.orange);
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
    _workingProvider?.get(_date)?.then((value) {
      setState(() {
        if (null == value) {
          _working = Working.fromDateTime(_date, time: _defaultTime);
        } else {
          _working = value;
        }
      });
    });
    _workingProvider?.list(_date)?.then((list) {
      _list = list;
    });
  }
  
  _getCompanyHolidays() {
    _workingProvider?.companyHolidays()?.then((value) {
      _companyHolidays = value;
    });
  }
}