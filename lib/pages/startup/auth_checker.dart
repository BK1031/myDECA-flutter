import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/models/user.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {

  double percent = 0.2;
  bool connected = true;

  final connectionRef = FirebaseDatabase.instance.reference().child(".info/connected");

  Future<void> checkConnection() async {
    connectionRef.onValue.listen((event) {
      if (event.snapshot.value) {
        setState(() {
          connected = true;
        });
        checkAuth();
      }
      else {
        setState(() {
          connected = false;
        });
      }
    });
  }

  Future<void> checkAuth() async {
    setState(() {
      percent = 0.4;
    });
    if (fb.FirebaseAuth.instance.currentUser != null) {
      FirebaseDatabase.instance.reference().child("users").child(fb.FirebaseAuth.instance.currentUser.uid).once().then((value) {
        currUser = new User.fromSnapshot(value);
        print("––––––––––––– DEBUG INFO ––––––––––––––––");
        print("NAME: ${currUser.firstName} ${currUser.lastName}");
        print("EMAIL: ${currUser.email}");
        print("ROLE: ${currUser.roles.toString()}");
        print("–––––––––––––––––––––––––––––––––––––––––");
        if (value.value["darkMode"] != null && value.value["darkMode"]) {
          setState(() {
            darkMode = true;
            currBackgroundColor = darkBackgroundColor;
            currCardColor = darkCardColor;
            currDividerColor = darkDividerColor;
            currTextColor = darkTextColor;
          });
        }
        setState(() {
          percent = 1.0;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true);
        });
      });
    }
    else {
      setState(() {
        percent = 1.0;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        router.navigateTo(context, "/onboarding", transition: TransitionType.fadeIn, replace: true);
      });
    }

  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (connected) {
      return Scaffold(
        backgroundColor: currBackgroundColor,
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: new Image.asset(
                  "images/deca-diamond.png",
                  width: 100,
                ),
              ),
              Center(
                child: new CircularPercentIndicator(
                  radius: 75,
                  circularStrokeCap: CircularStrokeCap.round,
                  lineWidth: 7,
                  animateFromLastPercent: true,
                  animation: true,
                  percent: percent,
                  progressColor: mainColor,
                ),
              )
            ],
          ),
        ),
      );
    }
    else {
      return Scaffold(
        backgroundColor: currBackgroundColor,
        body: Container(
          padding: EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0, top: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                child: Image.asset(
                  'images/deca-logo.png',
                ),
              ),
              new Column(
                children: [
                  new Text(
                    "Server Connection Error",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: "Montserrat",
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(8.0)),
                  new Text(
                    "We encountered a problem when trying to connect you to our servers. This page will automatically disappear if a connection with the server is established.\n\nTroubleshooting Tips:\n- Check your wireless connection\n- Restart the myDECA app\n- Restart your device",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontSize: 17.0,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}
