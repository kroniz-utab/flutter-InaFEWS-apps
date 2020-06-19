import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inafews_app/core/flutter_icons.dart';
import 'package:inafews_app/core/style.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:inafews_app/core/base_api.dart' as RestAPI;

import 'dart:convert';
import 'dart:async';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

Future<Banjir> fetchBanjir() async{
  final response = await http.get(RestAPI.BASE_URL + "/last");

  if(response.statusCode == 200){
    return Banjir.fromJson(json.decode(response.body));
  } else{
    throw Exception('Failed to Load Data');
  }
}

Banjir banjirFromJson(String str) => Banjir.fromJson(json.decode(str));

String banjir2json(Banjir data) => json.encode(data.toJson());

class Banjir {
    Banjir({
        this.siteStatus,
        this.data,
        this.today,
    });

    String siteStatus;
    Data data;
    Today today;

    factory Banjir.fromJson(Map<String, dynamic> json) => Banjir(
        siteStatus: json["site_status"],
        data: Data.fromJson(json["data"]),
        today: Today.fromJson(json["today"]),
    );

    Map<String, dynamic> toJson() => {
        "site_status": siteStatus,
        "data": data.toJson(),
        "today": today.toJson(),
    };
}

class Data {
    Data({
        this.ketinggian,
        this.status,
        this.tanggal,
        this.jam,
    });

    String ketinggian;
    String status;
    DateTime tanggal;
    String jam;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        ketinggian: json["ketinggian"],
        status: json["status"],
        tanggal: DateTime.parse(json["tanggal"]),
        jam: json["jam"],
    );

    Map<String, dynamic> toJson() => {
        "ketinggian": ketinggian,
        "status": status,
        "tanggal": "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "jam": jam,
    };
}

class Today {
    Today({
        this.max,
        this.min,
        this.banjir,
        this.awas,
        this.waspada,
    });

    String max;
    String min;
    int banjir;
    int awas;
    int waspada;

    factory Today.fromJson(Map<String, dynamic> json) => Today(
        max: json["max"],
        min: json["min"],
        banjir: json["banjir"],
        awas: json["awas"],
        waspada: json["waspada"],
    );

    Map<String, dynamic> toJson() => {
        "max": max,
        "min": min,
        "banjir": banjir,
        "awas": awas,
        "waspada": waspada,
    };
}


