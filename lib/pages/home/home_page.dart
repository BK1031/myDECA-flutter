import 'package:flutter/material.dart';
import 'package:mydeca_flutter/pages/app_drawer.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "HOME",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new Column(
          children: [
            new Text(
              "Welcome back, ${currUser.firstName}",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 35, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
