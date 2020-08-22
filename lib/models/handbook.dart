import 'package:firebase_database/firebase_database.dart';

class Handbook {

  String handbookID = "";
  String name = "";
  List<String> tasks = new List();

  Handbook.plain();

  Handbook.fromSnapshot(DataSnapshot snapshot) {
    handbookID = snapshot.key;
    name = snapshot.value["name"];
    if (snapshot.value["tasks"] != null) {
      for (int i = 0; i < snapshot.value["tasks"].length; i++) {
        tasks.add(snapshot.value["tasks"][i]);
      }
    }
  }
}