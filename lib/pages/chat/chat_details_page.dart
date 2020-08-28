import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ChatDetailsPage extends StatefulWidget {
  @override
  _ChatDetailsPageState createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {

  String chatName = "";
  String chatID = "";
  String chatType = "";
  bool rendered = false;
  List<Widget> usersList = new List();

  void renderDetails(String route) {
    rendered = true;
    chatID = route.split("?id=")[1];
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).child("name").once().then((value) {
      setState(() {
        chatName = value.value;
      });
    });
    FirebaseDatabase.instance.reference().child("users").onChildAdded.listen((event) {
      User user = new User.fromSnapshot(event.snapshot);
      if (chatID == "General" && user.chapter.chapterID == currUser.chapter.chapterID) {
        setState(() {
          chatType = "Chapter";
          usersList.add(new Container(
            child: new InkWell(
              child: new Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
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
                              user.firstName + " " + user.lastName
                          ),
                          new Text(
                              user.email
                          )
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
      if (user.chapter.chapterID == currUser.chapter.chapterID && user.roles.contains(route.split("?id=")[1])) {
        // User in Role Chat
        setState(() {
          chatType = "Role";
          usersList.add(new Container(
            child: new InkWell(
              child: new Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
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
                              user.firstName + " " + user.lastName
                          ),
                          new Text(
                              user.email
                          )
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
      else if (user.chapter.chapterID == currUser.chapter.chapterID && user.groups.contains(route.split("?id=")[1])) {
        // User in GRoup chat
        setState(() {
          chatType = "Group";
          usersList.add(new Container(
            child: new InkWell(
              child: new Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
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
                              user.firstName + " " + user.lastName
                          ),
                          new Text(
                              user.email
                          )
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

  @override
  Widget build(BuildContext context) {
    if (!rendered) renderDetails(ModalRoute.of(context).settings.name);
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "DETAILS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: new Container(
        padding: new EdgeInsets.all(8),
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: new Text(
                      "$chatName".toUpperCase(),
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                  )
              ),
              new ListTile(
                leading: new Text(
                    "Chat ID",
                    style: TextStyle(fontSize: 17, color: currTextColor)
                ),
                trailing: new Text(
                    "$chatID",
                    style: TextStyle(fontSize: 17, color: currTextColor)
                ),
              ),
              new ListTile(
                leading: new Text(
                    "Chat Type",
                    style: TextStyle(fontSize: 17, color: currTextColor)
                ),
                trailing: new Text(
                    "$chatType",
                    style: TextStyle(fontSize: 17, color: currTextColor)
                ),
              ),
              Container(
                  child: new Text(
                    "USERS",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                  )
              ),
              Container(
                  child: new Column(
                    children: usersList,
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
