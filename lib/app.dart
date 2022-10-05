import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    const _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      Navigator.of(context).pushReplacementNamed('/Tabs');
    } else {
      Navigator.of(context).pushReplacementNamed('/Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 250,
              ),
            ),
            Positioned(
              child: Center(
                child: SizedBox(
                  child: Image.asset('assets/images/dplogo.png'),
                  width: 100,
                ),
              ),
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 50,
            ),
          ],
        ),
      ),
    );
  }
}
