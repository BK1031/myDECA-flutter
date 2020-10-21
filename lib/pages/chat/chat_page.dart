import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import '../app_drawer.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  List<Widget> widgetList = new List();

  @override
  void initState() {
    super.initState();
    setState(() {
      widgetList.add(new ListTile(
        title: new Text("General", style: TextStyle(fontSize: 17, color: currTextColor),),
        trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
        onTap: () {
          router.navigateTo(context, "/chat/view?id=General", transition: TransitionType.native);
        },
      ));
    });
    currUser.roles.reversed.forEach((element) {
      if (element == "Advisor") {
        setState(() {
          widgetList.add(new ListTile(
            title: new Text("Officer", style: TextStyle(fontSize: 17, color: currTextColor),),
            trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
            onTap: () {
              router.navigateTo(context, "/chat/view?id=Officer", transition: TransitionType.native);
            },
          ));
        });
      }
      if (element != "Member" && element != "President" && element != "Advisor") {
        setState(() {
          widgetList.add(new ListTile(
            title: new Text(element, style: TextStyle(fontSize: 17, color: currTextColor),),
            trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
            onTap: () {
              router.navigateTo(context, "/chat/view?id=$element", transition: TransitionType.native);
            },
          ));
        });
      }
    });
    setState(() {
      widgetList.add(Container(
          padding: new EdgeInsets.all(8),
          child: new Text(
              "MY GROUPS",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
          )
      ));
    });
    currUser.groups.forEach((element) {
      FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(element).child("name").once().then((value) {
        setState(() {
          widgetList.add(new ListTile(
            title: new Text(value.value, style: TextStyle(fontSize: 17, color: currTextColor),),
            trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
            onTap: () {
              router.navigateTo(context, "/chat/view?id=$element", transition: TransitionType.native);
            },
          ));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "CHAT",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: widgetList
          ),
        ),
      ),
    );
  }
}
