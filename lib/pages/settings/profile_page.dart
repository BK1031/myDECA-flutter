import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydeca_flutter/models/chapter.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<Widget> roleWidgetList = new List();
  final storageRef = FirebaseStorage.instance.ref();

  bool uploading = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < currUser.roles.length; i++) {
      print(currUser.roles[i]);
      roleWidgetList.add(new Card(
        color: roleColors[currUser.roles[i]],
        child: new Container(
          padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
          child: new Text(currUser.roles[i], style: TextStyle(color: Colors.white),),
        ),
      ));
    }
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).once().then((value) {
      setState(() {
        currUser.chapter = new Chapter.fromSnapshot(value);
      });
    });
  }

  Future<void> pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 512,
        maxWidth: 512,
      );
      if (croppedImage != null) {
        setState(() {
          uploading = true;
        });
        print("UPLOADING");
        StorageUploadTask imageUploadTask = storageRef.child("users").child("${currUser.userID}.png").putFile(croppedImage);
        imageUploadTask.events.listen((event) {
          print("UPLOADING: ${event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble()}");
          setState(() {
            progress = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
          });
        });
        var downurl = await (await imageUploadTask.onComplete).ref.getDownloadURL();
        var url = downurl.toString();
        print(url);
        FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("profileUrl").set(url);
        setState(() {
          currUser.profileUrl = url;
          uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "PROFILE",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      body: new Container(
        padding: EdgeInsets.all(8),
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              new Padding(padding: EdgeInsets.all(16)),
              new ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: new CachedNetworkImage(
                  imageUrl: currUser.profileUrl,
                  height: 100,
                  width: 100,
                ),
              ),
              new Visibility(
                visible: uploading,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: new LinearProgressIndicator(
                    value: progress,
                  ),
                ),
              ),
              new Visibility(
                visible: !uploading,
                child: new FlatButton(
                  child: new Text("Edit Picture"),
                  textColor: mainColor,
                  onPressed: () {
                    pickImage();
                  }
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Text(
                currUser.firstName + " " + currUser.lastName,
                style: TextStyle(fontSize: 25, color: currTextColor),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Wrap(
                  direction: Axis.horizontal,
                  children: roleWidgetList
              ),
              new ListTile(
                leading: new Icon(currUser.emailVerified ? Icons.verified_user : Icons.mail, color: darkMode ? Colors.grey : Colors.black54),
                title: new Text(currUser.email, style: TextStyle(color: currTextColor),),
              ),
              new ListTile(
                leading: new Icon(Icons.school, color: darkMode ? Colors.grey : Colors.black54),
                title: new Text("${currUser.chapter.school}", style: TextStyle(color: currTextColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
