import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/conference.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../app_drawer.dart';

class ConferencePage extends StatefulWidget {
  @override
  _ConferencePageState createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {

  List<Conference> conferenceList = new List();
  List<Conference> pastConferenceList = new List();
  List<Widget> widgetList = new List();
  List<Widget> pastWidgetList = new List();

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("conferences").onChildAdded.listen((event) {
      Conference conference = new Conference.fromSnapshot(event.snapshot);
      print(conference.conferenceID);
      FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("conferences").child(conference.conferenceID).child("enabled").once().then((value) {
        if (value.value != null && value.value) {
          // Conference is enabled for chapter
          setState(() {
            Widget conferenceCard = new Padding(
              padding: new EdgeInsets.only(bottom: 4.0),
              child: new Card(
                color: Colors.white,
                elevation: 2.0,
                child: new InkWell(
                  onTap: () {
                    router.navigateTo(context, '/conferences/details?id=${conference.conferenceID}', transition: TransitionType.native);
                  },
                  child: new Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      new ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        child: new CachedNetworkImage(
                          placeholder: (context, url) => new Container(
                            child: new GlowingProgressIndicator(
                              child: new Image.asset('images/deca-diamond.png', height: 75.0,),
                            ),
                          ),
                          imageUrl: conference.imageUrl,
                          height: 150.0,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      new Center(
                        child: new Container(
                          height: 150.0,
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                conference.conferenceID.split("-")[1],
                                style: TextStyle(fontFamily: "Gotham", fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              new Text(
                                conference.conferenceID.split("-")[0],
                                style: TextStyle(fontSize: 22.0, color: Colors.white, decoration: TextDecoration.overline),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
            if (conference.past) {
              pastConferenceList.add(conference);
              pastWidgetList.add(conferenceCard);
            }
            else {
              conferenceList.add(conference);
              widgetList.add(conferenceCard);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "CONFERENCES",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      body: Container(
        padding: new EdgeInsets.only(left: 8, top: 8, right: 8),
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: new Text(
                      "MY CONFERENCES",
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                  )
              ),
              new Visibility(
                  visible: (conferenceList.length == 0),
                  child: new Text("Nothing to see here!\nCheck back later for conferences.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
              ),
              Container(
                child: new Column(
                  children: widgetList,
                ),
              ),
              Container(
                  padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: new Text(
                      "PAST CONFERENCES",
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                  )
              ),
              new Visibility(
                  visible: (pastConferenceList.length == 0),
                  child: new Text("Nothing to see here!\nCheck back later for conferences.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
              ),
              Container(
                child: new Column(
                  children: pastWidgetList,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
