import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class AltAppDrawer extends StatefulWidget {
  @override
  _AltAppDrawerState createState() => _AltAppDrawerState();
}

class _AltAppDrawerState extends State<AltAppDrawer> {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Scaffold(
        backgroundColor: mainColor,
        body: new SafeArea(
          child: new Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Padding(padding: EdgeInsets.all(16)),
                      new ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: new CachedNetworkImage(
                          imageUrl: currUser.profileUrl,
                          height: 100,
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Text(
                        currUser.firstName + " " + currUser.lastName,
                        style: TextStyle(color: Colors.white, fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      new FlatButton(
                        child: new Text("View Profile"),
                        textColor: Colors.grey,
                        onPressed: () {

                        },
                      ),
                    ],
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new ListTile(
                      leading: Icon(Icons.message, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Announcements", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {

                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
