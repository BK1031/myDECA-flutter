import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeDialog extends StatefulWidget {
  @override
  _WelcomeDialogState createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {

  String status = "";

  @override
  void initState() {
    super.initState();
    sendVerification();
  }

  void sendVerification() {
    FirebaseAuth.instance.currentUser.sendEmailVerification();
  }

  void checkVerification() {
    FirebaseAuth.instance.currentUser.reload();
    if (FirebaseAuth.instance.currentUser.emailVerified) {
      print("VERIFIED");
      setState(() {
        status = "Email Verified!";
      });
      FirebaseDatabase.instance.reference().child("users").child(FirebaseAuth.instance.currentUser.uid).child("emailVerified").set(true);
      router.navigateTo(context, "/home", transition: TransitionType.fadeIn, clearStack: true);
    }
    else {
      setState(() {
        status = "Email Not Verified";
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          status = "";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Text(
                "We're excited to have you onboard. Here are some resources to help you get started with myDECA:",
                style: TextStyle(color: currTextColor)
              ),
              new Padding(padding: EdgeInsets.all(8)),
              Container(
                height: 100,
                child: new Row(
                  children: [
                    new Expanded(
                      child: new Card(
                        color: currCardColor,
                        child: new InkWell(
                          onTap: () {
                            launch("https://docs.mydeca.org/user-1/registration");
                          },
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              new Icon(Icons.view_list, color: darkMode ? Colors.grey : Colors.black54),
                              Center(child: new Text("Getting Started Guide", style: TextStyle(color: currTextColor), textAlign: TextAlign.center,))
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Expanded(
                      child: new Card(
                        color: currCardColor,
                        child: new InkWell(
                          onTap: () {

                          },
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              new Icon(Icons.ondemand_video, color: darkMode ? Colors.grey : Colors.black54),
                              Center(child: new Text("Video Tutorials", style: TextStyle(color: currTextColor)))
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Text("One more thing, please verify your email via the link we just sent you.", style: TextStyle(color: currTextColor)),
              new Padding(padding: EdgeInsets.all(8)),
              new Text(status, style: TextStyle(color: status == "Email Not Verified" ? Colors.red : Colors.green),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new FlatButton(
                    child: new Text("RESEND\nVERIFICATION EMAIL", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      sendVerification();
                    },
                  ),
                  new RaisedButton(
                    color: mainColor,
                    textColor: Colors.white,
                    child: new Text("VERIFY"),
                    onPressed: () {
                      checkVerification();
                    },
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
}