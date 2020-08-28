import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class JoinGroupDialog extends StatefulWidget {
  @override
  _JoinGroupDialogState createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {

  List<Widget> widgetList = new List();

  String joinCode = "";

  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).onValue.listen((value) {
      print("rebuilding");
      setState(() {
        widgetList.clear();
        currUser = User.fromSnapshot(value.snapshot);
      });
      for (int i = 0; i < currUser.groups.length; i++) {
        print(currUser.groups[i]);
        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(currUser.groups[i]).child("name").once().then((value) {
          if (value.value != null) {
            setState(() {
              widgetList.add(new ListTile(
                  title: new Text(value.value, style: TextStyle(color: currTextColor),),
                  trailing: new IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      currUser.groups.removeAt(i);
                      print(currUser.groups);
                      FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("groups").set(currUser.groups);
                    },
                  )
              ));
            });
          }
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
              new Column(
                children: widgetList,
              ),
              new Padding(padding: EdgeInsets.all(16)),
              new Text("Join a Group", style: TextStyle(color: currTextColor, fontSize: 20),),
              new Visibility(
                visible: joinCode == "INVALID",
                child: new Text("Invalid Code", style: TextStyle(color: Colors.red),),
              ),
              Container(
                height: 65,
                child: Row(
                  children: [
                    new Expanded(
                      child: new TextField(
                        controller: _controller,
                        style: TextStyle(color: currTextColor, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: "Join Code",
                          labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (input) {
                          setState(() {
                            joinCode = input;
                          });
                        },
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    Container(
                      width: 75,
                      child: new RaisedButton(
                        color: mainColor,
                        textColor: Colors.white,
                        child: new Text("JOIN"),
                        onPressed: () {
                          if (joinCode != "" && !currUser.groups.contains(joinCode)) {
                            FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(joinCode).once().then((value) {
                              if (value.value != null) {
                                currUser.groups.add(joinCode);
                                FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("groups").set(currUser.groups);
                                _controller.clear();
                                joinCode = "";
                              }
                              else {
                                setState(() {
                                  joinCode = "INVALID";
                                });
                              }
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ]
        ),
      ),
    );
  }
}