class StatisticPage extends StatefulWidget {
  StatisticPage({Key key}) : super(key: key);

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {

  Future<Banjir> futureBanjir;

  RefreshController _refreshController = RefreshController(initialRefresh: false);


  @override
  void initState(){
    super.initState();
    futureBanjir = fetchBanjir();
    setupNotification();
  }

  void setupNotification() async {
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

    _firebaseMessaging.subscribeToTopic("peringatan");

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("message: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("message: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("message: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.aspectRatio  * 600,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100*MediaQuery.of(context).size.aspectRatio),
                bottomRight: Radius.circular(100*MediaQuery.of(context).size.aspectRatio),
              )
            ),
          ),
          SmartRefresher(
            header: WaterDropHeader(
              waterDropColor: Colors.white,
            ),
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: () async {
              futureBanjir = fetchBanjir();
              setState(() {});
              _refreshController.refreshCompleted();
            },
            child: new FutureBuilder<Banjir>(
              future: futureBanjir,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasError){
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (snapshot.hasData){
                  if(snapshot.data.siteStatus != "Active"){
                    return _buildMain(
                      "Situ Gintung",
                      "Ciputat, Tangerang Selatan",
                      snapshot.data.data.tanggal.toString(), 
                      snapshot.data.data.jam, 
                      AppColors.offColor, 
                      snapshot.data.data.ketinggian, 
                      "SITE MATI", 
                      "24", 
                      "5", 
                      "2", 
                      snapshot.data.today.max, 
                      snapshot.data.today.min, 
                      snapshot.data.today.banjir.toString(), 
                      snapshot.data.today.awas.toString(),
                      snapshot.data.today.waspada.toString(),
                    );
                  } else {
                    if(snapshot.data.data.status == "1"){
                      return _buildMain(
                        "Situ Gintung",
                        "Ciputat, Tangerang Selatan",
                        snapshot.data.data.tanggal.toString(), 
                        snapshot.data.data.jam, 
                        AppColors.meluapAlert, 
                        snapshot.data.data.ketinggian, 
                        "MELUAP", 
                        "24", 
                        "5", 
                        "2", 
                        snapshot.data.today.max, 
                        snapshot.data.today.min, 
                        snapshot.data.today.banjir.toString(), 
                        snapshot.data.today.awas.toString(),
                        snapshot.data.today.waspada.toString(),
                      );
                    } else if(snapshot.data.data.status == "2"){
                      return _buildMain(
                        "Situ Gintung",
                        "Ciputat, Tangerang Selatan",
                        snapshot.data.data.tanggal.toString(), 
                        snapshot.data.data.jam, 
                        AppColors.awasAlert, 
                        snapshot.data.data.ketinggian, 
                        "AWAS", 
                        "24", 
                        "5", 
                        "2", 
                        snapshot.data.today.max, 
                        snapshot.data.today.min, 
                        snapshot.data.today.banjir.toString(), 
                        snapshot.data.today.awas.toString(),
                        snapshot.data.today.waspada.toString(),
                      );
                    } else if(snapshot.data.data.status == "3"){
                      return _buildMain(
                        "Situ Gintung",
                        "Ciputat, Tangerang Selatan",
                        snapshot.data.data.tanggal.toString(), 
                        snapshot.data.data.jam, 
                        AppColors.waspadaAlert, 
                        snapshot.data.data.ketinggian, 
                        "WASPADA", 
                        "24", 
                        "5", 
                        "2", 
                        snapshot.data.today.max, 
                        snapshot.data.today.min, 
                        snapshot.data.today.banjir.toString(), 
                        snapshot.data.today.awas.toString(),
                        snapshot.data.today.waspada.toString(),
                      );
                    } else if(snapshot.data.data.status == "4"){
                      return _buildMain(
                        "Situ Gintung",
                        "Ciputat, Tangerang Selatan",
                        snapshot.data.data.tanggal.toString(), 
                        snapshot.data.data.jam, 
                        AppColors.amanColor, 
                        snapshot.data.data.ketinggian, 
                        "AMAN", 
                        "24", 
                        "5", 
                        "2", 
                        snapshot.data.today.max, 
                        snapshot.data.today.min, 
                        snapshot.data.today.banjir.toString(), 
                        snapshot.data.today.awas.toString(),
                        snapshot.data.today.waspada.toString(),
                      );
                    }
                  }
                }
                return SpinKitDoubleBounce(
                  color: Colors.blue,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Container _buildMain(
    String loc,
    String detail,
    String tanggal,
    String jam,
    Color colorInd,
    String tinggi,
    String status,
    String temp,
    String wind,
    String rain,
    String max,
    String min,
    String meluap,
    String awas,
    String waspada
  ) {
    return Container(
          padding: EdgeInsets.only(top: 25 * MediaQuery.of(context).size.aspectRatio ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 100 * MediaQuery.of(context).size.aspectRatio ,
                  left: 30 * MediaQuery.of(context).size.aspectRatio,
                  right: 30 * MediaQuery.of(context).size.aspectRatio
                ),
                child: Text(
                  loc,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32 * MediaQuery.of(context).textScaleFactor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10 * MediaQuery.of(context).size.aspectRatio,
                  left: 30 * MediaQuery.of(context).size.aspectRatio ,
                  right: 30 * MediaQuery.of(context).size.aspectRatio,
                  bottom: 15 * MediaQuery.of(context).size.aspectRatio,
                ),
                child: Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                  ),
                ),
              ),
              // tanggal, jam, ketinggian, status, temp, wind, rain
              _buildMainBanner(tanggal, jam, colorInd, tinggi, status, temp, wind, rain),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30 * MediaQuery.of(context).size.aspectRatio,
                  vertical: 15 * MediaQuery.of(context).size.aspectRatio,
                ),
                child: Center(
                  child: Text(
                    "Data Hari Ini",
                    style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 20 * MediaQuery.of(context).textScaleFactor,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30 * MediaQuery.of(context).size.aspectRatio),
                child: Row(
                  children: <Widget>[
                    Expanded(child: _buildData(FlutterIcons.angle_double_up, AppColors.awasAlert, max,"KETINGGIAN MAX")),
                    SizedBox(width: 20 * MediaQuery.of(context).size.aspectRatio,),
                    Expanded(child: _buildData(FlutterIcons.angle_double_down, AppColors.amanColor, min,"KETINGGIAN MIN")),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30 * MediaQuery.of(context).size.aspectRatio,
                  vertical: 20 * MediaQuery.of(context).size.aspectRatio,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20*MediaQuery.of(context).size.aspectRatio),
                      ),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(1,1),
                          spreadRadius: 3*MediaQuery.of(context).size.aspectRatio,
                          blurRadius: 3*MediaQuery.of(context).size.aspectRatio,
                        ),
                      ]
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12 * MediaQuery.of(context).size.aspectRatio),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _buildToday(AppColors.meluapAlert, "MELUAP", meluap)),
                          Expanded(child: _buildToday(AppColors.awasAlert, "AWAS", awas)),
                          Expanded(child: _buildToday(AppColors.waspadaAlert, "WASPADA", waspada)),
                        ],
                      ),
                    ),
                ),
              )
            ],
          ),
        );
  }

  Column _buildToday(Color color, String title, String value) {
    return Column(
                            children: <Widget>[
                              Icon(
                                FlutterIcons.attention_circled,
                                size: 30 * MediaQuery.of(context).textScaleFactor,
                                color: color,
                              ),
                              Text(
                                title,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 18 * MediaQuery.of(context).textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10 * MediaQuery.of(context).size.aspectRatio),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 30 * MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          );
  }

  Container _buildData(IconData icon, Color color, String value, String title) {
    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15*MediaQuery.of(context).size.aspectRatio),
                        ),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(1,1),
                            spreadRadius: 3*MediaQuery.of(context).size.aspectRatio,
                            blurRadius: 3*MediaQuery.of(context).size.aspectRatio,
                          ),
                        ]
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5 * MediaQuery.of(context).size.aspectRatio),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  icon,
                                  size: 25 * MediaQuery.of(context).textScaleFactor,
                                  color: color,
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    fontSize: 15 * MediaQuery.of(context).textScaleFactor,
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5 * MediaQuery.of(context).size.aspectRatio),
                              child: Text(
                                value + " m",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32 * MediaQuery.of(context).textScaleFactor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
  }

  Container _buildMainBanner(
    String tanggal,
    String jam,
    Color color,
    String tinggi,
    String status,
    String temp,
    String wind,
    String rain,
  ) {
    return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15*MediaQuery.of(context).size.aspectRatio),
                  ),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(1,1),
                      spreadRadius: 3*MediaQuery.of(context).size.aspectRatio,
                      blurRadius: 3*MediaQuery.of(context).size.aspectRatio,
                    ),
                  ]
                ),
                margin: EdgeInsets.symmetric(horizontal: 30 * MediaQuery.of(context).size.aspectRatio),
                padding: EdgeInsets.all(20 * MediaQuery.of(context).size.aspectRatio),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Update At,",
                        style: TextStyle(
                          color: AppColors.mainColor.withOpacity(.4),
                          fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tanggal + " " + jam,
                        style: TextStyle(
                          color: AppColors.mainColor.withOpacity(.4),
                          fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15 * MediaQuery.of(context).size.aspectRatio),
                        child: Container(
                          width: 320*MediaQuery.of(context).size.aspectRatio,
                          height: 320*MediaQuery.of(context).size.aspectRatio,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.all(
                              Radius.circular(160*MediaQuery.of(context).size.aspectRatio),
                            )
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Ketinggian air",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15 * MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  tinggi + " m",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50 * MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24 * MediaQuery.of(context).textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15 * MediaQuery.of(context).size.aspectRatio),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildWeather(FlutterIcons.temperatire, temp + " \u00b0C"),
                            _buildWeather(FlutterIcons.wind, wind + " m/s"),
                            _buildWeather(FlutterIcons.rain, rain + " mm"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
  }

  Padding _buildWeather(IconData icon, String value) {
    return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15 * MediaQuery.of(context).size.aspectRatio),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    icon,
                                    size: 20 * MediaQuery.of(context).textScaleFactor,
                                    color: AppColors.mainColor.withOpacity(.7)
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 6 * MediaQuery.of(context).size.aspectRatio),
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: AppColors.mainColor.withOpacity(.7),
                                        fontSize: 17 * MediaQuery.of(context).textScaleFactor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
  }
}