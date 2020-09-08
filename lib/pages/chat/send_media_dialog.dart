import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class SendMediaDialog extends StatefulWidget {
  var image;
  String chatID;
  SendMediaDialog(this.image, this.chatID);
  @override
  _SendMediaDialogState createState() => _SendMediaDialogState(image, chatID);
}

class _SendMediaDialogState extends State<SendMediaDialog> {

  var image;
  String chatID;
  bool _uploading = false;
  double _progress = 0.0;

  final databaseRef = FirebaseDatabase.instance.reference();
  final storageRef = FirebaseStorage.instance.ref();

  _SendMediaDialogState(this.image, this.chatID);

  Future<void> uploadImage() async {
    String messageColor = "";
    setState(() {
      _uploading = true;
    });
    print("UPLOADING");
    StorageUploadTask imageUploadTask = storageRef.child(currUser.chapter.chapterID).child("chat").child("${new DateTime.now()}.png").putFile(image);
    imageUploadTask.events.listen((event) {
      print("UPLOADING: ${event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble()}");
      setState(() {
        _progress = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
      });
    });
    var downurl = await (await imageUploadTask.onComplete).ref.getDownloadURL();
    var url = downurl.toString();
    print(url);
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).push().set({
      "message": url,
      "author": currUser.userID,
      "type": "image",
      "date": DateTime.now().toString(),
      "nsfw": false
    });
    router.pop(context);
    router.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: currCardColor,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Image.file(
            image,
            width: MediaQuery.of(context).size.width * 2/3,
            height: MediaQuery.of(context).size.height * 1/2,
          ),
          new Padding(padding: EdgeInsets.all(8.0)),
          new Visibility(
            visible: !_uploading,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    child: new Text("CANCEL"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    },
                  ),
                ),
                new Expanded(
                  child: new RaisedButton.icon(
                      icon: new Icon(Icons.send),
                      label: new Text("SEND"),
                      color: mainColor,
                      textColor: Colors.white,
                      onPressed: uploadImage
                  ),
                ),
              ],
            ),
          ),
          new Visibility(
            visible: _uploading,
            child: new LinearProgressIndicator(
              value: _progress,
            ),
          )
        ],
      ),
    );
  }
}
