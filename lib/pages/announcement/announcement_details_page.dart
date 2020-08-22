import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_flutter/models/announcement.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailsPage extends StatefulWidget {
  @override
  _AnnouncementDetailsPageState createState() => _AnnouncementDetailsPageState();
}

class _AnnouncementDetailsPageState extends State<AnnouncementDetailsPage> {

  Announcement announcement = new Announcement.plain();
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void renderAnnouncement(String route) {
    if (route.contains("?id=")) {
      FirebaseDatabase.instance.reference().child("announcements").child(route.split("?id=")[1]).once().then((value) {
        if (value.value != null) {
          print("Official Announcement");
          setState(() {
            announcement = new Announcement.fromSnapshot(value);
            announcement.official = true;
          });
          FirebaseDatabase.instance.reference().child("users").child(announcement.author.userID).once().then((value) {
            setState(() {
              announcement.author = new User.fromSnapshot(value);
            });
            print("Announcement by " + announcement.author.toString());
          });
        }
        else {
          print("Chapter Announcement");
          FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("announcements").child(route.split("?id=")[1]).once().then((value) {
            setState(() {
              announcement = new Announcement.fromSnapshot(value);
            });
            FirebaseDatabase.instance.reference().child("users").child(announcement.author.userID).once().then((value) {
              setState(() {
                announcement.author = new User.fromSnapshot(value);
              });
              print("Announcement by " + announcement.author.toString());
            });
          });
        }
      });
      FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").child(route.split("?id=")[1]).set(DateTime.now().toString());
    }
    else {
      router.navigateTo(context, "/home/announcements", transition: TransitionType.fadeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (announcement.title == "") renderAnnouncement(ModalRoute.of(context).settings.name);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "DETAILS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                child: new Text(
                  announcement.title,
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 30, color: currTextColor),
                  textAlign: TextAlign.start,
                ),
              ),
              new Container(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new CircleAvatar(
                      radius: 25,
                      backgroundColor: announcement.author.roles.length != 0 ? roleColors[announcement.author.roles.first] : currTextColor,
                      child: new ClipRRect(
                        borderRadius: new BorderRadius.all(Radius.circular(45)),
                        child: new CachedNetworkImage(
                          imageUrl: announcement.author.profileUrl,
                          height: 45,
                          width: 45,
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Tooltip(
                          message: "Topics: ${announcement.topics}",
                          child: new Text(
                            "${announcement.author.firstName} ${announcement.author.lastName} | ${announcement.author.roles.length != 0 ? announcement.author.roles.first : ""}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20.0,
                                color: announcement.author.roles.length != 0 ? roleColors[announcement.author.roles.first] : currTextColor
                            ),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(2)),
                        new Row(
                          children: [
                            new Visibility(
                              visible: announcement.official,
                              child: new Tooltip(
                                message: "Official DECA Communication",
                                child: new Card(
                                  color: mainColor,
                                  child: new Container(
                                    padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                    child: new Text("✓  VERIFIED", style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ),
                            ),
                            new Visibility(visible: announcement.official, child: new Padding(padding: EdgeInsets.all(2))),
                            new Text(
                              "${DateFormat.yMMMd().format(announcement.date)} @ ${DateFormat.jm().format(announcement.date)}",
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              new Container(
                height: MediaQuery.of(context).size.height * 2/3,
                width: MediaQuery.of(context).size.width,
                child: new Markdown(
                  data: announcement.desc,
                  controller: controller,
                  selectable: true,
                  styleSheet: markdownStyle,
                  onTapLink: (url) {
                    launch(url);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}