import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/pages/auth/register_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_page.dart';
import 'package:mydeca_flutter/pages/home/home_page.dart';
import 'package:mydeca_flutter/pages/startup/auth_checker.dart';
import 'package:mydeca_flutter/pages/startup/onboarding_page.dart';
import 'package:mydeca_flutter/utils/config.dart';
import 'package:mydeca_flutter/utils/service_account.dart';
import 'package:mydeca_flutter/utils/theme.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container(
    color: Colors.red.withOpacity(0.6),
    height: 100.0,
    child: new Material(
      child: new Center(
        child: new Text(details.exceptionAsString()),
      ),
    ),
  );

  await Firebase.initializeApp();

  // STARTUP ROUTES
  router.define('/auth-checker', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new AuthChecker();
  }));
  router.define('/onboarding', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new OnboardingPage();
  }));

  // AUTH ROUTES
  router.define('/register', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new RegisterPage();
  }));

  // HOME ROUTES
  router.define('/home', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new HomePage();
  }));

  // CONFERENCE ROUTES
  router.define('/conferences', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferencePage();
  }));

  runApp(new MaterialApp(
    title: "VC DECA",
    home: AuthChecker(),
    onGenerateRoute: router.generator,
    navigatorObservers: <NavigatorObserver>[routeObserver],
    debugShowCheckedModeBanner: false,
    theme: mainTheme,
  ));
}