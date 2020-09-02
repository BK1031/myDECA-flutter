import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class HandbookDetailsPage extends StatefulWidget {
  @override
  _HandbookDetailsPageState createState() => _HandbookDetailsPageState();
}

class _HandbookDetailsPageState extends State<HandbookDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "DETAILS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: [

            ],
          ),
        ),
      ),
    );
  }
}
