import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydeca_flutter/models/chat_message.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/pages/chat/send_media_dialog.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatViewPage extends StatefulWidget {
  @override
  _ChatViewPageState createState() => _ChatViewPageState();
}

class _ChatViewPageState extends State<ChatViewPage> {

  List<Widget> widgetList = new List();
  List<ChatMessage> chatList = new List();
  ChatMessage newMessage = new ChatMessage.plain();
  FocusNode _focusNode = new FocusNode();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _textController = new TextEditingController();

  bool rendered = false;
  bool confirmNsfw = false;

  String chatID = "";
  String chatName = "";

  List<String> noNoWordList = new List();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(focusNodeListener);
    FirebaseDatabase.instance.reference().child("chatNoNoWords").onChildAdded.listen((Event event) {
      noNoWordList.add(event.snapshot.value.toString());
    });
  }

  Future<Null> focusNodeListener() async {
    if (_focusNode.hasFocus) {
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 10.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void getChat(String route) {
    rendered = true;
    chatID = route.split("?id=")[1];
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).child("name").once().then((value) {
      if (value.value != null) {
        setState(() {
          chatName = value.value;
        });
      }
      else {
        setState(() {
          chatName = chatID;
        });
        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).child("name").set(chatName);
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 20.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).onChildAdded.listen((event) {
      ChatMessage message = new ChatMessage.fromSnapshot(event.snapshot);
      FirebaseDatabase.instance.reference().child("users").child(message.author.userID).once().then((value) {
        message.author = new User.fromSnapshot(value);
        chatList.add(message);
        setState(() {
          // Add the actual chat message widget
          if (message.mediaType == "text") {
            if (chatList.length > 1 && message.author.userID == chatList[chatList.length - 2].author.userID &&  message.date.difference(chatList[chatList.length - 2].date).inMinutes.abs() < 5) {
              widgetList.add(new InkWell(
                onLongPress: () {

                },
                child: new Container(
                  padding: EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      new Container(width: 58),
                      new Expanded(
                        child: new Linkify(
                          text: message.message,
                          style: TextStyle(color: currTextColor, fontSize: 15),
                          linkStyle: TextStyle(color: mainColor, fontSize: 15),
                          onOpen: (link) {
                            launch(link.url);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            }
            else {
              widgetList.add(new InkWell(
                onLongPress: () {

                },
                child: new Container(
                  padding: EdgeInsets.only(left: 12, top: 8, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        child: new CircleAvatar(
                          radius: 20,
                          backgroundColor: roleColors[message.author.roles.first],
                          child: new ClipRRect(
                            borderRadius: new BorderRadius.all(Radius.circular(45)),
                            child: new CachedNetworkImage(
                              imageUrl: message.author.profileUrl,
                              height: 35,
                              width: 35,
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(
                              message.author.firstName + " " + message.author.lastName,
                              style: TextStyle(color: roleColors[message.author.roles.first], fontSize: 15),
                            ),
                            new Linkify(
                              text: message.message,
                              style: TextStyle(color: currTextColor, fontSize: 15),
                              linkStyle: TextStyle(color: mainColor, fontSize: 15),
                              onOpen: (link) {
                                launch(link.url);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            }
          }
          else {
            if (chatList.length > 1 && message.author.userID == chatList[chatList.length - 2].author.userID &&  message.date.difference(chatList[chatList.length - 2].date).inMinutes.abs() < 5) {
              widgetList.add(new InkWell(
                onLongPress: () {

                },
                child: new Container(
                  padding: EdgeInsets.only(left: 12, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(width: 58),
                      new Expanded(
                        child: new ClipRRect(
                          borderRadius: BorderRadius.circular(2.0),
                          child: new CachedNetworkImage(
                            imageUrl: message.message,
                            width: MediaQuery.of(context).size.width > 500 ? 500 : null,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              ));
            }
            else {
              widgetList.add(new InkWell(
                onLongPress: () {

                },
                child: new Container(
                  padding: EdgeInsets.only(left: 12, top: 8, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        child: new CircleAvatar(
                          radius: 20,
                          backgroundColor: roleColors[message.author.roles.first],
                          child: new ClipRRect(
                            borderRadius: new BorderRadius.all(Radius.circular(45)),
                            child: new CachedNetworkImage(
                              imageUrl: message.author.profileUrl,
                              height: 35,
                              width: 35,
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(
                              message.author.firstName + " " + message.author.lastName,
                              style: TextStyle(color: roleColors[message.author.roles.first], fontSize: 15),
                            ),
                            new Padding(padding: EdgeInsets.all(2)),
                            new ClipRRect(
                              borderRadius: BorderRadius.circular(2.0),
                              child: new CachedNetworkImage(
                                imageUrl: message.message,
                                width: MediaQuery.of(context).size.width > 500 ? 500 : null,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            }
          }
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 20.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    });
  }

  void sendMessage() {
    if (newMessage.message.replaceAll(" ", "").replaceAll("\n", "") != "") {
      // Message is not empty
      if (!checkNSFW(newMessage.message)) {
        FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).push().set({
          "message": newMessage.message,
          "author": currUser.userID,
          "type": "text",
          "date": DateTime.now().toString(),
          "nsfw": false
        });
        _textController.clear();
        newMessage = ChatMessage.plain();
      }
      else {
        // Message kinda not very pc kekw
        setState(() {
          confirmNsfw = true;
        });
      }
    }
  }

  bool checkNSFW(String message) {
    // dart is funny and goes through the entire list before returning something
    bool found = false;
    noNoWordList.forEach((element) {
      if (message.replaceAll(" ", "").replaceAll("\n", "").contains(element)) {
        print("$element found");
        found = true;
      }
      else print("$element not found");
    });
    return found;
  }

  void sendMedia() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return new SafeArea(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.camera_alt),
              title: new Text('Take Photo'),
              onTap: takePhoto,
            ),
            new ListTile(
              leading: new Icon(Icons.photo_library),
              title: new Text('Photo Library'),
              onTap: pickImage,
            ),
            new ListTile(
              leading: new Icon(Icons.clear),
              title: new Text('Cancel'),
              onTap: () {
                router.pop(context);
              },
            ),
          ],
        ),
      );
    });
  }

  Future<void> pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      showDialog(
          barrierDismissible: false,
          context: context,
          child: new AlertDialog(
            content: new SendMediaDialog(image, chatID),
          )
      );
    }
  }

  Future<void> takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return new SendMediaDialog(image, chatID);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!rendered) getChat(ModalRoute.of(context).settings.name);
    return Scaffold(
      appBar: new AppBar(
        title: new FittedBox(
          fit: BoxFit.fitWidth,
          child: new Text(
            chatName.toUpperCase(),
            style: TextStyle(fontFamily: "Montserrat"),
          ),
        ),
        actions: [
          new IconButton(
            icon: new Icon(Icons.more_vert),
            onPressed: () {
              router.navigateTo(context, "/chat/details?id=$chatID", transition: TransitionType.nativeModal);
            },
          )
        ],
      ),
      backgroundColor: currBackgroundColor,
      body: new SafeArea(
        child: new Container(
          child: Column(
            children: [
              new Expanded(
                child: new SingleChildScrollView(
                  controller: _scrollController,
                  child: new Column(
                      children: widgetList
                  ),
                ),
              ),
              new AnimatedContainer(
                padding: EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0),
                duration: const Duration(milliseconds: 200),
                height: confirmNsfw ? 100 : 0,
                child: new Card(
                  color: Color(0xFFffebba),
                  child: new Container(
                    padding: EdgeInsets.all(8),
                    child: new Row(
                      children: [
                        new Icon(Icons.warning, color: Colors.orangeAccent,),
                        new Padding(padding: EdgeInsets.all(4)),
                        new Text("It looks like your message contains\nsome NSFW content. Are you sure\nyou would like to send this?", style: TextStyle(color: Colors.orangeAccent),),
                        new Padding(padding: EdgeInsets.all(4)),
                        new OutlineButton(
                          disabledBorderColor: Colors.orangeAccent,
                          highlightedBorderColor: Colors.orangeAccent,
                          color: Colors.orangeAccent,
                          textColor: Colors.orangeAccent,
                          child: new Text("SEND"),
                          onPressed: () {
                            FirebaseDatabase.instance.reference().child("chapters").child(currUser.chapter.chapterID).child("chat").child(chatID).push().set({
                              "message": newMessage.message,
                              "author": currUser.userID,
                              "type": "text",
                              "date": DateTime.now().toString(),
                              "nsfw": true
                            });
                            _textController.clear();
                            newMessage = ChatMessage.plain();
                            setState(() {
                              confirmNsfw = false;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                )
              ),
              new Container(
                padding: EdgeInsets.all(8),
                child: new Card(
                  color: currCardColor,
                  child: new ListTile(
                      title: Container(
                        child: Row(
                          children: <Widget>[
                            Material(
                              child: new Container(
                                child: new IconButton(
                                  icon: new Icon(Icons.image),
                                  color: Colors.grey,
                                  onPressed: () {
                                    sendMedia();
                                  },
                                ),
                              ),
                              color: currCardColor,
                            ),
                            // Edit text
                            Flexible(
                              child: Container(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  textInputAction: TextInputAction.newline,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: TextStyle(color: currTextColor, fontSize: 15.0),
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'Type your message...',
                                      hintStyle: TextStyle(color: darkMode ? Colors.grey : Colors.black54)
                                  ),
                                  onChanged: (input) {
                                    setState(() {
                                      newMessage.message = input;
                                      confirmNsfw = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            new Material(
                              child: new Container(
                                child: new IconButton(
                                  icon: new Icon(
                                    Icons.send,
                                    color: newMessage.message.replaceAll(" ", "").replaceAll("\n", "") != "" ? mainColor : Colors.grey,
                                  ),
                                  onPressed: () {
                                    sendMessage();
                                  },
                                ),
                              ),
                              color: currCardColor,
                            )
                          ],
                        ),
                        width: double.infinity,
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
