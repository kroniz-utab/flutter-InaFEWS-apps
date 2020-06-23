import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inafews_app/core/style.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startSplashScreen() async{
    var dur = const Duration(seconds: 5);

    return Timer(dur, (){
      Navigator.pushReplacementNamed(context, '/statistic');
    });
  }

  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/inafews_icon.png",
                  height: 150,
                  width: 150,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15 * MediaQuery.of(context).size.aspectRatio),
                  child: Text(
                    "Indonesia Flood Early \nWarning System",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: SpinKitWave(
                    color: Colors.white,
                    size: 40 * MediaQuery.of(context).size.aspectRatio,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}