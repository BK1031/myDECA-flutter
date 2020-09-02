import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/competitive_event.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EventDetailsPage extends StatefulWidget {
  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  CompetitiveEvent event = new CompetitiveEvent();
  bool rendered = false;

  void renderEvent(String route) {
    rendered = true;
    event.id = route.split("details?id=")[1];
    FirebaseDatabase.instance.reference().child("events").child(event.id).once().then((value) {
      setState(() {
        event = new CompetitiveEvent.fromSnapshot(value);
        getCategoryColor(event.cluster);
      });
    });
  }

  void getCategoryColor(String name) {
    if (name == "Business Management") {
      eventColor = Color(0xFFfcc414);
      print("YELLOW");
    }
    else if (name == "Entrepreneurship") {
      eventColor = Color(0xFF818285);
      print("GREY");
    }
    else if (name == "Finance") {
      eventColor = Color(0xFF049e4d);
      print("GREEN");
    }
    else if (name == "Hospitality + Tourism") {
      eventColor = Color(0xFF046faf);
      print("INDIGO");
    }
    else if (name == "Marketing") {
      eventColor = Color(0xFFe4241c);
      print("RED");
    }
    else if (name == "Personal Financial Literacy") {
      eventColor = Color(0xFF7cc242);
      print("LT GREEN");
    }
    else {
      eventColor = mainColor;
      print("COLOR NOT FOUND");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!rendered) renderEvent(ModalRoute.of(context).settings.name);
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: eventColor,
          title: new Text(event.id, style: TextStyle(fontFamily: "Montserrat"),),
          elevation: 0.0,
        ),
        backgroundColor: currBackgroundColor,
        body: new Stack(
          children: <Widget>[
            new Container(
              color: eventColor,
              height: 100.0,
            ),
            new Container(
              child: new SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Card(
                      color: currCardColor,
                      child: new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                                event.name,
                                style: TextStyle(fontFamily: "Montserrat", fontSize: 25.0, color: currTextColor)
                            ),
                            new Container(
                              width: double.infinity,
                              height: 100.0,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 3,
                                    child: new Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Text(
                                          event.snapshot.value["participants"].toString(),
                                          style: TextStyle(fontSize: 35.0, color: eventColor),
                                        ),
                                        new Text(
                                          "Participants",
                                          style: TextStyle(fontSize: 15.0, color: currTextColor),
                                        )
                                      ],
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.value["pages"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Pages",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.value["presentationTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.value["prepTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes Prep",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.value["interviewTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Text(
                              event.desc,
                              style: TextStyle(fontSize: 16.0, color: currTextColor),
                            )
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4.0)),
                    new Card(
                      color: currCardColor,
                      child: new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              width: double.infinity,
                              height: 100.0,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 3,
                                    child: new InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => new Scaffold(
                                            appBar: AppBar(
                                              backgroundColor: eventColor,
                                              title: new Text("${event.id} Guidelines".toUpperCase()),
                                            ),
                                            backgroundColor: currBackgroundColor,
                                            body: new WebView(
                                              initialUrl: event.guidelines,
                                              javascriptMode: JavascriptMode.unrestricted,
                                            ),
                                          )),
                                        );
                                      },
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Icon(Icons.format_list_bulleted, size: 50.0, color: eventColor),
                                          new Text(
                                            "Guidelines",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written" || event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => new Scaffold(
                                              appBar: AppBar(
                                                backgroundColor: eventColor,
                                                title: new Text("${event.id} Sample Event".toUpperCase()),
                                              ),
                                              backgroundColor: currBackgroundColor,
                                              body: new WebView(
                                                initialUrl: event.snapshot.value["sample"],
                                                javascriptMode: JavascriptMode.unrestricted,
                                              ),
                                            )),
                                          );
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(event.type == "written" ? Icons.library_books : Icons.speaker_notes, size: 50.0, color: eventColor),
                                            new Text(
                                              "Sample Event",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => new Scaffold(
                                              appBar: AppBar(
                                                backgroundColor: eventColor,
                                                title: new Text("${event.id} Penalty Points".toUpperCase()),
                                              ),
                                              backgroundColor: currBackgroundColor,
                                              body: new WebView(
                                                initialUrl: event.snapshot.value["penalty"],
                                                javascriptMode: JavascriptMode.unrestricted,
                                              ),
                                            )),
                                          );
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.close, size: 50.0, color: eventColor),
                                            new Text(
                                              "Penalty Points",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => new Scaffold(
                                              appBar: AppBar(
                                                backgroundColor: eventColor,
                                                title: new Text("${event.id} Sample Exam".toUpperCase()),
                                              ),
                                              backgroundColor: currBackgroundColor,
                                              body: new WebView(
                                                initialUrl: event.snapshot.value["sampleExam"],
                                                javascriptMode: JavascriptMode.unrestricted,
                                              ),
                                            )),
                                          );
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.library_books, size: 50.0, color: eventColor),
                                            new Text(
                                              "Sample Exam",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "online",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          launch(event.snapshot.value["register"]);
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.open_in_new, size: 50.0, color: eventColor),
                                            new Text(
                                              "Register",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4.0)),
                    new Card(
                      color: currCardColor,
                      child: new Container(
                        width: double.infinity,
                        child: new FlatButton(
                          child: new Text("COMPETITIVE EVENTS SITE"),
                          textColor: eventColor,
                          onPressed: () {
                            launch("https://www.deca.org/high-school-programs/high-school-competitive-events");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
