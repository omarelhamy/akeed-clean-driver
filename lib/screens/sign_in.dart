import 'dart:convert';
import 'package:driverapp/screens/tabs.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:driverapp/api/api.dart';
import 'forgot_password.dart';

const darkBlue = Color(0xFF265E9E);
const containerShadow = Color(0xFF91B4D8);
const extraDarkBlue = Color(0xFF91B4D8);

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  FocusNode email = FocusNode();
  FocusNode password = FocusNode();
  var showSnipper = false;
  var playerIddd;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getDeviceToken();
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

  getDeviceToken() async {
    check().then((intenet) async {
      if (intenet != null && intenet) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        var playerId = await messaging.getToken();
        playerIddd = playerId;
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('device_token', playerId);
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('No Internet Connection'),
            content: Text('يرجى التحقق من الاتصال'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
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

  void _login(data) async {
    check().then((intenet) async {
      if (intenet != null && intenet) {
        setState(() {
          showSnipper = true;
        });
        SharedPreferences localStorage = await SharedPreferences.getInstance();

        var navigate = TabsScreen();
        var deviceToken = playerIddd;
        data['device_token'] = deviceToken;
        data['coworker_login'] = '1';
        var res;
        var body;
        var resData;
        var userId;
        try {
          res = await CallApi().postData(data, 'login');
          body = json.decode(res.body);
          resData = body['data'];
          if (body['success'] == true) {
            _emailController.text = '';
              _passwordController.text = '';
              SharedPreferences localStorage =
                  await SharedPreferences.getInstance();
              localStorage.setString('token', resData['token']);
              localStorage.setString('user', json.encode(resData));
              var abc = localStorage.getString('token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TabsScreen(),
                ),
              );
          } else {
            showDialog(
              builder: (context) => AlertDialog(
                title: Text('خطأ'),
                content: Text(body['message'].toString()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
//                Navigator.popAndPushNamed(context, Login.route);
                      Navigator.pop(context);
                    },
                    child: Text('يرجى المحاولة مرة اخرى'),
                  )
                ],
              ),
              context: context,
            );
          }
        } catch (e) {
          showDialog(
            builder: (context) => AlertDialog(
              title: Text('خطأ'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('يرجى المحاولة مرة اخرى'),
                )
              ],
            ),
            context: context,
          );
        }
        setState(() {
          showSnipper = false;
        });
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('خطأ'),
            content: Text('يرجى الـتأكد من اتصالك بالانترنت'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSnipper,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 30),
                  color: Theme.of(context).primaryColor,
                  child: Center(
                      child: Image.asset(
                    'assets/images/logo_white.png',
                    width: 200,
                  )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 20.0,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(35.0)),
                            boxShadow: [
                              BoxShadow(
                                color: containerShadow,
                                blurRadius: 2,
                                offset: Offset(0, 0),
                                spreadRadius: 1,
                              )
                            ]),
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: email,
                          onFieldSubmitted: (a) {
                            email.unfocus();
                            FocusScope.of(context).requestFocus(password);
                          },
                          validator: (value) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            // Null check
                            if (value.isEmpty) {
                              return 'الرجاء ادخال البريد الالكتروني';
                            }
                            // Valid email formatting check
                            else if (!regex.hasMatch(value)) {
                              return 'الرجاء ادخال بريد الكتروني صحيح';
                            }
                            // success condition
                            return null;
                          },
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            suffixIcon: SvgPicture.asset(
                              'assets/icons/usericon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                            hintText: 'البريد الالكتروني',
                            hintStyle: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(35.0)),
                            boxShadow: [
                              BoxShadow(
                                color: containerShadow,
                                blurRadius: 2,
                                offset: Offset(0, 0),
                                spreadRadius: 1,
                              )
                            ]),
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "الرجاء ادخال كلمة المرور";
                            } else if (value.length < 6) {
                              return "كلمة المرور قصيرة جدا";
                            } else {
                              return null;
                            }
                          },
                          focusNode: password,
                          onFieldSubmitted: (a) {
                            password.unfocus();
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            suffixIcon: SvgPicture.asset(
                              'assets/icons/lockicon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                            hintText: 'كلمة المرور',
                            hintStyle: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ));
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: extraDarkBlue,
                              fontFamily: 'Cairo',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            child: RaisedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  final body = {
                                    "email": _emailController.text,
                                    "password": _passwordController.text,
                                    "provider": "LOCAL",
                                  };
                                  _login(body);
                                }
                              },
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
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
