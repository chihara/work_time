
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:working/settings/settings.dart';

/// スプラッシュ画面
class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  final Settings _settings = Settings();
  bool initialized = false;
  bool expired = false;

  @override
  void initState() {
    _settings.load(() {
      initialized = true;
      _moveToMainScreen();
    });
    _startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.access_time, size: 140.0, color: Colors.white,),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('WorkTime',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // スプラッシュ画面を終了させるタイマーを開始する
  _startTimer() async {
    Timer(Duration(seconds: 2), () {
      expired = true;
      _moveToMainScreen();
    });
  }

  // スプラッシュ画面をメイン画面に置き換えて遷移する
  _moveToMainScreen() {
    if (initialized && expired) {
      Navigator.pushReplacementNamed(context, '/MainScreen');
    }
  }
}