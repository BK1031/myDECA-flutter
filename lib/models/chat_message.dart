import 'package:firebase_database/firebase_database.dart';
import 'package:mydeca_flutter/models/user.dart';

class ChatMessage {
  String key = "";
  String message = "";
  String mediaType = "";
  DateTime date = new DateTime.now();
  bool nsfw = false;
  User author = new User.plain();

  ChatMessage.plain();

  ChatMessage.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key;
    message = snapshot.value["message"];
    author.userID = snapshot.value["author"];
    mediaType = snapshot.value["type"];
    date = DateTime.parse(snapshot.value["date"]);
    nsfw = snapshot.value["nsfw"];
  }
}