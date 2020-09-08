import 'package:mydeca_flutter/models/handbook_item.dart';
import 'package:mydeca_flutter/models/user.dart';

class UserHandbook {
  String handbookID = "";
  String name = "";
  User user = new User.plain();
  List<HandbookItem> items = new List();
}