import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/competitive_event.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class EventClusterPage extends StatefulWidget {
  @override
  _EventClusterPageState createState() => _EventClusterPageState();
}

class _EventClusterPageState extends State<EventClusterPage> {

  String cluster = "";
  String type = "";
  List<Widget> eventsList = new List();
  bool rendered = false;

  renderEvents(String route) {
    rendered = true;
    setState(() {
      type = route.split("?id=")[1].split("/")[0];
      cluster = route.split("?id=")[2];
      getCategoryColor(cluster);
    });
    FirebaseDatabase.instance.reference().child("events").onChildAdded.listen((snapshot) {
      CompetitiveEvent event = CompetitiveEvent.fromSnapshot(snapshot.snapshot);
      if (event.type == type.toLowerCase() && event.cluster == cluster) {
        setState(() {
          eventsList.add(new Container(
              padding: EdgeInsets.only(bottom: 8.0),
              child: new Card(
                color: currCardColor,
                child: new ListTile(
                  onTap: () {
                    print(event.id);
                    router.navigateTo(context, '/events/type?id=$type/cluster?id=${event.cluster}/details?id=${event.id}', transition: TransitionType.native);
                  },
                  leading: new Text(
                    event.id,
                    style: TextStyle(color: eventColor, fontSize: 17.0, fontWeight: FontWeight.bold, fontFamily: "Montserrat"),
                  ),
                  title: new Text(
                    event.name,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: currTextColor, fontWeight: FontWeight.normal),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: eventColor),
                ),
              )
          ));
        });
      }
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
    if (!rendered) renderEvents(ModalRoute.of(context).settings.name);
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: eventColor,
        title: new Text(
          cluster.toUpperCase(),
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.only(top: 8),
                  child: new Text("Select an event below.", style: TextStyle(color: currTextColor, fontSize: 16))
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: new Column(
                  children: eventsList,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
