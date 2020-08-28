import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_flutter/models/announcement.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'announcement_confirm_dialog.dart';

class NewAnnouncementPage extends StatefulWidget {
  @override
  _NewAnnouncementPageState createState() => _NewAnnouncementPageState();
}

class _NewAnnouncementPageState extends State<NewAnnouncementPage> {

  Announcement announcement = new Announcement.plain();

  PageController _controller = PageController();
  TextEditingController _textController = TextEditingController();
  int currPage = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      announcement.author = currUser;
    });
  }

  void alert(String alert) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Alert"),
          content: new Text(alert),
          actions: [
            new FlatButton(
                child: new Text("GOT IT"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  void confirmDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Select Target", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new AnnouncementConfirmDialog(announcement),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "NEW ANNOUNCEMENT",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      backgroundColor: currBackgroundColor,
      floatingActionButton: new FloatingActionButton.extended(
        icon: Icon(Icons.send),
        label: new Text("PUBLISH"),
        onPressed: () {
            if (announcement.title != "" && announcement.desc != "") {
              confirmDialog();
            }
            else {
              alert("Please make sure that you fill out all the fields!");
            }
        },
      ),
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                child: new TextField(
                  maxLines: null,
                  onChanged: (input) {
                    setState(() {
                      announcement.title = input;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: "Announcement Title",
                      labelStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54),
                      border: InputBorder.none
                  ),
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 25, color: currTextColor),
                ),
              ),
              new Container(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new CircleAvatar(
                      radius: 25,
                      backgroundColor: announcement.author.roles.length != 0 ? roleColors[announcement.author.roles.first] : currTextColor,
                      child: new ClipRRect(
                        borderRadius: new BorderRadius.all(Radius.circular(45)),
                        child: new CachedNetworkImage(
                          imageUrl: announcement.author.profileUrl,
                          height: 45,
                          width: 45,
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Tooltip(
                          message: "Topics: ${announcement.topics}",
                          child: new Text(
                            "${announcement.author.firstName} ${announcement.author.lastName} | ${announcement.author.roles.length != 0 ? announcement.author.roles.first : ""}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20.0,
                                color: announcement.author.roles.length != 0 ? roleColors[announcement.author.roles.first] : currTextColor
                            ),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(2)),
                        new Row(
                          children: [
                            new Visibility(
                              visible: currUser.roles.contains("Developer"),
                              child: new Tooltip(
                                message: announcement.official ? "Official DECA Communication" : "",
                                child: new InkWell(
                                  onTap: () {
                                    setState(() {
                                      announcement.official = !announcement.official;
                                    });
                                  },
                                  child: new Card(
                                    color: announcement.official ? mainColor : Colors.grey,
                                    child: new Container(
                                      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                      child: new Text(announcement.official ? "✓  VERIFIED" : "UNOFFICIAL", style: TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            new Padding(padding: EdgeInsets.all(2)),
                            new Text(
                              "${DateFormat.yMMMd().format(announcement.date)} @ ${DateFormat.jm().format(announcement.date)}",
                              style: TextStyle(color: Colors.grey, fontSize: 18),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: new Row(
                  children: [
                    new Expanded(
                      child: new RaisedButton(
                        elevation: currPage == 0 ? null : 0,
                        color: currPage == 0 ? mainColor : currBackgroundColor,
                        child: new Text("MARKDOWN"),
                        textColor: currPage == 0 ? Colors.white : mainColor,
                        onPressed: () {
                          _controller.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                          setState(() {});
                        },
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4)),
                    new Expanded(
                      child: new RaisedButton(
                        elevation: currPage == 1 ? null : 0,
                        color: currPage == 1 ? mainColor : currBackgroundColor,
                        child: new Text("PREVIEW"),
                        textColor: currPage == 1 ? Colors.white : mainColor,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _controller.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 400,
                width: MediaQuery.of(context).size.width - 16,
                padding: EdgeInsets.all(8),
                child: new PageView(
                  onPageChanged: (page) {
                    FocusScope.of(context).unfocus();
                    _textController.text = announcement.desc;
                    setState(() {
                      currPage = page;
                    });
                  },
                  controller: _controller,
                  children: [
                    new Container(
                      child: TextField(
                        maxLines: null,
                        controller: _textController,
                        onChanged: (value) {
                          setState(() {
                            announcement.desc = value;
                          });
                        },
                        style: TextStyle(color: currTextColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '# Heading\n\nWrite your announcement here, markdown is supported!',
                          hintStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                        ),
                      ),
                    ),
                    new Container(
                      child: new Markdown(
                        data: announcement.desc,
                        selectable: true,
                        styleSheet: markdownStyle,
                        onTapLink: (url) {
                          launch(url);
                        },
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}