import 'package:firebase_database/firebase_database.dart';
import 'chapter.dart';

class User {
  String userID = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  bool emailVerified = false;
  String profileUrl = "";
  String gender = "Male";
  List<String> roles = new List();
  List<String> groups = new List();
  int grade = 9;
  int yearsMember = 0;
  String shirtSize = "M";
  Chapter chapter = new Chapter();

  User.plain();

  User.fromSnapshot(DataSnapshot snapshot) {
    userID = snapshot.key;
    firstName = snapshot.value["firstName"];
    lastName = snapshot.value["lastName"];
    email = snapshot.value["email"];
    emailVerified = snapshot.value["emailVerified"];
    profileUrl = snapshot.value["profileUrl"];
    gender = snapshot.value["gender"];
    grade = snapshot.value["grade"];
    yearsMember = snapshot.value["yearsMember"];
    shirtSize = snapshot.value["shirtSize"];
    chapter.chapterID = snapshot.value["chapterID"];
    if (snapshot.value["roles"] != null) {
      for (int i = 0; i < snapshot.value["roles"].length; i++) {
        roles.add(snapshot.value["roles"][i]);
      }
    }
    if (snapshot.value["groups"] != null) {
      for (int i = 0; i < snapshot.value["groups"].length; i++) {
        groups.add(snapshot.value["groups"][i]);
      }
    }
  }

  @override
  String toString() {
    return "$firstName $lastName <$email> Grade $grade";
  }

}