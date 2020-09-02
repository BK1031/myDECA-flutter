import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

import '../app_drawer.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  List<Widget> widgetList = new List();

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("events").onChildAdded.listen((event) {

    });
  }

  Widget getLeadingPic(String name) {
    String imagePath = "";
    if (name == "Online") {
      imagePath = 'images/online.png';
    }
    else if (name == "Roleplay") {
      imagePath = 'images/roleplay.png';
    }
    else if (name == "Written") {
      imagePath = 'images/written.png';
    }
    return Image.asset(
      imagePath,
      height: 160.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "EVENTS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new SingleChildScrollView(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 8),
                  child: new Text("Select an event type below.", style: TextStyle(color: currTextColor, fontSize: 16))
                ),
                Center(
                  child: new Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      new Container(
                        padding: EdgeInsets.all(4.0),
                        child: new Card(
                          child: InkWell(
                            onTap: () {
                              router.navigateTo(context, '/events/type?id=Written', transition: TransitionType.native);
                            },
                            child: getLeadingPic("Written"),
                          ),
                          color: currCardColor,
                        ),
                      ),
                      new Container(
                        padding: EdgeInsets.all(4.0),
                        child: new Card(
                          child: InkWell(
                            onTap: () {
                              router.navigateTo(context, '/events/type?id=Roleplay', transition: TransitionType.native);
                            },
                            child: getLeadingPic("Roleplay"),
                          ),
                          color: currCardColor,
                        ),
                      ),
                      new Container(
                        padding: EdgeInsets.all(8.0),
                        child: new Card(
                          child: InkWell(
                            onTap: () {
                              router.navigateTo(context, '/events/type?id=Online', transition: TransitionType.native);
                            },
                            child: getLeadingPic("Online"),
                          ),
                          color: currCardColor,
                        ),
                      )
                    ]
                  ),
                )
              ],
          ),
        ),
      ),
    );
  }
}
