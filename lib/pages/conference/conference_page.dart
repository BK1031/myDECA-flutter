import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/theme.dart';

import '../app_drawer.dart';

class ConferencePage extends StatefulWidget {
  @override
  _ConferencePageState createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "CONFERENCE",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
    );
  }
}
