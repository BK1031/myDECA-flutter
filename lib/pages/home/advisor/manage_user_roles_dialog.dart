import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ManageUserRolesDialog extends StatefulWidget {
  User user;
  ManageUserRolesDialog(this.user);
  @override
  _ManageUserRolesDialogState createState() => _ManageUserRolesDialogState(this.user);
}

class _ManageUserRolesDialogState extends State<ManageUserRolesDialog> {

  User user;
  List<Widget> widgetList = new List();

  Map<String, bool> rolesMap = {
    "Developer": false,
    "Advisor": false,
    "President": false,
    "Officer": false,
    "Member": false
  };

  _ManageUserRolesDialogState(this.user);

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("users").child(user.userID).child("roles").onValue.listen((event) {
      updateRoles();
    });
  }

  void updateRoles() {
    FirebaseDatabase.instance.reference().child("users").child(user.userID).child("roles").onChildAdded.listen((event) {
      setState(() {
        rolesMap[event.snapshot.value] = true;
      });
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
              new Visibility(
                visible: currUser.roles.contains("Developer"),
                child: new ListTile(
                  title: new Text("Developer", style: TextStyle(color: currTextColor)),
                  leading: Icon(rolesMap["Developer"] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                  onTap: () {
                    setState(() {
                      rolesMap["Developer"] = !rolesMap["Developer"];
                    });
                  },
                ),
              ),
              new Visibility(
                visible: currUser.roles.contains("Advisor") || currUser.roles.contains("Developer"),
                child: new ListTile(
                  title: new Text("Advisor", style: TextStyle(color: currTextColor)),
                  leading: Icon(rolesMap["Advisor"] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                  onTap: () {
                    setState(() {
                      rolesMap["Advisor"] = !rolesMap["Advisor"];
                    });
                  },
                ),
              ),
              new Visibility(
                visible: currUser.roles.contains("Advisor") || currUser.roles.contains("Developer") || currUser.roles.contains("President"),
                child: new ListTile(
                  title: new Text("President", style: TextStyle(color: currTextColor)),
                  leading: Icon(rolesMap["President"] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                  onTap: () {
                    setState(() {
                      rolesMap["President"] = !rolesMap["President"];
                    });
                  },
                ),
              ),
              new Visibility(
                visible: currUser.roles.contains("Advisor") || currUser.roles.contains("Developer") || currUser.roles.contains("President") || currUser.roles.contains("Officer"),
                child: new ListTile(
                  title: new Text("Officer", style: TextStyle(color: currTextColor)),
                  leading: Icon(rolesMap["Officer"] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                  onTap: () {
                    setState(() {
                      rolesMap["Officer"] = !rolesMap["Officer"];
                    });
                  },
                ),
              ),
              new ListTile(
                title: new Text("Member", style: TextStyle(color: currTextColor)),
                leading: Icon(rolesMap["Member"] ? Icons.check_box : Icons.check_box_outline_blank, color: mainColor,),
                onTap: () {
                  setState(() {
                    if (rolesMap["Advisor"]) {
                      rolesMap["Member"] = !rolesMap["Member"];
                    }
                    else {
                      rolesMap["Member"] = true;
                    }
                  });
                },
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
                    child: new Text("OK", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      FirebaseDatabase.instance.reference().child("users").child(user.userID).child("roles").remove();
                      List<String> list = new List();
                      rolesMap.keys.forEach((key) {
                        if (rolesMap[key]){
                          list.add(key);
                        }
                      });
                      if (list.isNotEmpty) {
                        FirebaseDatabase.instance.reference().child("users").child(user.userID).child("roles").set(list);
                        router.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
}