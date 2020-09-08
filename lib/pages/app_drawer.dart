import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:mydeca_flutter/models/user.dart' as user;

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Scaffold(
        backgroundColor: mainColor,
        body: new SafeArea(
          child: new Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Padding(padding: EdgeInsets.all(16)),
                      new ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: new CachedNetworkImage(
                          imageUrl: currUser.profileUrl,
                          height: 100,
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Text(
                        currUser.firstName + " " + currUser.lastName,
                        style: TextStyle(color: Colors.white, fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      new FlatButton(
                        child: new Text("View Profile"),
                        textColor: Colors.white.withOpacity(0.6),
                        onPressed: () {
                          router.pop(context);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            router.navigateTo(context, "/profile", transition: TransitionType.nativeModal);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new ListTile(
                      leading: Icon(Icons.home, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Home", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.notifications, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Announcements", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/home/announcements", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.people, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Conferences", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/conferences", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.event_note, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Events", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/events", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.chat, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Chat", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/chat", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.settings, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Settings", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/settings", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                  ],
                ),
                new Container(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  width: double.infinity,
                  child: new RaisedButton(
                    onPressed: () {
                      currUser = new user.User.plain();
                      FirebaseAuth.instance.signOut();
                      router.navigateTo(context, "/auth-checker", transition: TransitionType.fadeIn, replace: true);
                    },
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text("SIGN OUT"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
