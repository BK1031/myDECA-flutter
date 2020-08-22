
import 'package:firebase_database/firebase_database.dart';
import 'package:mydeca_flutter/models/user.dart';

class Announcement {
  String announcementID  = "";
  String title = "";
  String desc = "";
  DateTime date = new DateTime.now();
  User author = new User.plain();
  bool read = false;
  bool official = false;
  List<String> topics = new List();

  Announcement.plain();

  Announcement.fromSnapshot(DataSnapshot snapshot) {
    announcementID = snapshot.key;
    title = snapshot.value["title"];
    desc = snapshot.value["desc"];
    date = DateTime.parse(snapshot.value["date"]);
    author.userID = snapshot.value["author"];
    for (int i = 0; i < snapshot.value["topics"].length; i++) {
      topics.add(snapshot.value["topics"][i]);
    }
  }
}