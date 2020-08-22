import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/conference_agenda_item.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ConferenceSchedulePage extends StatefulWidget {
  @override
  _ConferenceSchedulePageState createState() => _ConferenceSchedulePageState();
}

class _ConferenceSchedulePageState extends State<ConferenceSchedulePage> {

  List<ConferenceAgendaItem> agendaList = new List();
  List<Widget> widgetList = new List();
  bool rendered = false;

  @override
  void initState() {
    super.initState();
  }

  void renderConference(String route) {
    rendered = true;
    FirebaseDatabase.instance.reference().child("conferences").child(route.split("?id=")[1]).child("agenda").onChildAdded.listen((event) {
      setState(() {
        ConferenceAgendaItem agendaItem = ConferenceAgendaItem.fromSnapshot(event.snapshot);
        agendaList.add(agendaItem);
        widgetList.add(new Container(
          padding: EdgeInsets.only(bottom: 4.0),
          child: new Card(
            color: currCardColor,
            elevation: 2.0,
            child: new Container(
              padding: EdgeInsets.all(16.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                      padding: EdgeInsets.all(8.0),
                      child: new Text(
                        agendaItem.time,
                        style: TextStyle(color: mainColor, fontSize: 17.0, fontWeight: FontWeight.bold, fontFamily: "Gotham"),
                      )
                  ),
                  new Padding(padding: EdgeInsets.all(8.0)),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          child: new Text(
                            agendaItem.title,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(2.0)),
                        new Container(
                          child: new Text(
                            agendaItem.location,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    child: new Icon(
                      Icons.arrow_forward_ios,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!rendered) renderConference(ModalRoute.of(context).settings.name);
    if (widgetList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: new Text("Nothing to see here!\nCheck back later for schedule.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
      );
    }
    else {
      return Container(
        padding: EdgeInsets.all(8),
        child: new SingleChildScrollView(
          child: new Column(
              children: widgetList
          ),
        )
      );
    }
  }
}
