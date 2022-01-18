import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '/api/api.dart';

const darkBlue = Color(0xFF265E9E);
const containerShadow = Color(0xFF91B4D8);
const extraDarkBlue = Color(0xFF91B4D8);

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  var showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF66BF4B),
          automaticallyImplyLeading: true,
          elevation: 0,
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 30),
                color: Theme.of(context).primaryColor,
                child: Center(child: Image.asset('assets/images/logo_white.png', width: 200,)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: const [
                        Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 20.0,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0, top: 15),
                          child: Text(
                            'ادخل بريدك الالكتروني لاسترجاع كلمة المرور',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: extraDarkBlue,
                              fontSize: 16.0,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                              Radius.circular(35.0)),
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
                        validator: (value) {
                          Pattern pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          // Null check
                          if (value.isEmpty) {
                            return 'البريد الالكتروني مطلوب';
                          }
                          // Valid email formatting check
                          else if (!regex.hasMatch(value)) {
                            return 'البريد الالكتروني غير صحيح';
                          }
                          // success condition
                          return null;
                        },
                        enableSuggestions: false,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(15),
                          border: InputBorder.none,
                          hintText: 'البريد الالكتروني',
                          hintStyle: TextStyle(
                            color: extraDarkBlue,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: const TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(35.0)),
                      ),
                      child: RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            final body = {
                              "email": _emailController.text,
                            };
                            _forgotPassword(body);
                          }
                        },
                        elevation: 2.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(35.0),
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        child: const Text(
                          'استرجاع كلمة المرور',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _forgotPassword(data) async {
    setState(() {
      showSpinner = true;
    });
    var res;
    var body;
    var userId;
    try {
      res = await CallApi().postData(data, 'forgot_password');
      body = json.decode(res.body);
      if (_emailController.text.isNotEmpty) {
        if (body['success'] == true) {
          setState(() {
            showSpinner = false;
          });
          userId = body['data']['id'];
          Navigator.pop(context);
        } else {
          showDialog(
            builder: (context) => AlertDialog(
              title: Text('خطأ'),
              content: Text(body['data'].toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      showSpinner = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('حاول مرة اخرى'),
                )
              ],
            ),
            context: context,
          );
        }
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text('خطأ'),
            content: Text('البريد الالكتروني مطلوب'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    showSpinner = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('حاول مرة اخرى'),
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
                setState(() {
                  showSpinner = false;
                });
                Navigator.pop(context);
              },
              child: Text('حاول مرة اخرى'),
            )
          ],
        ),
        context: context,
      );
    }
  }
}
