import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ManageGroupDialog extends StatefulWidget {
  String id;
  ManageGroupDialog(this.id);
  @override
  _ManageGroupDialogState createState() => _ManageGroupDialogState(this.id);
}

class _ManageGroupDialogState extends State<ManageGroupDialog> {

  String id;
  String name = "";
  String handbook = "";
  List<Widget> usersWidgetList = new List();
  List<Widget> handbookWidgetList = new List();

  double height = 0;

  _ManageGroupDialogState(this.id);

  void getHandbooks() {
    setState(() {
      handbookWidgetList.clear();
      handbookWidgetList.add(Container(
        padding: EdgeInsets.all(8),
        child: new Text("Select a Handbook", style: TextStyle(color: currTextColor))
      ));
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").onChildAdded.listen((event) {
      setState(() {
        handbookWidgetList.add(
            new ListTile(
              leading: (event.snapshot.value["name"] == handbook) ? Icon(Icons.radio_button_checked, color: mainColor,) : Icon(Icons.radio_button_unchecked, color: mainColor,),
              title: new Text(event.snapshot.value["name"], style: TextStyle(color: currTextColor),),
              onTap: () {
                setState(() {
                  FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id).child("handbook").set(event.snapshot.key);
                  height = 0;
                });
              },
            )
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id).onValue.listen((value) {
      setState(() {
        name = value.snapshot.value["name"];
      });
      if (value.snapshot.value["handbook"] != null) {
        String handbookID = value.snapshot.value["handbook"];
        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbookID).child("name").once().then((value) {
          setState(() {
            handbook = value.value;
          });
        });
      }
    });
    FirebaseDatabase.instance.reference().child("users").onChildAdded.listen((value) {
      User user = new User.fromSnapshot(value.snapshot);
      if (user.groups.contains(id)) {
        setState(() {
          usersWidgetList.add(new Container(
            padding: EdgeInsets.only(bottom: 4),
            child: new Card(
              color: currCardColor,
              child: Container(
                padding: EdgeInsets.all(8),
                child: new Row(
                  children: [
                    new CircleAvatar(
                      radius: 20,
                      backgroundColor: roleColors[user.roles.first],
                      child: new ClipRRect(
                        borderRadius: new BorderRadius.all(Radius.circular(45)),
                        child: new CachedNetworkImage(
                          imageUrl: user.profileUrl,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4),),
                    new Expanded(
                      child: new Column(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 25,
                    child: new RaisedButton(
                      child: Text("DELETE", style: TextStyle()),
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id).remove();
                        router.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Text(
                name,
                style: TextStyle(fontFamily: "Montserrat", fontSize: 22, color: currTextColor),
              ),
              new Text(
                id,
                style: TextStyle(color: Colors.grey),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              Row(
                children: [
                  new InkWell(
                    onTap: () {
                      if (height == 0) {
                        getHandbooks();
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
                      elevation: handbook == "" ? 0 : 1,
                      color: handbook == "" ? currCardColor : mainColor,
                      child: new Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: new Text(handbook == "" ? "Select Handbook" : handbook, style: TextStyle(color: handbook == "" ? mainColor : Colors.white),),
                      ),
                    ),
                  ),
                  new Visibility(
                    visible: handbook != "",
                    child: new IconButton(
                      icon: new Icon(Icons.clear),
                      onPressed: () {
                        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id).child("handbook").remove();
                        setState(() {
                          handbook = "";
                        });
                      },
                    )
                  )
                ],
              ),
              new AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: height,
                child: new SingleChildScrollView(
                  child: new Column(
                    children: handbookWidgetList,
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Visibility(
                visible: usersWidgetList.isEmpty,
                child: Center(child: new Text("No users have joined this group.\nPlease check again later.", style: TextStyle(color: currTextColor), textAlign: TextAlign.center,)),
              ),
              new Column(
                children: usersWidgetList,
              )
            ]
        ),
      ),
    );
  }
}