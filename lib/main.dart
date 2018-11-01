
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:working/screen/main_screen.dart';
import 'package:working/screen/splash_screen.dart';
import 'package:working/settings/settings.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkTime',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/MainScreen': (BuildContext context) => new MainScreen()
      },
    );
  }
}
