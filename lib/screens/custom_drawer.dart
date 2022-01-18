import 'dart:convert';
import 'package:driverapp/screens/tabs.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driverapp/api/api.dart';
import 'package:driverapp/screens/full_profile.dart';
import 'package:driverapp/screens/sign_in.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int tappedIndex;
  var _userName = '';
  var _completeImage = '';
  var _isLoggedIn = false;
  var _isLoggedInagain = false;
  var showSpinner = false;

  @override
  void initState() {
    _getUserInfo();
    _getlogAgain();
    tappedIndex = 0;
    super.initState();
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<void> _getUserInfo() async {
    check().then((intenet) async {
      if (intenet != null && intenet) {
        setState(() {
          showSpinner = true;
        });
        var res = await CallApi().getWithToken('edit_profile');
        var body = json.decode(res.body);
        var theData = body['data'];
        setState(() {
          showSpinner = false;
        });
        _userName = theData['name'];
        _completeImage = theData['completeImage'];
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('لا يوجد اتصال بالانترنت'),
            content: Text('يرجى التحقق من الاتصال'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomDrawer(),
                      ));
                },
                child: Text('حسنا'),
              )
            ],
          ),
          context: context,
        );
      }
    });
  }

  Future<void> _getlogAgain() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    if (user != null) {
      setState(() {
        _isLoggedInagain = true;
      });
    }
  }

  Future<void> _getLoginInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => _isLoggedIn ? FullProfile() : SignIn()));
  }

  List items = [
    'سياسة الخصوصية',
    'الأسئلة الشائعة',
    'تسجيل الخروج',
  ];

  List<Icon> icons = [
    Icon(Icons.security),
    Icon(Icons.help),
    Icon(Icons.exit_to_app),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          child: Drawer(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  padding: EdgeInsets.only(top: 30, bottom: 30),
                  child: Center(
                    child: Text(
                      _isLoggedInagain == false
                          ? 'Login to continue'
                          : _userName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: icons[index],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              items[index],
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: tappedIndex == index
                                    ? Theme.of(context).primaryColor
                                    : darkBlue,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(
                            () {
                              // Navigator.pop(context);
                              // if (items[index] == 'الرئيسية') {
                              //   Navigator.pop(context);
                              // }
                              // if (items[index] == 'الحجوزات') {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (_) => AllAppointment()));
                              // }
                              // if (items[index] == 'الإشعارات') {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (_) => Notifications()));
                              // }
                              // if (items[index] == 'سياسة الخصوصية') {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (_) => PrivacyPolicy()));
                              // }
                              // if (items[index] == 'الأسئلة الشائعة') {
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (_) => FAQ()));
                              // }
                              // if (items[index] == 'تسجيل الخروج') {
                              //   CallApi().logout();
                              //   Navigator.pushReplacement(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => TabsScreen(),
                              //       ));
                              // }
                              // tappedIndex = index;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
