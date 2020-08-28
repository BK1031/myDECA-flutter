import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class AdvisorConferenceSelect extends StatefulWidget {
  @override
  _AdvisorConferenceSelectState createState() => _AdvisorConferenceSelectState();
}

class _AdvisorConferenceSelectState extends State<AdvisorConferenceSelect> {

  List<Widget> widgetList = new List();

  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  void updateWidget() {
    widgetList.clear();
    FirebaseDatabase.instance.reference().child("conferences").once().then((value) {
      Map<String, dynamic> map = Map.from(value.value);
      map.keys.forEach((element) {
        if (!map[element]["past"]) {
          FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("conferences").child(element).child("enabled").once().then((enabled) {
            if (enabled.value != null && enabled.value) {
              // Conference has already been enabled
              setState(() {
                widgetList.add(new ListTile(
                  leading: Icon(Icons.check_box, color: mainColor),
                  title: new Text(element, style: TextStyle(color: currTextColor),),
                  onTap: () {
                    selectConference(false, element);
                  },
                ));
              });
            }
            else {
              setState(() {
                widgetList.add(new ListTile(
                  leading: Icon(Icons.check_box_outline_blank, color: mainColor),
                  title: new Text(element, style: TextStyle(color: currTextColor)),
                  onTap: () {
                    selectConference(true, element);
                  },
                ));
              });
            }
          });
        }
      });
    });
  }

  void selectConference(bool select, String id) {
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("conferences").child(id).child("enabled").set(select);
    updateWidget();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgetList
        ),
      ),
    );
  }
}