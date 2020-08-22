import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mydeca_flutter/models/chapter.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  PageController _controller = new PageController();

  double height = 1000.0;

  List<Chapter> chapterList = new List();
  Widget registerWidget = new Container();
  Widget loginWidget = new Container();
  double cardHeight = 200;

  bool chapterExists = false;
  bool advisorExists = false;
  bool advisorCodeExists = false;

  Chapter selectedChapter = new Chapter();

  String _email = "";
  String _password = "";

  String password = "";
  String confirmPassword = "";

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

  void checkChapterCode(String code) {
    setState(() {
      cardHeight = 200;
      chapterExists = false;
      advisorExists = false;
      advisorCodeExists = false;
    });
    for (int i = 0; i < chapterList.length; i++) {
      if (code == chapterList[i].chapterID) {
        setState(() {
          print("Chapter Exists!");
          selectedChapter = chapterList[i];
          cardHeight = 500;
          chapterExists = true;
          if (chapterList[i].advisorName != null && chapterList[i].advisorName != "") {
            // Advisor already exists for selected chapter
            print("Advisor Exists!");
            advisorExists = true;
            cardHeight = MediaQuery.of(context).size.height - 64;
            registerWidget = new RaisedButton(
                child: new Text("CREATE ACCOUNT", style: TextStyle(fontSize: 17),),
                textColor: Colors.white,
                color: mainColor,
                onPressed: register
            );
          }
        });
      }
    }
  }

  void checkAdvisorCode(String code) {
    setState(() {
      cardHeight = 500;
      advisorCodeExists = false;
      registerWidget = new Container();
    });
    if (code == selectedChapter.advisorCode) {
      setState(() {
        cardHeight = 530;
        advisorCodeExists = true;
        registerWidget = new RaisedButton(
            child: new Text("CREATE ACCOUNT", style: TextStyle(fontSize: 17),),
            textColor: Colors.white,
            color: mainColor,
            onPressed: register
        );
      });
    }
  }

  Future<void> login() async {
    if (_email != "" && _password != "") {
      try {
        setState(() {
          loginWidget = new Container(
            child: new HeartbeatProgressIndicator(
              child: new Image.asset("images/deca-diamond.png", height: 20,),
            ),
          );
        });
        await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password).then((value) async {
          print(fb.FirebaseAuth.instance.currentUser.uid);
          currUser.userID = fb.FirebaseAuth.instance.currentUser.uid;
          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).once().then((value) {
            currUser = new User.fromSnapshot(value);
          });
          router.navigateTo(context, "/home", transition: TransitionType.fadeIn, clearStack: true);
        });
      } catch (e) {
        print(e);
        alert("An error occured while creating your account: ${e.message}");
      }
    }
    setState(() {
      loginWidget = new RaisedButton(
          child: new Text("LOGIN", style: TextStyle(fontSize: 17),),
          textColor: Colors.white,
          color: mainColor,
          onPressed: login
      );
    });
  }

  Future<void> register() async {
    if (currUser.firstName == "" || currUser.lastName == "") {
      alert("Name cannot be empty!");
    }
    else if (currUser.email == "") {
      alert("Email cannot be empty!");
    }
    else if (password != confirmPassword) {
      alert("Passwords must match!");
    }
    else {
      // All good to create account!
      try {
        setState(() {
          registerWidget = new Container(
            child: new HeartbeatProgressIndicator(
              child: new Image.asset("images/deca-diamond.png", height: 20,),
            ),
          );
        });
        await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: currUser.email, password: password).then((value) async {
          currUser.userID = value.user.uid;
          if (advisorCodeExists) {
            currUser.roles.add("Advisor");
          }
          else {
            currUser.roles.add("Member");
          }
          currUser.chapter = selectedChapter;
          print(currUser.userID);
          print(currUser.chapter.chapterID);
          currUser.userID = fb.FirebaseAuth.instance.currentUser.uid;
          await FirebaseDatabase.instance.reference().child("users").child(currUser.userID).set({
            "firstName": currUser.firstName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "lastName": currUser.lastName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "email": currUser.email,
            "emailVerified": currUser.emailVerified,
            "gender": currUser.gender,
            "roles": currUser.roles,
            "grade": currUser.grade,
            "yearsMember": currUser.yearsMember,
            "shirtSize": currUser.shirtSize,
            "chapterID": currUser.chapter.chapterID,
          });
          if (currUser.gender == "Female") {
            print("Female pic used");
            FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("profileUrl").set("https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-female.png?alt=media&token=ad2ae077-6927-4209-893a-e394b368538b");
          }
          else {
            print("Male pic used");
            FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("profileUrl").set("https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-male.png?alt=media&token=5b6b4b1c-649c-46b9-be30-b15d3603e358");
          }
          print("Uploaded profile picture!");
          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).once().then((value) {
            currUser = new User.fromSnapshot(value);
          });
          router.navigateTo(context, "/home?new", transition: TransitionType.fadeIn, clearStack: true);
        });
      } catch (e) {
        print(e);
        alert("An error occured while creating your account: ${e.message}");
      }
    }
    setState(() {
      registerWidget = new RaisedButton(
          child: new Text("CREATE ACCOUNT", style: TextStyle(fontSize: 17),),
          textColor: Colors.white,
          color: mainColor,
          onPressed: register
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      height = 200;
    });
    FirebaseDatabase.instance.reference().child("chapters").onChildAdded.listen((event) {
      Chapter chapter = new Chapter();
      chapter.chapterID = event.snapshot.key;
      chapter.name = event.snapshot.value["name"];
      chapter.advisorCode = event.snapshot.value["advisorCode"];
      chapter.advisorName = event.snapshot.value["advisor"];
      chapter.city = event.snapshot.value["city"];
      print(chapter);
      chapterList.add(chapter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              width: double.infinity,
              height: height,
              color: mainColor,
              child: Hero(
                tag: "welcome_text",
                child: new Text(
                  "Welcome to\nmyDECA",
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 35
                  ),
                ),
              ),
            ),
            new AnimatedContainer(
              height: chapterExists ? 110 : 0,
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(8.0),
              child: new Card(
                child: new Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Padding(padding: EdgeInsets.all(4.0),),
                      new Image.asset("images/deca-diamond.png", height: 50,),
                      new Padding(padding: EdgeInsets.all(8.0),),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(selectedChapter.name + " DECA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          new Text(selectedChapter.city, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                          new Text("Advisor: " + (selectedChapter.advisorName == null ? "Not Set" : selectedChapter.advisorName), style: TextStyle(fontWeight: FontWeight.w300))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            new Expanded(
              child: new SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: new PageView(
                    controller: _controller,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      new SingleChildScrollView(
                        child: new Column(
                          children: [
                            new Row(
                              children: [
                                new Text(chapterExists ? "Valid Chapter Code!" : "Enter your chapter code below", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: chapterExists ? Colors.green : currTextColor)),
                                new IconButton(icon: Icon(Icons.help), tooltip: "Use the chapter code you recieved from your advisor here.\nIf you do not have a code, contact your advisor.",)
                              ],
                            ),
                            new TextField(
                              decoration: InputDecoration(
                                labelText: "Chapter Code",
                                hintText: "CC-######",
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: checkChapterCode,
                            ),
                            new Visibility(visible: chapterExists, child: new Padding(padding: EdgeInsets.all(8.0))),
                            new Visibility(
                                visible: chapterExists && !advisorExists,
                                child: Row(
                                  children: [
                                    new Text(advisorCodeExists ? "Valid Advisor Code!" : "Enter your advisor code below", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: advisorCodeExists ? Colors.green : currTextColor),),
                                    new IconButton(icon: Icon(Icons.help), tooltip: "An advisor has not been set for this chapter yet. Please ask your advisor to create their\naccount first. If you are an advisor and have not recieved a code, please reach out to us.",)
                                  ],
                                )
                            ),
                            new Visibility(
                              visible: chapterExists && !advisorExists,
                              child: new TextField(
                                decoration: InputDecoration(
                                  labelText: "Advisor Code",
                                  hintText: "AC-######",
                                ),
                                autocorrect: false,
                                textCapitalization: TextCapitalization.characters,
                                onChanged: checkAdvisorCode,
                              ),
                            ),
                            new Padding(padding: EdgeInsets.all(16.0)),
                            new Visibility(
                              visible: (chapterExists && advisorExists) || (chapterExists && !advisorExists && advisorCodeExists),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 16,
                                child: new RaisedButton(
                                  color: mainColor,
                                  textColor: Colors.white,
                                  child: new Text("NEXT", style: TextStyle(fontSize: 17),),
                                  onPressed: () {
                                    _controller.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                                  },
                                ),
                              )
                            ),
                            new FlatButton(
                              child: new Text("Already have an account?", style: TextStyle(fontSize: 17),),
                              textColor: mainColor,
                              onPressed: () {
                                setState(() {
                                  chapterExists = false;
                                  advisorExists = false;
                                  advisorCodeExists = false;
                                  selectedChapter = Chapter();
                                  loginWidget = new RaisedButton(
                                      child: new Text("LOGIN", style: TextStyle(fontSize: 17),),
                                      textColor: Colors.white,
                                      color: mainColor,
                                      onPressed: login
                                  );
                                });
                                _controller.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                              },
                            )
                          ],
                        ),
                      ),
                      new SingleChildScrollView(
                        child: new Column(
                          children: [
                            Column(
                              children: [
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.person),
                                    labelText: "First Name",
                                    hintText: "Enter your first name",
                                  ),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (value) {
                                    currUser.firstName = value;
                                  },
                                ),
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.person),
                                    labelText: "Last Name",
                                    hintText: "Enter your last name",
                                  ),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (value) {
                                    currUser.lastName = value;
                                  },
                                ),
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.email),
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  onChanged: (value) {
                                    currUser.email = value;
                                  },
                                ),
                                new Visibility(
                                  visible: !advisorCodeExists,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 3,
                                        child: new Text(
                                          "Grade",
                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 2,
                                        child: new DropdownButton(
                                          value: currUser.grade,
                                          items: [
                                            DropdownMenuItem(child: new Text("9"), value: 9),
                                            DropdownMenuItem(child: new Text("10"), value: 10),
                                            DropdownMenuItem(child: new Text("11"), value: 11),
                                            DropdownMenuItem(child: new Text("12"), value: 12),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              currUser.grade = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      flex: 3,
                                      child: new Text(
                                        "Gender",
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                      ),
                                    ),
                                    new Expanded(
                                      flex: 2,
                                      child: new DropdownButton(
                                        value: currUser.gender,
                                        items: [
                                          DropdownMenuItem(child: new Text("Male"), value: "Male"),
                                          DropdownMenuItem(child: new Text("Female"), value: "Female"),
                                          DropdownMenuItem(child: new Text("Other"), value: "Other"),
                                          DropdownMenuItem(child: new Text("Prefer not to say"), value: "Opt-Out"),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            currUser.gender = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      flex: 3,
                                      child: new Text(
                                        "Shirt Size",
                                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                      ),
                                    ),
                                    new Expanded(
                                      flex: 2,
                                      child: new DropdownButton(
                                        value: currUser.shirtSize,
                                        items: [
                                          DropdownMenuItem(child: new Text("S"), value: "S"),
                                          DropdownMenuItem(child: new Text("M"), value: "M"),
                                          DropdownMenuItem(child: new Text("L"), value: "L"),
                                          DropdownMenuItem(child: new Text("XL"), value: "XL"),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            currUser.shirtSize = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                new Visibility(
                                  visible: !advisorCodeExists,
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 3,
                                        child: new Text(
                                          "Years in DECA",
                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 2,
                                        child: new DropdownButton(
                                          value: currUser.yearsMember,
                                          items: [
                                            DropdownMenuItem(child: new Text("First Year"), value: 0),
                                            DropdownMenuItem(child: new Text("Second Year"), value: 1),
                                            DropdownMenuItem(child: new Text("Third Year"), value: 2),
                                            DropdownMenuItem(child: new Text("Fourth Year"), value: 3),
                                            DropdownMenuItem(child: new Text("Fifth Year"), value: 4),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              currUser.yearsMember = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.lock),
                                    labelText: "Password",
                                    hintText: "Enter a password",
                                  ),
                                  autocorrect: false,
                                  obscureText: true,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                ),
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.lock),
                                    labelText: "Confirm Password",
                                    hintText: "Confirm your password",
                                  ),
                                  autocorrect: false,
                                  obscureText: true,
                                  onChanged: (value) {
                                    confirmPassword = value;
                                  },
                                ),
                                new Padding(padding: EdgeInsets.all(8.0)),
                                new RichText(
                                  text: new TextSpan(
                                    children: [
                                      new TextSpan(
                                        text: "By creating a myDECA account, you agree to our ",
                                        style: new TextStyle(color: Colors.black),
                                      ),
                                      new TextSpan(
                                        text: 'Terms of Service',
                                        style: new TextStyle(color: mainColor),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            launch("https://deca.bk1031.dev/terms");
                                          },
                                      ),
                                      new TextSpan(
                                        text: " and ",
                                        style: new TextStyle(color: Colors.black),
                                      ),
                                      new TextSpan(
                                        text: 'Privacy Policy',
                                        style: new TextStyle(color: mainColor),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            launch("https://deca.bk1031.dev/terms");
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                new Padding(padding: EdgeInsets.all(16)),
                                Container(
                                  width: MediaQuery.of(context).size.width - 16,
                                  child: registerWidget
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      new SingleChildScrollView(
                        child: new Column(
                          children: [
                            Column(
                              children: [
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.email),
                                    labelText: "Email",
                                    hintText: "Enter your email",
                                  ),
                                  autocorrect: false,
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  onChanged: (value) {
                                    _email = value;
                                  },
                                ),
                                new TextField(
                                  decoration: InputDecoration(
                                    icon: new Icon(Icons.lock),
                                    labelText: "Password",
                                    hintText: "Enter a password",
                                  ),
                                  autocorrect: false,
                                  obscureText: true,
                                  onChanged: (value) {
                                    _password = value;
                                  },
                                ),
                                new Padding(padding: EdgeInsets.all(16)),
                                Container(
                                    width: MediaQuery.of(context).size.width - 16,
                                    child: loginWidget
                                ),
                                new FlatButton(
                                  child: new Text("Don't have an account?", style: TextStyle(fontSize: 17),),
                                  textColor: mainColor,
                                  onPressed: () {
                                    _controller.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
