import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mydeca_flutter/models/announcement.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/models/version.dart';
import 'package:mydeca_flutter/pages/app_drawer.dart';
import 'package:mydeca_flutter/pages/home/join_group_dialog.dart';
import 'package:mydeca_flutter/pages/home/welcome_dialog.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'advisor/advisor_conference_select.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<Announcement> announcementList = new List();
  int unreadAnnounce = 0;

  bool rendered = false;

  List<Widget> roleWidgetList = new List();
  List<Widget> conferenceWidgetList = new List();
  List<String> groupsList = new List();

  @override
  void initState() {
    super.initState();
    // Get Session Info
    FirebaseDatabase.instance.reference().child("stableVersion").once().then((DataSnapshot snapshot) {
      Version stable = Version(snapshot.value);
      print("Current Version: $appVersion");
      print("Current Version: ${appVersion.getVersionCode()}");
      print("Stable Version: ${stable.getVersionCode()}");
      if (appVersion.getVersionCode() < stable.getVersionCode()) {
        print("OUTDATED APP!");
        appStatus = " [OUTDATED]";
        if (stable.major > appVersion.major) {
          // Minor Build Outdated
          print("Force this boi to update");
          outdatedAlert(true);
        }
        else {
          outdatedAlert(false);
        }
      }
      else if (appVersion.getVersionCode() > stable.getVersionCode()) {
        print("BETA APP!");
        appStatus = " Beta ${appVersion.getBuild()}";
        _firebaseMessaging.subscribeToTopic("Beta");
      }
      FirebaseDatabase.instance.reference().child("users").child(currUser.userID).update({
        "appVersion": "${appVersion.toString()}$appStatus",
        "deviceName": Platform.localHostname,
        "platform": Platform.operatingSystem
      });
    });
  }

  void alert(String alert) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Alert", style: TextStyle(color: currTextColor),),
          content: new Text(alert, style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("GOT IT"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  Future<void> firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: " + token);
      FirebaseDatabase.instance.reference().child("users").child(currUser.userID).update({"fcmToken": token});
    });
    firebaseSubscibeTopics();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  Future<void> firebaseSubscibeTopics() async {
    // Clear existing topics
    await _firebaseMessaging.deleteInstanceID();
    currUser.roles.forEach((role) {
      _firebaseMessaging.subscribeToTopic(role);
      print("Subscribed to $role");
      _firebaseMessaging.subscribeToTopic(currUser.chapter.chapterID + "_" + role);
      print("Subscribed to " + currUser.chapter.chapterID + "_" + role);
    });
    currUser.groups.forEach((group) {
      _firebaseMessaging.subscribeToTopic(currUser.chapter.chapterID + "_" + group);
      print("Subscribed to " + currUser.chapter.chapterID + "_" + group);
    });
  }

