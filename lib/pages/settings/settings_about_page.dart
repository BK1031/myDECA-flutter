import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsAboutPage extends StatefulWidget {
  @override
  _SettingsAboutPageState createState() => _SettingsAboutPageState();
}

class _SettingsAboutPageState extends State<SettingsAboutPage> {

  String devicePlatform = "";
  String deviceName = "";

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      devicePlatform = "iOS";
    }
    else if (Platform.isAndroid) {
      devicePlatform = "Android";
    }
    deviceName = Platform.localHostname;
  }

  launchContributeUrl() async {
    const url = 'https://github.com/equinox-initiative/myDECA-flutter';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchGuidelinesUrl() async {
    const url = 'https://github.com/equinox-initiative/myDECA-flutter/wiki/contributing';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text(
            "ABOUT",
            style: TextStyle(fontFamily: "Montserrat"),
          ),
        ),
        backgroundColor: currBackgroundColor,
        body: new SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                new Card(
                  color: currCardColor,
                  child: Column(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(top: 16.0),
                        child: new Text("device".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 18, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                      ),
                      new ListTile(
                        title: new Text("App Version", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                        trailing: new Text("$appVersion$appStatus", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                      ),
                      new ListTile(
                        title: new Text("Device Name", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                        trailing: new Text("$deviceName", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                      ),
                      new ListTile(
                        title: new Text("Platform", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                        trailing: new Text("$devicePlatform", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                      ),
                    ],
                  ),
                ),
                new Padding(padding: EdgeInsets.all(4)),
                new Card(
                  color: currCardColor,
                  child: Column(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(top: 16.0),
                        child: new Text("credits".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 18, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                      ),
                      new ListTile(
                        title: new Text("Bharat Kathi", style: TextStyle(color: currTextColor, fontSize: 17,)),
                        subtitle: new Text("App Development", style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          const url = 'https://www.instagram.com/bk1031_official';
                          launch(url);
                        },
                      ),
                      new ListTile(
                        title: new Text("Jennifer Song", style: TextStyle(color: currTextColor, fontSize: 17,)),
                        subtitle: new Text("App Development", style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          const url = 'https://www.instagram.com/jenyfur_soong/';
                          launch(url);
                        },
                      ),
                      new ListTile(
                        title: new Text("Myron Chan", style: TextStyle(color: currTextColor, fontSize: 17)),
                        subtitle: new Text("App Design", style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          const url = 'https://www.instagram.com/myronchan_/';
                          launch(url);
                        },
                      ),
                    ],
                  ),
                ),
                new Padding(padding: EdgeInsets.all(4)),
                new Card(
                  color: currCardColor,
                  child: Column(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(top: 16.0),
                        child: new Text("contributing".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                      ),
                      new ListTile(
                        title: new Text("View on GitHub", style: TextStyle(color: currTextColor, fontSize: 17,)),
                        trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                        onTap: () {
                          launchContributeUrl();
                        },
                      ),
                      new ListTile(
                        title: new Text("Contributing Guidelines", style: TextStyle(color: currTextColor, fontSize: 17,)),
                        trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                        onTap: () {
                          launchGuidelinesUrl();
                        },
                      ),
                    ],
                  ),
                ),
                new Padding(padding: EdgeInsets.all(16.0)),
                new InkWell(
                  child: new Text("© Equinox Initiative 2020", style: TextStyle(color: Colors.grey),),
                  splashColor: currBackgroundColor,
                  highlightColor: currCardColor,
                  onTap: () {
                    launch("https://equinox.bk1031.dev");
                  },
                ),
                new InkWell(
                  splashColor: currBackgroundColor,
                  highlightColor: currCardColor,
                  onTap: () {
                    launch("https://equinox.bk1031.dev");
                  },
                  child: new Image.asset(
                    'images/full_black_trans.png',
                    height: 120.0,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}