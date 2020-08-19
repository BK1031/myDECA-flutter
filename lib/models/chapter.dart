class Chapter {
  String chapterID = "";
  String name = "";
  String advisorName = "";
  String advisorCode = "";
  String city = "";

  @override
  String toString() {
    return "$chapterID – $name, $city – Advisor $advisorName";
  }
}