//   ignore: non_constant_identifier_names
  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }


  void getAnnouncements() {
    print(DateTime.now());
    // Get Chapter announcements
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once().then((value) {
            setState(() {
              announcementList.add(announcement);
            });
            if (value.value == null) {
              unreadAnnounce++;
            }
          });
          break;
        }
      };
    });
    // Get official announcements
    FirebaseDatabase.instance.reference().child("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once().then((value) {
            setState(() {
              announcementList.add(announcement);
            });
            if (value.value == null) {
              unreadAnnounce++;
            }
          });
          break;
        }
      };
    });
  }

  Future<void> updateUserGroups() async {
    print("UPDATING GROUPS");
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("groups").onChildAdded.listen((event) {
      FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(event.snapshot.value).child("name").once().then((value) {
        if (value.value != null) {
          setState(() {
            groupsList.add(value.value);
          });
        }
      });
    });
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("groups").onChildRemoved.listen((event) {
      FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(event.snapshot.value).child("name").once().then((value) {
        if (value.value != null) {
          setState(() {
            groupsList.remove(value.value);
          });
        }
      });
    });
    // FirebaseDatabase.instance.reference().child("users").child(currUser.userID).onValue.listen((value) {
    //   setState(() {
    //     currUser = User.fromSnapshot(value.snapshot);
    //   });
    //   if (!currUser.emailVerified) {
    //     welcomeDialog();
    //   }
    //   currUser.groups.forEach((element) async {
    //     setState(() {
    //       groupWidgetList.clear();
    //     });
    //     await FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(element).child("name").once().then((value) {
    //       if (value.value != null) {
    //         setState(() {
    //           groupWidgetList.add(new Card(
    //             color: mainColor,
    //             child: new Container(
    //               padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
    //               child: new Text(value.value, style: TextStyle(color: Colors.white),),
    //             ),
    //           ));
    //         });
    //       }
    //     });
    //   });
    // });
  }

  void getAdvisorInfo() {
    if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor")) {
      FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("conferences").onValue.listen((event) {
        print("value");
        updateSelectedConferences();
      });
    }
    else {
      print("Not authorized");
    }
  }

  void updateSelectedConferences() {
    print("UPDATING CONFERNECES");
    setState(() {
      conferenceWidgetList.clear();
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("conferences").onChildAdded.listen((event) {
      print("${event.snapshot.key} – ${event.snapshot.value["enabled"]}");
      if (event.snapshot.value["enabled"]) {
        FirebaseDatabase.instance.reference().child("conferences").child(event.snapshot.key).child("past").once().then((value) {
          if (value.value) {
            print("Event has already past");
          }
          else {
            setState(() {
              conferenceWidgetList.add(new Card(
                color: mainColor,
                child: new Container(
                  padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: new Text(event.snapshot.key, style: TextStyle(color: Colors.white),),
                ),
              ));
            });
          }
        });
      }
    });
  }

  void welcomeDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Welcome to myDECA!", style: TextStyle(color: currTextColor),),
            backgroundColor: currBackgroundColor,
            content: new WelcomeDialog(),
          );
        }
    );
  }

  void selectConferenceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Select Conferences", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new AdvisorConferenceSelect(),
            actions: [
              new FlatButton(
                child: new Text("DONE"),
                onPressed: () {
                  router.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  void selectGroupDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("My Groups", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new JoinGroupDialog(),
            actions: [
              new FlatButton(
                child: new Text("DONE"),
                onPressed: () {
                  router.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  void outdatedAlert(bool major) {
    if (major) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Update Required", style: TextStyle(color: currTextColor),),
              backgroundColor: currBackgroundColor,
              content: new Text(
                "It looks like you are using an outdated version of the myDECA App. Please update your app from the App Store.",
                style: TextStyle(color: currTextColor)
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("GOT IT"),
                  textColor: mainColor,
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            );
          }
      );
    }
    else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Update Available", style: TextStyle(color: currTextColor),),
              backgroundColor: currBackgroundColor,
              content: new Text(
                "It looks like you are using an outdated version of the myDECA App. Please update your app from the App Store for the best experience.",
                style: TextStyle(color: currTextColor)
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("GOT IT"),
                  textColor: mainColor,
                  onPressed: () {
                    router.pop(context);
                  },
                ),
              ],
            );
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!rendered) {
      rendered = true;
      getAnnouncements();
      updateUserGroups();
      getAdvisorInfo();
      firebaseCloudMessagingListeners();
    }
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
        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              new Text(
                "Welcome back, ${currUser.firstName}",
                style: TextStyle(fontFamily: "Montserrat", fontSize: 35, fontWeight: FontWeight.bold, color: currTextColor),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Visibility(
                visible: unreadAnnounce > 0,
                child: new Container(
                  width: double.infinity,
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Card(
                          shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: new BorderSide(color: mainColor, width: 2.0)),
                          elevation: 2.0,
                          color: currCardColor,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, '/home/announcements', transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Text(
                                  unreadAnnounce > 0 ? unreadAnnounce.toString() : announcementList.length.toString(),
                                  style: TextStyle(fontSize: 35.0, color: unreadAnnounce > 0 ? mainColor : Colors.grey),
                                ),
                                new Text(
                                  unreadAnnounce > 0 ? "New Announcements" : "Announcements",
                                  style: TextStyle(fontSize: 13.0, color: unreadAnnounce > 0 ? mainColor : currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Container(
                width: double.infinity,
                height: 100.0,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 5,
                      child: new Card(
                        elevation: 2.0,
                        color: currCardColor,
                        child: new InkWell(
                          onTap: () {
                          },
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Icon(Icons.event, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                              new Text(
                                "My Events",
                                style: TextStyle(fontSize: 13.0, color: currTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(2.0)),
                    new Expanded(
                      flex: 3,
                      child: new Card(
                        elevation: 2.0,
                        color: currCardColor,
                        child: new InkWell(
                          onTap: () {
                            if (currUser.groups.isNotEmpty) {
                              router.navigateTo(context, '/home/handbook', transition: TransitionType.native);
                            }
                            else {
                              alert("You are not a part of any groups. Please join a group to get access to your handbook.");
                            }
                          },
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Icon(Icons.library_books, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                              new Text(
                                "My Handbook",
                                style: TextStyle(fontSize: 13.0, color: currTextColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(2.0)),
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(2.0)),
              new Container(
                width: double.infinity,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 5,
                      child: new Card(
                        elevation: 2.0,
                        color: currCardColor,
                        child: new InkWell(
                          onTap: () {
                            selectGroupDialog();
                          },
                          child: Row(
                            children: [
                              new ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 100
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Icon(Icons.group, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                      new Text(
                                        "My Groups",
                                        style: TextStyle(fontSize: 13.0, color: currTextColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              new Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: new Wrap(
                                    direction: Axis.horizontal,
                                    children: groupsList.map((e) => new Card(
                                      color: mainColor,
                                      child: new Container(
                                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                        child: new Text(e, style: TextStyle(color: Colors.white),),
                                      ),
                                    )).toList()
                                  ),
                                ),
                              ),
                              new Visibility(
                                visible: currUser.groups.isEmpty,
                                child: Container(
                                  child: new Text(
                                    "It looks like you are not part of any\ngroups. Click on this card to join a group.",
                                    style: TextStyle(color: currTextColor),
                                  ),
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(8))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(2.0)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Officer"),
                child: new Container(
                  width: double.infinity,
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 3,
                        child: new Card(
                          color: currCardColor,
                          elevation: 2.0,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, '/home/notification-manager', transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Icon(Icons.notifications_active, size: 35.0, color: darkMode ? Colors.grey : Colors.black54,),
                                new Text(
                                  "Send Notification",
                                  style: TextStyle(fontSize: 13.0, color: currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(2.0)),
                      new Expanded(
                        flex: 5,
                        child: new Card(
                          elevation: 2.0,
                          color: currCardColor,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, "/home/manage-users", transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Icon(Icons.supervised_user_circle, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                new Text(
                                  "Manage Users",
                                  style: TextStyle(fontSize: 13.0, color: currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(2)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor"),
                child: new Padding(padding: EdgeInsets.only(top: 8, bottom: 8), child: new Divider(color: currDividerColor, height: 8))
              ),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor"),
                child: new Container(
                  width: double.infinity,
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 5,
                        child: new Card(
                          elevation: 2.0,
                          color: currCardColor,
                          child: new InkWell(
                            onTap: () {
                              selectConferenceDialog();
                            },
                            child: Row(
                              children: [
                                new ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: 100
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 16, right: 16),
                                    child: new Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Icon(Icons.event, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                        new Text(
                                          "My Conferences",
                                          style: TextStyle(fontSize: 13.0, color: currTextColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                new Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: new Wrap(
                                      direction: Axis.horizontal,
                                      children: conferenceWidgetList,
                                    ),
                                  ),
                                ),
                                new Visibility(
                                  visible: conferenceWidgetList.isEmpty,
                                  child: Container(
                                    child: new Text(
                                      "No conferences selected for this\nchapter. Click on this card to add\na conference.",
                                      style: TextStyle(color: currTextColor),
                                    ),
                                  ),
                                ),
                                new Padding(padding: EdgeInsets.all(8))
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(2.0)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor"),
                child: new Container(
                  width: double.infinity,
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 5,
                        child: new Card(
                          elevation: 2.0,
                          color: currCardColor,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, '/home/handbook/manage', transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Icon(Icons.library_books, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                new Text(
                                  "Manage Handbooks",
                                  style: TextStyle(fontSize: 13.0, color: currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(2.0)),
                      new Expanded(
                        flex: 3,
                        child: new Card(
                          elevation: 2.0,
                          color: currCardColor,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, "/home/manage-users", transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Icon(Icons.supervised_user_circle, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                new Text(
                                  "Manage Users",
                                  style: TextStyle(fontSize: 13.0, color: currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(2.0)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor"),
                child: new Container(
                  width: double.infinity,
                  height: 100.0,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 3,
                        child: new Card(
                          color: currCardColor,
                          elevation: 2.0,
                          child: new InkWell(
                            onTap: () {
                              router.navigateTo(context, '/home/notification-manager', transition: TransitionType.native);
                            },
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Icon(Icons.notifications_active, size: 35.0, color: darkMode ? Colors.grey : Colors.black54,),
                                new Text(
                                  "Send Notification",
                                  style: TextStyle(fontSize: 13.0, color: currTextColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(2.0)),
                      new Expanded(
                        flex: 5,
                        child: new Card(),
                      )
                    ],
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(16))
            ],
          ),
        ),
      ),
    );
  }
}
