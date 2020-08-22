import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_flutter/models/announcement.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

import '../app_drawer.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {

  List<Announcement> announcementList = new List();
  List<String> readAnnounceIds = new List();
  List<Widget> announcementWidgetList = new List();
  int unreadAnnounce = 0;

  @override
  void initState() {
    super.initState();
    getAnnouncements();
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").onChildAdded.listen((event) {
      print(event.snapshot.value);
      readAnnounceIds.add(event.snapshot.key);
      updateWidgetList();
    });
  }

  void getAnnouncements() {
    print(DateTime.now());
    // Get Chapter announcements
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("+ " + announcement.announcementID + announcement.topics.toString());
      // Check if user can see announcement
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          print("User in topic");
          FirebaseDatabase.instance.reference().child("users").child(announcement.author.userID).once().then((value) {
            announcement.author = new User.fromSnapshot(value);
            FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once().then((value) {
              if (value.value != null) {
                announcement.read = true;
              }
              setState(() {
                announcementList.add(announcement);
              });
              updateWidgetList();
            });
          });
          break;
        }
        else {
          print("User not in topic");
        }
      }
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("announcements").onChildRemoved.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("- " + announcement.announcementID);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          var oldEntry = announcementList.singleWhere((entry) {
            return entry.announcementID == event.snapshot.key;
          });
          announcementList.removeAt(announcementList.indexOf(oldEntry));
          updateWidgetList();
        }
      }
    });
    // Get official announcements
    FirebaseDatabase.instance.reference().child("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("+ " + announcement.announcementID + announcement.topics.toString());
      // Check if user can see announcement
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          print("User in topic");
          FirebaseDatabase.instance.reference().child("users").child(announcement.author.userID).once().then((value) {
            announcement.author = new User.fromSnapshot(value);
            FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once().then((value) {
              announcement.official = true;
              if (value.value != null) {
                announcement.read = true;
              }
              setState(() {
                announcementList.add(announcement);
              });
              updateWidgetList();
            });
          });
          break;
        }
        else {
          print("User not in topic");
        }
      }
    });
    FirebaseDatabase.instance.reference().child("announcements").onChildRemoved.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("- " + announcement.announcementID);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          var oldEntry = announcementList.singleWhere((entry) {
            return entry.announcementID == event.snapshot.key;
          });
          announcementList.removeAt(announcementList.indexOf(oldEntry));
          updateWidgetList();
        }
      }
    });
  }

  void updateWidgetList() {
    announcementList.sort((a,b) {
      return b.date.compareTo(a.date);
    });
    announcementWidgetList.clear();
    print("Rebuilding Announcement Widgets");
    setState(() {
      unreadAnnounce = announcementList.length;
      print(unreadAnnounce);
      for (int i = 0; i < announcementList.length; i++) {
        if (readAnnounceIds.contains(announcementList[i].announcementID)) unreadAnnounce--;
        announcementWidgetList.add(Container(
          child: new Card(
            color: currCardColor,
            child: new InkWell(
              onTap: () {
                print(announcementList[i].announcementID);
                router.navigateTo(context, '/home/announcements/details?id=${announcementList[i].announcementID}', transition: TransitionType.native);
              },
              child: new Container(
                padding: EdgeInsets.all(8.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
//                    new Container(
//                        padding: EdgeInsets.only(left: 8, right: 16),
//                        child: new Icon(
//                          Icons.notifications_active,
//                          color: readAnnounceIds.contains(announcementList[i].announcementID) ? Colors.grey : mainColor,
//                        )
//                    ),
                    new Padding(padding: EdgeInsets.all(2.0)),
                    new Tooltip(
                      message: "${announcementList[i].author.firstName} ${announcementList[i].author.lastName}\n${announcementList[i].author.roles.first}\n${announcementList[i].author.email}",
                      child: new CircleAvatar(
                        radius: 20,
                        backgroundColor: roleColors[announcementList[i].author.roles.first],
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: announcementList[i].author.profileUrl,
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8.0)),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            child: new Text(
                              announcementList[i].title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                                color: readAnnounceIds.contains(announcementList[i].announcementID) ? currTextColor : mainColor,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              new Visibility(
                                visible: announcementList[i].official,
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
                              new Visibility(visible: announcementList[i].official, child: new Padding(padding: EdgeInsets.all(4))),
                              new Text(
                                "${DateFormat("MMMd").format(announcementList[i].date)}",
                                style: TextStyle(color: Colors.grey, fontSize: 15),
                              )
                            ],
                          ),
                          new Padding(padding: EdgeInsets.all(4.0)),
                          new Container(
                            child: new Text(
                              announcementList[i].desc,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: currTextColor
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Container(
                        child: new Icon(
                          Icons.arrow_forward_ios,
                          color: readAnnounceIds.contains(announcementList[i].announcementID) ? Colors.grey : mainColor,
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          unreadAnnounce > 0 ? "ANNOUNCEMENTS ($unreadAnnounce)" : "ANNOUNCEMENTS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      floatingActionButton: new Visibility(
        visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer"),
        child: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            router.navigateTo(context, "/home/announcements/new", transition: TransitionType.nativeModal);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              new Visibility(
                  visible: (announcementWidgetList.length == 0),
                  child: new Text("Nothing to see here!\nCheck back later for more announcements.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
              ),
              Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: announcementWidgetList,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}