import 'package:firebase_database/firebase_database.dart';

class CompetitiveEvent {
  String id = "";
  String name = "";
  String desc = "";
  String type = "";
  String cluster = "";
  String guidelines = "";
  DataSnapshot snapshot;

  CompetitiveEvent();

  CompetitiveEvent.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.value["name"];
    desc = snapshot.value["desc"];
    type = snapshot.value["type"];
    cluster = snapshot.value["cluster"];
    guidelines = snapshot.value["guidelines"];
    this.snapshot = snapshot;
  }
}