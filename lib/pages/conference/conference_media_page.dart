import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ConferenceMediaPage extends StatefulWidget {
  @override
  _ConferenceMediaPageState createState() => _ConferenceMediaPageState();
}

class _ConferenceMediaPageState extends State<ConferenceMediaPage> {

  List<Widget> widgetList = new List();

  @override
  Widget build(BuildContext context) {
    if (widgetList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: new Text("Nothing to see here!\nCheck back later for media.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
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
