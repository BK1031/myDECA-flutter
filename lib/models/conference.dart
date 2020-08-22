import 'package:firebase_database/firebase_database.dart';

class Conference {
  String conferenceID = "";
  String fullName = "";
  String desc = "";
  String date = "";
  String imageUrl = "";
  String mapUrl = "";
  String hotelMapUrl = "";
  String eventsUrl = "";
  String alertsUrl = "";
  String siteUrl = "";
  String location = "";
  String address = "";
  bool past = false;

  Conference.plain();

  Conference.fromSnapshot(DataSnapshot snapshot)
      : conferenceID = snapshot.key,
        fullName = snapshot.value["full"],
        desc = snapshot.value["desc"],
        date = snapshot.value["date"],
        imageUrl = snapshot.value["imageUrl"],
        mapUrl = snapshot.value["mapUrl"],
        hotelMapUrl = snapshot.value["hotelMapUrl"],
        eventsUrl = snapshot.value["eventsUrl"],
        siteUrl = snapshot.value["siteUrl"],
        alertsUrl = snapshot.value["alertsUrl"],
        location = snapshot.value["location"],
        past = snapshot.value["past"],
        address = snapshot.value["address"];
}