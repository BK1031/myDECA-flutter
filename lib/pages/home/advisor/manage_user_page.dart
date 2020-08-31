import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/pages/conference/conference_overview_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_flutter/pages/home/advisor/manage_group_dialog.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

import 'manage_user_roles_dialog.dart';
import 'new_group_dialog.dart';

class ManageUserPage extends StatefulWidget {
  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {

  List<Widget> usersWidgetList = new List();
  List<Widget> groupsWidgetList = new List();

  void manageRolesDialog(User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Update Roles", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new ManageUserRolesDialog(user),
          );
        }
    );
  }

  void manageGroupDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: currBackgroundColor,
            content: new ManageGroupDialog(id),
          );
        }
    );
  }

  void newGroupDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Create Group", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new NewGroupDialog(),
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("users").onValue.listen((event) {
      setState(() {
        usersWidgetList.clear();
      });
      updateUsers();
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").onValue.listen((event) {
      updateGroups();
    });
  }

  void updateUsers() {
    setState(() {
      usersWidgetList.clear();
    });
    FirebaseDatabase.instance.reference().child("users").onChildAdded.listen((event) {
      User user = new User.fromSnapshot(event.snapshot);
      print("+ ${user.userID}");
      if (user.chapter.chapterID == currUser.chapter.chapterID) {
        // In same chapter
        List<Widget> rolesList = new List();
        user.roles.forEach((element) {
          rolesList.add(new Card(
            color: roleColors[element],
            child: new Container(
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              child: new Text(element, style: TextStyle(color: Colors.white),),
            ),
          ));
        });
        setState(() {
          usersWidgetList.add(new Container(
            padding: EdgeInsets.only(bottom: 4),
            child: new InkWell(
              onTap: () {
                manageRolesDialog(user);
              },
              child: new Card(
                color: currCardColor,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
                      new Padding(padding: EdgeInsets.all(4),),
                      new CircleAvatar(
                        radius: 25,
                        backgroundColor: roleColors[user.roles.first],
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: user.profileUrl,
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8),),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(
                            user.firstName + " " + user.lastName,
                            style: TextStyle(color: currTextColor),
                          ),
                          new Text(
                            user.email,
                            style: TextStyle(color: currTextColor),
                          ),
                          new Padding(padding: EdgeInsets.all(4),),
                          Container(
                            width: MediaQuery.of(context).size.width - 114,
                            child: new Wrap(
                              direction: Axis.horizontal,
                              children: rolesList
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
        });
      }
    });
  }

  void updateGroups() {
    setState(() {
      groupsWidgetList.clear();
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").onChildAdded.listen((event) {
      setState(() {
        groupsWidgetList.add(Container(
          padding: EdgeInsets.only(bottom: 4),
          child: new Card(
            color: currCardColor,
            child: new ListTile(
              onTap: () {
                manageGroupDialog(event.snapshot.key);
              },
              title: new Text(event.snapshot.value["name"], style: TextStyle(color: currTextColor),),
              subtitle: new Text(event.snapshot.key, style: TextStyle(color: Colors.grey)),
              trailing: event.snapshot.value["handbook"] != null ? Icon(Icons.library_books, color: Colors.grey,) : Icon(Icons.crop_square, color: Colors.grey,),
            ),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "MANAGE USERS",
            style: TextStyle(fontFamily: "Montserrat"),
          ),
        ),
        body: new Container(
          color: currBackgroundColor,
          child: Column(
            children: [
              new Container(
                color: currBackgroundColor,
                height: 60,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                child: Card(
                  color: mainColor,
                  child: TabBar(
                    tabs: [
                      Tab(text: "USERS"),
                      Tab(text: "GROUPS"),
                    ],
                  ),
                ),
              ),
              new Expanded(
                child: new TabBarView(
                  children: [
                    new Container(
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: usersWidgetList,
                        ),
                      ),
                    ),
                    new Container(
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: new SingleChildScrollView(
                        child: Column(
                          children: [
                            new Column(
                              children: groupsWidgetList,
                            ),
                            new Visibility(
                              visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President"),
                              child: new Card(
                                color: currCardColor,
                                child: new ListTile(
                                  onTap: () {
                                    newGroupDialog();
                                  },
                                  leading: new Icon(Icons.add, color: mainColor,),
                                  title: new Text("New Group", style: TextStyle(color: mainColor),),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
