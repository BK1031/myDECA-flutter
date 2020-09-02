import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/competitive_event.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class EventTypePage extends StatefulWidget {
  @override
  _EventTypePageState createState() => _EventTypePageState();
}

class _EventTypePageState extends State<EventTypePage> {

  String type = "";
  bool rendered = false;

  List<String> clusters = new List();
  List<Widget> clusterList = new List();

  renderClusters(String route) {
    rendered = true;
    setState(() {
      type = route.split("?id=")[1];
    });
    FirebaseDatabase.instance.reference().child("events").onChildAdded.listen((snapshot) {
      CompetitiveEvent event = CompetitiveEvent.fromSnapshot(snapshot.snapshot);
      if (event.type == type.toLowerCase() && !clusters.contains(event.cluster)) {
        setState(() {
          clusterList.add(new Container(
              padding: EdgeInsets.only(bottom: 8.0),
              child: new Card(
                color: currCardColor,
                child: new ListTile(
                  onTap: () {
                    print(event.cluster);
                    router.navigateTo(context, '/events/type?id=$type/cluster?id=${event.cluster}', transition: TransitionType.native);
                  },
                  leading: getLeadingPic(event.cluster),
                  title: new Text(
                    event.cluster,
                    style: TextStyle(
                      color: currTextColor
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: mainColor,),
                ),
              )
          ));
        });
        clusters.add(event.cluster);
      }
    });
  }

  Widget getLeadingPic(String name) {
    String imagePath = "";
    if (name == "Business Management") {
      imagePath = 'images/business.png';
    }
    else if (name == "Entrepreneurship") {
      imagePath = 'images/entrepreneurship.png';
    }
    else if (name == "Finance") {
      imagePath = 'images/finance.png';
    }
    else if (name == "Hospitality + Tourism") {
      imagePath = 'images/hospitality.png';
    }
    else if (name == "Marketing") {
      imagePath = 'images/marketing.png';
    }
    else if (name == "Personal Financial Literacy") {
      imagePath = 'images/personal-finance.png';
    }
    return Image.asset(
      imagePath,
      height: 35.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!rendered) renderClusters(ModalRoute.of(context).settings.name);
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          type.toUpperCase(),
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
                  child: new Text("Select an event cluster below.", style: TextStyle(color: currTextColor, fontSize: 16))
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: new Column(
                  children: clusterList,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
