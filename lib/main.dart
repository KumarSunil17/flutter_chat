import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/login_page.dart';
import 'package:flutter_chat/ui_components/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal/onesignal.dart';


final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ]
);

final analytics = FirebaseAnalytics();
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseApp mapp;

Future<String> getCurrentUser()async{
  FirebaseUser currentUser = await auth.currentUser();
  return currentUser != null ? currentUser.uid : null;
}

void configureApp(app) async {
  app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:788316081318:ios:56dceb6291f8655a',
      gcmSenderID: '788316081318',
      databaseURL: 'https://flutter-chat-f6130.firebaseio.com/',
    )
        : const FirebaseOptions(
      googleAppID: '1:788316081318:android:8657c0a9898cdbbe',
      apiKey: 'AIzaSyCyyu4Tt4-pWbJm4YLERnb-zBjI-w5nWy0',
      databaseURL: 'https://flutter-chat-f6130.firebaseio.com/',
    ),
  );

  await OneSignal.shared.init("5ff77e00-d3e7-404a-9c5d-1555747436ba", iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: true
  });
  await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true).then((allowed){
    if(!allowed){
      Toast.show("Notification feature may not work", app);
    }
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configureApp(mapp);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Color(0xFF002540),
        accentColorBrightness: Brightness.dark,
        accentColor: Color(0xFFF60100),
        primaryColor: Color(0xFF002540),
        primaryColorDark: Color(0xFF000000),
        primaryColorLight: Color(0xFF0070F7),
        textSelectionColor: Color(0xFFFFFFFF),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}