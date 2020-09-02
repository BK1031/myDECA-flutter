import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/handbook.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ManageHandbookPage extends StatefulWidget {
  @override
  _ManageHandbookPageState createState() => _ManageHandbookPageState();
}

class _ManageHandbookPageState extends State<ManageHandbookPage> {

  List<Widget> handbookWidgetList = new List();
  List<Widget> taskWidgetList = new List();
  bool editing = false;
  bool editingTask = false;

  Handbook newHandbook = new Handbook.plain();
  String tempTask = "";

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").onValue.listen((event) {
      updateHandbooks();
    });
  }

  void updateNewHandbook() {
    setState(() {
      taskWidgetList.clear();
    });
    for (int i = 0; i < newHandbook.tasks.length; i++) {
      setState(() {
        taskWidgetList.add(
            new ListTile(
                leading: Icon(Icons.check_box_outline_blank, color: darkMode ? Colors.grey : Colors.black54),
                title: new Text(newHandbook.tasks[i], style: TextStyle(color: currTextColor),),
                trailing: new IconButton(
                  icon: Icon(Icons.clear, color: darkMode ? Colors.grey : Colors.black54),
                  onPressed: () {
                    newHandbook.tasks.removeAt(i);
                    updateNewHandbook();
                  },
                )
            )
        );
      });
    }
  }

  void updateHandbooks() {
    setState(() {
      handbookWidgetList.clear();
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").onChildAdded.listen((event) {
      Handbook handbook = new Handbook.fromSnapshot(event.snapshot);
      List<Widget> taskList = new List();
      for (int i = 0; i < handbook.tasks.length; i++) {
        taskList.add(
            new ListTile(
              leading: Icon(Icons.check_box_outline_blank, color: darkMode ? Colors.grey : Colors.black54),
              title: new Text(handbook.tasks[i], style: TextStyle(color: currTextColor),),
            )
        );
      }
      setState(() {
        handbookWidgetList.add(
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
                        new Visibility(
                          visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President"),
                          child: new RaisedButton(
                            color: Colors.red,
                            child: Text("DELETE"),
                            textColor: Colors.white,
                            onPressed: () {
                              if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President")) {
                                FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbook.handbookID).remove();
                              }
                            },
                          ),
                        )
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "HOME",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: Container(
        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              new Visibility(
                visible: editing,
                child: Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: new Card(
                    color: currCardColor,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        children: [
                          new TextField(
                            decoration: InputDecoration(
                              labelText: "Handbook Name",
                              labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                            ),
                            style: TextStyle(color: currTextColor, fontSize: 17.0),
                            onChanged: (input) {
                              newHandbook.name = input;
                            },
                          ),
                          Column(
                            children: taskWidgetList,
                          ),
                          new Visibility(
                            visible: editingTask,
                            child: Container(
                              height: 75,
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  new Expanded(
                                    child: new TextField(
                                      decoration: InputDecoration(
                                          labelText: "Task Name",
                                          labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                                      ),
                                      autofocus: true,
                                      style: TextStyle(color: currTextColor, fontSize: 17.0),
                                      onChanged: (input) {
                                        tempTask = input;
                                      },
                                    ),
                                  ),
                                  Container(
                                    child: new RaisedButton(
                                      color: mainColor,
                                      child: new Text("ADD"),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          newHandbook.tasks.add(tempTask);
                                          editingTask = false;
                                        });
                                        updateNewHandbook();
                                      },
                                    ),
                                  ),
                                  new IconButton(
                                    icon: new Icon(Icons.clear, color: Colors.grey,),
                                    onPressed: () {
                                      setState(() {
                                        editingTask = false;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          new Visibility(
                            visible: !editingTask,
                            child: new ListTile(
                              onTap: () {
                                setState(() {
                                  editingTask = true;
                                });
                              },
                              leading: new Icon(Icons.add, color: mainColor,),
                              title: new Text("New Item", style: TextStyle(color: mainColor),),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              new FlatButton(
                                child: new Text("CANCEL", style: TextStyle(color: mainColor),),
                                onPressed: () {
                                  setState(() {
                                    editing = false;
                                  });
                                },
                              ),
                              new FlatButton(
                                child: new Text("CREATE", style: TextStyle(color: mainColor),),
                                onPressed: () {
                                  if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President")) {
                                    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("handbooks").push().set({
                                      "name": newHandbook.name,
                                      "tasks": newHandbook.tasks
                                    });
                                    // Reset new handbook
                                    newHandbook = new Handbook.plain();
                                    updateNewHandbook();
                                    setState(() {
                                      editingTask = false;
                                      editing = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                  visible: (handbookWidgetList.length == 0 && !editing),
                  child: new Text("Nothing to see here!\nCreate a new handbook below.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
              ),
              Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: handbookWidgetList,
                ),
              ),
              new Visibility(
                visible: !editing && (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President")),
                child: Container(
                  child: new Card(
                    color: currCardColor,
                    child: new ListTile(
                      onTap: () {
                        setState(() {
                          editing = true;
                        });
                      },
                      leading: new Icon(Icons.add, color: mainColor,),
                      title: new Text("New Handbook", style: TextStyle(color: mainColor),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}