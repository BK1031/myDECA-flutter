import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_flutter/models/handbook.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class HandbookPage extends StatefulWidget {
  @override
  _HandbookPageState createState() => _HandbookPageState();
}

class _HandbookPageState extends State<HandbookPage> {

  double height = 0.0;
  String selectedGroupID = "";
  String selectedGroup = "";
  bool hasHandbook = false;
  List<Widget> groupsList = new List();
  List<Widget> widgetList = new List();

  @override
  void initState() {
    super.initState();
    updateGroups();
  }

  void updateGroups() {
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").onChildAdded.listen((event) {
      if (currUser.roles.contains("Advisor") || currUser.roles.contains("President") || currUser.roles.contains("Developer") || currUser.groups.contains(event.snapshot.key)) {
        setState(() {
          groupsList.add(new ListTile(
            leading: new Icon(selectedGroup == event.snapshot.value["name"] ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: mainColor,),
            title: new Text(event.snapshot.value["name"], style: TextStyle(color: currTextColor)),
            onTap: () {
              setState(() {
                selectedGroupID = event.snapshot.key;
                selectedGroup = event.snapshot.value["name"];
                height = 0;
              });
              updateHandbookView();
            },
          ));
        });
      }
    });
  }

  Future<void> updateHandbookView() async {
    setState(() {
      widgetList.clear();
    });
    // Check if group has handbook
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(selectedGroupID).child("handbook").once().then((value) async {
      if (value.value != null) {
        print("Group has handbook");
        setState(() {
          hasHandbook = true;
        });
        String handbookID = value.value;
        if (currUser.roles.contains("Advisor") || currUser.roles.contains("President") || currUser.roles.contains("Developer") || currUser.roles.contains("Officer")) {
          // Show all users
          FirebaseDatabase.instance.reference().child("users").onChildAdded.listen((event) async {
            User user = new User.fromSnapshot(event.snapshot);
            if (user.chapter.chapterID == currUser.chapter.chapterID && user.groups.contains(selectedGroupID)) {
              // User is in chapter and selected group
              await FirebaseDatabase.instance.reference().child("chapters").child(user.chapter.chapterID).child("handbooks").child(handbookID).once().then((value) async {
                Handbook handbook = new Handbook.fromSnapshot(value);
                List<Widget> taskList = new List();
                for (int i = 0; i < handbook.tasks.length; i++) {
                  // Check is task completed
                  await FirebaseDatabase.instance.reference().child("users").child(user.userID).child("handbooks").child(handbookID).child(i.toString()).once().then((value) async {
                    if (value.value != null) {
                      // Task is completed
                      await FirebaseDatabase.instance.reference().child("users").child(value.value["checkedBy"]).once().then((value2) {
                        User checkedBy = new User.fromSnapshot(value2);
                        taskList.add(new ExpansionTile(
                          leading: Icon(Icons.check_box, color: mainColor),
                          title: new Text(handbook.tasks[i], style: TextStyle(color: currTextColor),),
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  new Container(
                                    child: new CircleAvatar(
                                      radius: 15,
                                      backgroundColor: roleColors[checkedBy.roles.first],
                                      child: new ClipRRect(
                                        borderRadius: new BorderRadius.all(Radius.circular(45)),
                                        child: new CachedNetworkImage(
                                          imageUrl: checkedBy.profileUrl,
                                          height: 26,
                                          width: 26
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Padding(padding: EdgeInsets.all(4)),
                                  new Container(
                                    child: new Text("${checkedBy.firstName} ${checkedBy.lastName}  |  ", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                  ),
                                  new Container(
                                    child: new Text("${DateFormat().add_MMMd().format(DateTime.parse(value.value["date"]))} @ ${DateFormat().add_jm().format(DateTime.parse(value.value["date"]))}", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                  )
                                ],
                              ),
                            )
                          ],
                        ));
                      });
                    }
                    else {
                      taskList.add(
                          new ListTile(
                            leading: Icon(Icons.check_box_outline_blank, color: darkMode ? Colors.grey : Colors.black54),
                            title: new Text(handbook.tasks[i], style: TextStyle(color: currTextColor),),
                          )
                      );
                    }
                  });
                }
                setState(() {
                  widgetList.add(
                    Container(
                      padding: EdgeInsets.only(bottom: 8),
                      child: new Card(
                        color: currCardColor,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: new Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  new Text(
                                    "${user.firstName} ${user.lastName} – ${handbook.name}",
                                    style: TextStyle(color: currTextColor, fontSize: 18),
                                  ),
                                ],
                              ),
                              Column(
                                children: taskList,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
              });
            }
          });
        }
        else {
          // Show just user
          await FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbookID).once().then((value) async {
            Handbook handbook = new Handbook.fromSnapshot(value);
            List<Widget> taskList = new List();
            for (int i = 0; i < handbook.tasks.length; i++) {
              // Check is task completed
              await FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("handbooks").child(handbookID).child(i.toString()).once().then((value) async {
                if (value.value != null) {
                  // Task is completed
                  await FirebaseDatabase.instance.reference().child("users").child(value.value["checkedBy"]).once().then((value2) {
                    User checkedBy = new User.fromSnapshot(value2);
                    taskList.add(new ListTile(
                        leading: Icon(Icons.check_box, color: mainColor),
                        title: new Text(handbook.tasks[i], style: TextStyle(color: currTextColor),),
                    ));
                    taskList.add(
                        Container(
                          padding: EdgeInsets.only(left: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              new Container(
                                child: new CircleAvatar(
                                  radius: 12,
                                  backgroundColor: roleColors[checkedBy.roles.first],
                                  child: new ClipRRect(
                                    borderRadius: new BorderRadius.all(Radius.circular(45)),
                                    child: new CachedNetworkImage(
                                      imageUrl: checkedBy.profileUrl,
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Container(
                                child: new Text("${checkedBy.firstName} ${checkedBy.lastName}  |  ", style: TextStyle(color: Colors.grey),),
                              ),
                              new Container(
                                child: new Text("${DateFormat().add_MMMd().add_jm().format(DateTime.parse(value.value["date"]))}", style: TextStyle(color: Colors.grey),),
                              )
                            ],
                          ),
                        )
                    );
                  });
                }
                else {
                  taskList.add(
                      new ListTile(
                        leading: Icon(Icons.check_box_outline_blank, color: darkMode ? Colors.grey : Colors.black54),
                        title: new Text(handbook.tasks[i], style: TextStyle(color: currTextColor),),
                      )
                  );
                }
              });
            }
            setState(() {
              widgetList.add(
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: new Card(
                    color: currCardColor,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new Text(
                                handbook.name,
                                style: TextStyle(color: currTextColor, fontSize: 18),
                              ),
                            ],
                          ),
                          Column(
                            children: taskList,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          });
        }
      }
      else {
        print("Group has no handbook");
        setState(() {
          hasHandbook = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "HANDBOOK",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: new Container(
        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new InkWell(
                onTap: () {
                  if (height == 0) {
                    setState(() {
                      height = 250;
                    });
                  }
                  else {
                    setState(() {
                      height = 0;
                    });
                  }
                },
                child: new Card(
                  elevation: selectedGroupID == "" ? 0 : 1,
                  color: selectedGroupID == "" ? currCardColor : mainColor,
                  child: new ListTile(
                    title: new Text(selectedGroupID == "" ? "Select Group" : selectedGroup, style: TextStyle(color: selectedGroupID == "" ? mainColor : Colors.white),),
                  ),
                ),
              ),
              new AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: height,
                child: new SingleChildScrollView(
                  child: new Column(
                    children: groupsList,
                  ),
                ),
              ),
              new Visibility(
                visible: !hasHandbook,
                child: new Container(
                  padding: EdgeInsets.all(16),
                  child: new Center(child: Text("No handbook has been added to this group.\nPlease check again later!", style: TextStyle(color: currTextColor, fontSize: 17), textAlign: TextAlign.center,),),
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Column(
                children: widgetList,
              )
            ],
          ),
        ),
      ),
    );
  }
}
