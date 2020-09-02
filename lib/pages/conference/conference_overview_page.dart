import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/conference.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ConferenceOverviewPage extends StatefulWidget {
  @override
  _ConferenceOverviewPageState createState() => _ConferenceOverviewPageState();
}

class _ConferenceOverviewPageState extends State<ConferenceOverviewPage> {

  Conference conference = new Conference.plain();

  void missingDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("File Not Found"),
          content: new Text(
            "It looks like this file may not have been added yet. Please check back later.",
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("GOT IT"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void renderConference(String route) {
    FirebaseDatabase.instance.reference().child("conferences").child(route.split("?id=")[1]).once().then((value) {
      setState(() {
        conference = new Conference.fromSnapshot(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (conference.conferenceID == "") renderConference(ModalRoute.of(context).settings.name);
    return SingleChildScrollView(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.all(8),
              child: new Text(
                "${conference.fullName.toUpperCase()}",
                style: TextStyle(fontFamily: "Montserrat", fontSize: 30, color: currTextColor),
              )
          ),
          Container(
              padding: EdgeInsets.all(8),
              child: new Text(
                "${conference.desc}",
                style: TextStyle(fontSize: 17, color: currTextColor),
              )
          ),
          Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          new Icon(Icons.event, size: 50, color: mainColor,),
                          new Padding(padding: EdgeInsets.all(4)),
                          new Text(
                            "${conference.date}",
                            style: TextStyle(fontFamily: "Montserrat",fontSize: 17, color: currTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new InkWell(
                      onTap: () {
                        launch(conference.mapUrl);
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            new Icon(Icons.location_on, size: 50, color: mainColor,),
                            new Padding(padding: EdgeInsets.all(4)),
                            new Text(
                              "${conference.location.toUpperCase()}",
                              style: TextStyle(fontFamily: "Montserrat",fontSize: 17, color: currTextColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )
          ),
          // new Container(height: 50,),
          InkWell(
            onTap: () {
              print(conference.hotelMapUrl);
              if (conference.hotelMapUrl != "") {
                launch(conference.hotelMapUrl);
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Hotel Map", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.alertsUrl);
              if (conference.alertsUrl != "") {
                launch(conference.alertsUrl);
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Announcements", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.eventsUrl);
              if (conference.eventsUrl != "") {
                launch(conference.eventsUrl);
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Competitive Event Schedule", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.siteUrl);
              if (conference.siteUrl != "") {
                launch(conference.siteUrl);
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Check out the official conference website", style: TextStyle(color: mainColor), textAlign: TextAlign.center,),
            ),
          )
        ],
      )
    );
  }
}
