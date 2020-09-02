import 'package:firebase_database/firebase_database.dart';

class Chapter {
  String chapterID = "";
  String name = "";
  String school = "";
  String advisorName = "";
  String advisorCode = "";
  String city = "";

  Chapter();

  Chapter.fromSnapshot(DataSnapshot snapshot) {
    chapterID = snapshot.key;
    name = snapshot.value["name"];
    school = snapshot.value["school"];
    advisorCode = snapshot.value["advisorCode"];
    city = snapshot.value["city"];
    advisorName = (snapshot.value["advisorName"] != null) ? snapshot.value["advisorName"] : "";
  }

  @override
  String toString() {
    return "$chapterID – $name, $city – Advisor $advisorName";
  }
}