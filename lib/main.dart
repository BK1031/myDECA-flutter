import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_flutter/pages/announcement/announcement_details_page.dart';
import 'package:mydeca_flutter/pages/announcement/announcement_page.dart';
import 'package:mydeca_flutter/pages/announcement/new_announcement_page.dart';
import 'package:mydeca_flutter/pages/auth/register_page.dart';
import 'package:mydeca_flutter/pages/chat/chat_details_page.dart';
import 'package:mydeca_flutter/pages/chat/chat_page.dart';
import 'package:mydeca_flutter/pages/chat/chat_view_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_details_page.dart';
import 'package:mydeca_flutter/pages/conference/conference_page.dart';
import 'package:mydeca_flutter/pages/home/home_page.dart';
import 'package:mydeca_flutter/pages/settings/settings_about_page.dart';
import 'package:mydeca_flutter/pages/settings/settings_page.dart';
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

  // ANNOUNCEMENT ROUTES
  router.define('/home/announcements', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new AnnouncementsPage();
  }));
  router.define('/home/announcements/details', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new AnnouncementDetailsPage();
  }));
  router.define('/home/announcements/new', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new NewAnnouncementPage();
  }));

  // CONFERENCE ROUTES
  router.define('/conferences', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferencePage();
  }));
  router.define('/conferences/details', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferenceDetailsPage();
  }));

  // EVENT ROUTES
  router.define('/events', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferencePage();
  }));

  // CHAT ROUTES
  router.define('/chat', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ChatPage();
  }));
  router.define('/chat/view', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ChatViewPage();
  }));
  router.define('/chat/details', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ChatDetailsPage();
  }));

  // SETTINGS ROUTES
  router.define('/settings', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new SettingsPage();
  }));
  router.define('/settings/about', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new SettingsAboutPage();
  }));

  runApp(new MaterialApp(
    title: "VC DECA",
    home: AuthChecker(),
    onGenerateRoute: router.generator,
    debugShowCheckedModeBanner: false,
    theme: mainTheme,
  ));
}