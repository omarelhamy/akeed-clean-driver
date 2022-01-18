import 'dart:convert';

import 'package:driverapp/screens/appointment_detail.dart';
import 'package:driverapp/screens/sign_in.dart';
import 'package:driverapp/screens/tabs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final navKey = new GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: const Text(
        'Error!',
        style: TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };

  _initNotis();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final RemoteMessage initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _firebaseMessagingBackgroundHandler(initialMessage);
  }
  FirebaseMessaging.onMessageOpenedApp
      .listen(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final Map<String, dynamic> data = message.data;
  navKey.currentState.push(
    MaterialPageRoute(
      builder: (context) => AppointmentDetailScreen(
        appoinmentId: data['appointment_id'],
      ),
    ),
  );
}

Future _initNotis() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
}

void onDidReceiveLocalNotification(
    int id, String title, String body, String payload) {
  print('NOTIFICATION: $payload');
}

void onSelectNotification(String body) {
  final Map<String, dynamic> data = jsonDecode(body ?? '{}');
  print('NOTIFICATION: $data');

  navKey.currentState.push(
    MaterialPageRoute(
      builder: (context) => AppointmentDetailScreen(
        appoinmentId: data['appointment_id'],
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Akeed Clean Driver',
      debugShowCheckedModeBanner: false,
      locale: const Locale("ar", "AR"),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF65BF4B),
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.transparent,
        fontFamily: "Cairo",
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? Container(),
        );
      },
      routes: <String, WidgetBuilder>{
        '/Login': (BuildContext context) => SignIn(),
        '/appointment_details': (BuildContext context) =>
            AppointmentDetailScreen(),
        '/Tabs': (BuildContext context) => TabsScreen(),
        // '/AllAppointment': (BuildContext context) => AllAppointment(),
      },
    );
  }
}
