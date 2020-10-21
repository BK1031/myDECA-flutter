import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mydeca_flutter/models/user.dart' as user;
import '../app_drawer.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool mobilePush = true;
  bool webPush = true;
  bool emailPush = true;

  void stopNotifDialog(String type) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Stop Receiving ${type == "mobilePush" ? "Push" : (type == "webPush" ? "Web" : "Email")} Notifications?", style: TextStyle(color: currTextColor),),
          content: new Text("Are you sure you want to stop receiving these notifications? You may miss important announcements, meeting updates, and conference information.", style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("CANCEL"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            ),
            new FlatButton(
                child: new Text("DISABLE NOTIFICATIONS"),
                textColor: Colors.red,
                onPressed: () {
                  FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child(type).set(false);
                  router.pop(context);
                  getNotificationPrefs();
                }
            )
          ],
        )
    );
  }

  @override
  void initState() {
    super.initState();
    getNotificationPrefs();
  }

  getNotificationPrefs() {
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("mobilePush").once().then((value) {
      if (value.value != null) {
        setState(() {
          mobilePush = false;
        });
      }
      else {
        setState(() {
          mobilePush = true;
        });
      }
    });
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("webPush").once().then((value) {
      if (value.value != null) {
        setState(() {
          webPush = false;
        });
      }
      else {
        setState(() {
          webPush = true;
        });
      }
    });
    FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("emailPush").once().then((value) {
      if (value.value != null) {
        setState(() {
          emailPush = false;
        });
      }
      else {
        setState(() {
          emailPush = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "SETTINGS",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
      ),
      drawer: new AppDrawer(),
      backgroundColor: currBackgroundColor,
      body: new Container(
        color: currBackgroundColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              new Card(
                color: currCardColor,
                child: new Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(top: 16.0),
                      child: new Text("${currUser.firstName} ${currUser.lastName}".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                    ),
                    new ListTile(
                      title: new Text("Email", style: TextStyle(fontSize: 17, color: currTextColor),),
                      trailing: new Text(currUser.email, style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new ListTile(
                      title: new Text("User ID", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Text(currUser.userID, style: TextStyle(fontSize: 14.0, fontFamily: "", color: currTextColor)),
                    ),
                    new ListTile(
                      title: new Text("Update Profile", style: TextStyle(color: mainColor), textAlign: TextAlign.center,),
                      onTap: () {
                        router.navigateTo(context, '/profile', transition: TransitionType.nativeModal);
                      },
                    )
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Card(
                color: currCardColor,
                child: Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(top: 16.0),
                      child: new Text("General".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                    ),
                    new ListTile(
                      title: new Text("About", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                      onTap: () {
                        router.navigateTo(context, '/settings/about', transition: TransitionType.native);
                      },
                    ),
                    new ListTile(
                      title: new Text("Help", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                      onTap: () async {
                        const url = 'https://docs.mydeca.org';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    new ListTile(
                        title: new Text("Legal", style: TextStyle(fontSize: 17, color: currTextColor)),
                        trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                        onTap: () {
                          showLicensePage(
                              context: context,
                              applicationVersion: appFull + appStatus,
                              applicationName: "myDECA App",
                              applicationLegalese: appLegal,
                              applicationIcon: new Image.asset(
                                'images/deca-diamond.png',
                                height: 35.0,
                              )
                          );
                        }
                    ),
                    new ListTile(
                      title: new Text("Sign Out", style: TextStyle(fontSize: 17, color: Colors.red),),
                      onTap: () {
                        currUser = new user.User.plain();
                        FirebaseAuth.instance.signOut();
                        router.navigateTo(context, "/auth-checker", transition: TransitionType.fadeIn, replace: true);
                      },
                    ),
                    new ListTile(
                      title: new Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 17),),
                      subtitle: new Text("\nDeleting your myDECA Account will remove all the data linked to your account as well. You will be required to create a new account in order to sign in again.\n", style: TextStyle(color: Colors.grey)),
                      onTap: () {

                      },
                    )
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Card(
                color: currCardColor,
                child: Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(top: 16.0),
                      child: new Text("Preferences".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: mobilePush,
                      onChanged: (val) {
                        if (!val) {
                          stopNotifDialog("mobilePush");
                        }
                        else {
                          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("mobilePush").remove();
                          setState(() {
                            mobilePush = val;
                          });
                        }
                      },
                      title: new Text("Push Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: webPush,
                      onChanged: (val) {
                        if (!val) {
                          stopNotifDialog("webPush");
                        }
                        else {
                          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("webPush").remove();
                          setState(() {
                            webPush = val;
                          });
                        }
                      },
                      title: new Text("Web Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new SwitchListTile.adaptive(
                      activeColor: mainColor,
                      activeTrackColor: mainColor,
                      value: emailPush,
                      onChanged: (val) {
                        if (!val) {
                          stopNotifDialog("emailPush");
                        }
                        else {
                          FirebaseDatabase.instance.reference().child("users").child(currUser.userID).child("emailPush").remove();
                          setState(() {
                            emailPush = val;
                          });
                        }
                      },
                      title: new Text("Email Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                    ),
                    new Visibility(
                      visible: (currUser.roles.contains('Developer')),
                      child: new SwitchListTile.adaptive(
                        activeColor: mainColor,
                        activeTrackColor: mainColor,
                        title: new Text("Dark Mode", style: TextStyle(fontSize: 17, color: currTextColor)),
                        value: darkMode,
                        onChanged: (bool value) {
                          // Toggle Dark Mode
                          setState(() {
                            darkMode = value;
                            if (darkMode) {
                              currTextColor = darkTextColor;
                              currBackgroundColor = darkBackgroundColor;
                              currCardColor = darkCardColor;
                              currDividerColor = darkDividerColor;
                            }
                            else {
                              currTextColor = lightTextColor;
                              currBackgroundColor = lightBackgroundColor;
                              currCardColor = lightCardColor;
                              currDividerColor = lightDividerColor;
                            }
                            FirebaseDatabase.instance.reference().child("users").child(currUser.userID).update({"darkMode": darkMode});
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Card(
                color: currCardColor,
                child: Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(top: 16.0),
                      child: new Text("Feedback".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                    ),
                    new ListTile(
                      title: new Text("Provide Feedback", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                      onTap: () async {
                        const url = 'https://forms.gle/8UMH4V5Ty79qFEnNA';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    new ListTile(
                      title: new Text("Report a Bug", style: TextStyle(fontSize: 17, color: currTextColor)),
                      trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                      onTap: () async {
                        const url = 'https://github.com/Equinox-Initiative/myDECA-flutter/issues';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(4)),
              new Visibility(
                visible: (currUser.roles.contains('Developer')),
                child: new Column(
                  children: <Widget>[
                    new Card(
                      color: currCardColor,
                      child: Column(
                        children: <Widget>[
                          new Container(
                            padding: EdgeInsets.only(top: 16.0),
                            child: new Text("developer".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                          ),
                          new ListTile(
                            leading: new Icon(Icons.developer_mode, color: darkMode ? Colors.grey : Colors.black54,),
                            title: new Text("Test Firebase Upload", style: TextStyle(fontSize: 17, color: currTextColor)),
                            onTap: () {
                              FirebaseDatabase.instance.reference().child("testing").push().set("${currUser.firstName} - ${currUser.roles.first}");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(16.0))
            ],
          ),
        ),
      )
    );
  }
}
