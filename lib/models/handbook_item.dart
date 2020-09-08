import 'package:mydeca_flutter/models/user.dart';

class HandbookItem {
  int index = 0;
  String task = "";
  DateTime timestamp;
  User checkedBy = new User.plain();
}