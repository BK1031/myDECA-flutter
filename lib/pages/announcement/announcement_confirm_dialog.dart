import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/announcement.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class AnnouncementConfirmDialog extends StatefulWidget {
  final Announcement announcement;

  AnnouncementConfirmDialog(this.announcement);

  @override
  _AnnouncementConfirmDialogState createState() => _AnnouncementConfirmDialogState(announcement);
}

class _AnnouncementConfirmDialogState extends State<AnnouncementConfirmDialog> {

  Announcement announcement;

  _AnnouncementConfirmDialogState(this.announcement);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("Only users with the roles selected below will recieve this announcement."),
            new ListTile(
              leading: announcement.topics.contains("Member") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
              title: new Text("Member"),
              onTap: () {
                setState(() {
                  announcement.topics.contains("Member") ? announcement.topics.remove("Member") : announcement.topics.add("Member");
                });
              },
            ),
            new ListTile(
              leading: announcement.topics.contains("Officer") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
              title: new Text("Officer"),
              onTap: () {
                setState(() {
                  announcement.topics.contains("Officer") ? announcement.topics.remove("Officer") : announcement.topics.add("Officer");
                });
              },
            ),
            new ListTile(
              leading: announcement.topics.contains("President") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
              title: new Text("President"),
              onTap: () {
                setState(() {
                  announcement.topics.contains("President") ? announcement.topics.remove("President") : announcement.topics.add("President");
                });
              },
            ),
            new ListTile(
              leading: announcement.topics.contains("Advisor") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
              title: new Text("Advisor"),
              onTap: () {
                setState(() {
                  announcement.topics.contains("Advisor") ? announcement.topics.remove("Advisor") : announcement.topics.add("Advisor");
                });
              },
            ),
            new ListTile(
              leading: announcement.topics.contains("Developer") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
              title: new Text("Developer"),
              onTap: () {
                setState(() {
                  announcement.topics.contains("Developer") ? announcement.topics.remove("Developer") : announcement.topics.add("Developer");
                });
              },
            ),
            new Visibility(
              visible: announcement.topics.contains("Member") && !announcement.topics.contains("Advisor"),
              child: new Card(
                color: Color(0xFFffebba),
                child: new Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
                      new Icon(Icons.warning, color: Colors.orangeAccent,),
                      new Padding(padding: EdgeInsets.all(4)),
                      new Text("Advisors are not given the\nMember role by default, so\nyour advisors may not recieve\nthis announcement.", style: TextStyle(color: Colors.orangeAccent),)
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                new FlatButton(
                  child: new Text("CANCEL", style: TextStyle(color: mainColor),),
                  onPressed: () {
                    router.pop(context);
                  },
                ),
                new FlatButton(
                  child: new Text("PUBLISH", style: TextStyle(color: mainColor),),
                  onPressed: () {
                    if (announcement.topics.isNotEmpty) {
                      if (announcement.official) {
                        FirebaseDatabase.instance.reference().child("announcements").push().set({
                          "title": announcement.title,
                          "desc": announcement.desc,
                          "date": DateTime.now().toString(),
                          "author": announcement.author.userID,
                          "topics": announcement.topics
                        });
                      }
                      else {
                        FirebaseDatabase.instance.reference().child("chapters").child(announcement.author.chapter.chapterID).child("announcements").push().set({
                          "title": announcement.title,
                          "desc": announcement.desc,
                          "date": DateTime.now().toString(),
                          "author": announcement.author.userID,
                          "topics": announcement.topics
                        });
                      }
                      router.navigateTo(context, "/home/announcements", transition: TransitionType.fadeIn);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}