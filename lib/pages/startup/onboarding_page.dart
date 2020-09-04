import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/pages/auth/register_page.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/theme.dart';
import 'package:swipe_up/swipe_up.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  int imageFlex = 4;

  @override
  Widget build(BuildContext context) {
    return new SwipeUp(
      sensitivity: 0.5,
      onSwipe: () {
        router.navigateTo(context, "/register", transition: TransitionType.nativeModal, clearStack: true);
      },
      color: Colors.white,
      child: new Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(8),
          child: new Text(
            "GET STARTED",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
        ),
      ),
      body: Scaffold(
        backgroundColor: mainColor,
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Expanded(
              flex: imageFlex,
              child: new ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [mainColor, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: new Image.asset(
                  "images/onboarding-home.png",
                  fit: BoxFit.cover,
                  alignment: Alignment(0.45, 0),
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new Container(
                color: mainColor,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
