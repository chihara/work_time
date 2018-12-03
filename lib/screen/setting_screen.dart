
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working/settings/settings.dart';
import 'package:working/widget/hour_slider.dart';

/// 設定画面
class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  final Settings _settings = Settings();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _settings.load(() {
          Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: _buildBody(context),
      ),
    );
  }

  // コンテンツ全体widgetの構築をする
  Widget _buildBody(BuildContext context) {
    final _textStyle = TextStyle(
        fontSize: 18.0,
        color: Colors.black87,
    );
    final _sliderTheme = SliderThemeData.fromPrimaryColors(
        primaryColor: Color.fromARGB(0xff, 0x80, 0x80, 0x80),
        primaryColorDark: Color.fromARGB(0xff, 0x60, 0x60, 0x60),
        primaryColorLight: Color.fromARGB(0xff, 0xa0, 0xa0, 0xa0),
        valueIndicatorTextStyle: TextStyle(color: Colors.white)
    );
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.calendar_today),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Monthly', style: _textStyle,),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Divider(),
              ),
              HourSlider(
                _settings.hoursPerMonth,
                0.0,
                200.0,
                260.0,
                label: 'Duration ${_settings.hoursPerMonth.toStringAsFixed(0)} h',
                divisions: 200,
                sliderTheme: _sliderTheme,
                onChanged: (v) {
                  setState(() {
                    _settings.hoursPerMonth = v;
                  });
                },
              ),
              Padding(padding: EdgeInsets.only(top: 16.0),),
              Row(
                children: <Widget>[
                  Icon(Icons.access_time),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text('Daily', style: _textStyle,),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Divider(),
              ),
              HourSlider(
                _settings.start,
                0.0,
                24.0,
                260.0,
                label: 'Start ${_convertTime(_settings.start)}',
                divisions: 96,
                sliderTheme: _sliderTheme,
                onChanged: (v) {
                  setState(() {
                    _settings.set(start: v);
                  });
                },
              ),
              Padding(padding: EdgeInsets.only(top: 8.0),),
              HourSlider(
                _settings.end,
                0.0,
                24.0,
                260.0,
                label: 'End ${_convertTime(_settings.end)}',
                divisions: 96,
                sliderTheme: _sliderTheme,
                onChanged: (v) {
                  setState(() {
                    _settings.set(end: v);
                  });
                },
              ),
              Padding(padding: EdgeInsets.only(top: 8.0),),
              HourSlider(
                _settings.rest,
                0.0,
                3.0,
                260.0,
                label: 'Rest ${_settings.rest.toStringAsFixed(2)} h',
                divisions: 12,
                sliderTheme: _sliderTheme,
                onChanged: (v) {
                  setState(() {
                    _settings.set(rest: v);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 動作環境に応じてボトムナビゲーションバーを構築する
  Widget _buildBottomNavigationBar() {
    final applyButton = IconButton(
      icon: Icon(Icons.check),
      onPressed: () {
        _settings.save();
        Navigator.pop(context, 'saved');
      },
    );
    if (TargetPlatform.iOS == Theme.of(context).platform) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _settings.load(() {
                Navigator.pop(context);
              });
            },
          ),
          applyButton,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          applyButton,
        ],
      );
    }
  }

  // double値で管理している時間を表示文字列に変換する
  String _convertTime(double value) {
    int hour = value.toInt();
    int minute = ((value - hour) * 60.0).toInt();
    return DateFormat('HH:mm').format(DateTime(2000, 1, 1, hour, minute, 0));
  }
}