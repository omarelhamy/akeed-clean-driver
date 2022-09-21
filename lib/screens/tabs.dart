import 'dart:convert';

import 'package:driverapp/api/api.dart';
import 'package:driverapp/screens/full_profile.dart';
import 'package:driverapp/screens/sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventify/eventify.dart';

import 'all_appointments.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen({Key key}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool status = false;

  bool isLoggedIn = true;
  final List tabs = [
    AppointmentsScreen(),
    FullProfile(fromTabs: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    requestNotificationsPerms();
    SharedPreferences.getInstance().then((value) {
      if (value.getString('token') != null) {
        setState(() {
          isLoggedIn = true;
        });

        FirebaseMessaging.instance.getToken().then((token) async {
          try {
            var res = await CallApi()
                .postDataWithToken({"token": token}, 'updateToken');
            print('BODY: ' + res.body);
          } catch (e) {
            print('errror' + e);
          }
        });
      }
    });

    CallApi().getWithToken('get_coworker_status').then((res) {
      var body = json.decode(res.body);
      if (body['success'] == true) {
        // if (body['data'] == 1)
        //   BackgroundLocation.startLocationService();
        // else
        //   BackgroundLocation.stopLocationService();
        setState(() {
          status = body['data'] == 1 ? true : false;
        });
      }
    });
  }

  Future requestNotificationsPerms() async {
    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      handleNotifications();
    }

    CallApi.updateLocation();
    // BackgroundLocation.setAndroidConfiguration(1000);
    // await BackgroundLocation.setAndroidNotification(
    //   title: "Akeed clean Driver",
    //   message: "This app uses location services to track your location",
    //   icon: "@drawable/fcm",
    // );

    // BackgroundLocation.startLocationService();

    // BackgroundLocation.getLocationUpdates((location) async {
    //   var latitude = location.latitude.toString();
    //   var longitude = location.longitude.toString();

    //   var res = await CallApi().postDataWithToken(
    //       {"lat": latitude, "lon": longitude}, 'update_coworker_location');
    //   var body = json.decode(res.body);
    // });
  }

  void handleNotifications() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'akeed-notis',
      'All notifications',
      channelDescription: 'Receive app notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: "fcm",
      ticker: 'ticker',
    );

    const IOSNotificationDetails iOSNotificationDetails =
        IOSNotificationDetails(threadIdentifier: "akeed-notis");

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSNotificationDetails);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      CallApi.emitter.emit('notification', message.data);
      if (message.notification != null) {
        await FlutterLocalNotificationsPlugin().show(
          0,
          message.notification.title,
          message.notification.body,
          platformChannelSpecifics,
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
        selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "appointments".tr),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'account'.tr,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_white.png',
              height: 40,
            ),
            SizedBox(width: 15),
            Text(
              '${'status'.tr}: ${status == true ? 'available'.tr : 'unavailable'.tr}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Switch(
            value: status,
            onChanged: (c) async {
              CallApi.updateLocation();
              var res = await CallApi().postDataWithToken({
                "status": c ? "1" : "0",
              }, 'set_coworker_status');
              var body = json.decode(res.body);
              if (body['success'] == true) {
                // if (c == true)
                //   BackgroundLocation.startLocationService();
                // else
                //   BackgroundLocation.stopLocationService();
                setState(() {
                  status = c;
                });
              } else {
                Fluttertoast.showToast(msg: "something_went_wrong".tr);
                setState(() {
                  status = !c;
                });
              }
            },
          ),
          IconButton(
            onPressed: () {
              CallApi().logout();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignIn(),
                  ));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: tabs.elementAt(_selectedIndex),
    );
  }
}
