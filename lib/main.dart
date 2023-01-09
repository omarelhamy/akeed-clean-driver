import 'dart:convert';

import 'package:driverapp/api/api.dart';
import 'package:driverapp/screens/appointment_detail.dart';
import 'package:driverapp/screens/sign_in.dart';
import 'package:driverapp/screens/tabs.dart';
import 'package:driverapp/translations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // In release builds, show a yellow-on-t(blue message instead:

    try {
      CallApi().postData({ "app": "driver", "ex": details.exception.toString(), "stack": details.stack.toString(), "library": details.library, "date": DateTime.now().toString() }, 'crash');
    } catch (e) {}

    return Material(
      child: Container(
        alignment: Alignment.center,
        child: ListView(
          children: [
            Center(
              child: const Text(
                'Something went wrong!',
                style: TextStyle(fontSize: 24),
                textDirection: TextDirection.ltr,
              ),
            ),
            SizedBox(height: 15),
            Center(child: Text("Please restart the app"))
          ],
        ),
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
  

  runApp(RestartWidget(child: MyApp()));
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

  if (data['open'] != false) {
    navKey.currentState.push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(
          appoinmentId: data['appointment_id'],
        ),
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isArabic = true;
  Locale locale = Locale("ar", "EG");

  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  Future<void> _getLanguage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      if (localStorage.containsKey('isArabic')) {
        isArabic = localStorage.getBool('isArabic') ?? true;
      }
      locale = isArabic ? Locale("ar", "EG") : Locale('en', 'US');
      Get.updateLocale(isArabic ? Locale("ar", "EG") : Locale('en', 'US'));
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: Locale('ar', 'EG'),
      navigatorKey: navKey,
      title: 'Akeed Clean Driver',
      debugShowCheckedModeBanner: false,
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
        return StatefulBuilder(builder: (context, setState) {
          return Directionality(
            textDirection: isArabic == true ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? Container(),
          );
        });
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
