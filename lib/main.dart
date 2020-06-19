import 'package:flutter/material.dart';
import 'package:inafews_app/pages/splashScreen.dart';
import 'package:inafews_app/pages/statisticPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InaFEWS STMKG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       fontFamily: "Ubuntu"
      ),
      initialRoute: '/statistic',
      routes: {
        '/statistic'  : (context) => StatisticPage(),
        '/splash'     : (context) => SplashScreen(),
      },
    );
  }
}