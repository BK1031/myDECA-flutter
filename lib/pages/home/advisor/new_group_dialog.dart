import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';


class NewGroupDialog extends StatefulWidget {
  @override
  _NewGroupDialogState createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<NewGroupDialog> {

  String id = "";
  String name = "";
  bool valid = false;

  void checkValid() {
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id).once().then((value) {
      if (value.value != null) {
        // Group with id already exists
        setState(() {
          valid = false;
        });
      }
      else {
        // Group with id doesnt exist
        setState(() {
          valid = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 350.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Visibility(
                visible: id != "",
                child: new Text(
                  "Your code will be: $id",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              new Visibility(
                visible: id.length > 0,
                child: new Text(
                  valid ? "Valid Code" : "Invalid Code",
                  style: TextStyle(color: valid ? Colors.green : Colors.red),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 190,
                    child: new TextField(
                      decoration: InputDecoration(
                        labelText: "Join Code",
                        labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                      ),
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: currTextColor),
                      onChanged: (input) {
                        id = input.toUpperCase().replaceAll(" ", "");
                        checkValid();
                      },
                    ),
                  ),
                  new IconButton(
                    icon: Icon(Icons.help, color: Colors.grey,),
                    onPressed: () {},
                    tooltip: "This is the code that members can use to join the group",
                  )
                ],
              ),
              new TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                ),
                style: TextStyle(color: currTextColor),
                textCapitalization: TextCapitalization.words,
                onChanged: (input) {
                  name = input;
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
                    child: new Text("CREATE", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      if (valid && name != "") {
                        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("groups").child(id.toUpperCase()).set({
                          "name": name
                        });
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