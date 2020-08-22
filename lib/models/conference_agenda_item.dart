import 'package:firebase_database/firebase_database.dart';

class ConferenceAgendaItem {
  String key;
  String title;
  String desc;
  String date;
  String time;
  String endTime;
  String location;

  ConferenceAgendaItem.plain();

  ConferenceAgendaItem.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        desc = snapshot.value["desc"],
        date = snapshot.value["date"],
        time = snapshot.value["time"],
        endTime = snapshot.value["endTime"],
        location = snapshot.value["location"];
}