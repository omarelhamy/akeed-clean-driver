import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:driverapp/screens/tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:driverapp/api/api.dart';
import 'package:driverapp/screens/custom_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class FullProfile extends StatefulWidget {
  final bool fromTabs;
  FullProfile({this.fromTabs = false});
  @override
  _FullProfileState createState() => _FullProfileState();
}

class _FullProfileState extends State<FullProfile> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File _image;
  var name = '';
  var phone;
  var image;
  var showSnipper = false;
  var image64;
  var imageData;
  var changeName;
  var apiName;
  var apiPassword;
  var completeImage = '';
  var nameChange = 0;
  var proPicChange = 0;
  var passwordCheck = 0;
  bool isArabic = true;
  List<Map<String, dynamic>> packages = [];

  @override
  void initState() {
    _getProfileInfo();
    _getLanguage();
    super.initState();
  }

  Future<void> _getLanguage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      isArabic = localStorage.getBool('isArabic');
    });
  }

  Future<void> _setLanguage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      localStorage.setBool('isArabic', isArabic);
      Get.updateLocale(isArabic ? Locale("ar", "EG") : Locale('en', 'US'));
    });
  }

  Future<void> updateImage() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(imageData, 'update_image');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabsScreen(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('error'.tr),
          content: Text('something_went_wrong'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('ok'.tr),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  Future<void> updateName(apiName) async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(apiName, 'update_profile');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabsScreen(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('error'.tr),
          content: Text('something_went_wrong'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('ok'.tr),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  Future<void> updatePassword(apiPassword) async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postDataWithToken(apiPassword, 'change_password');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomDrawer(),
          ));
    } else {
      showDialog(
        builder: (context) => AlertDialog(
          title: Text('error'.tr),
          content: Text('something_went_wrong'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text('ok'.tr),
            )
          ],
        ),
        context: context,
      );
    }
    setState(() {
      showSnipper = false;
    });
  }

  _imgFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    image = imagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
    final bytes = Io.File(image.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    image64 = img64;
    setState(() {
      _image = File.fromUri(new Uri(path: image.path));
      imageData = {"image": "$image64"};
    });
  }

  _imgFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile image = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    final bytes = Io.File(image.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    image64 = img64;
    setState(() {
      _image = File.fromUri(new Uri(path: image.path));
      imageData = {"image": "$image64"};
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('gallery'.tr),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('camera'.tr),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _getProfileInfo() async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().getWithToken('user');
    var body = json.decode(res.body);
    var theData = body['user'];
    var thePackages = body['packages'];
    packages = List<Map<String, dynamic>>.from(thePackages ?? []);
    name = theData['name'];
    phone = theData['phone'];
    completeImage = theData['completeImage'];
    setState(() {
      showSnipper = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showSnipper,
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'name'.tr,
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            TextField(
                              controller: TextEditingController()..text = name,
                              enableSuggestions: false,
                              keyboardType: TextInputType.visiblePassword,
                              onChanged: (name) {
                                nameChange = 1;
                                changeName = name;
                              },
                              decoration: InputDecoration(
                                hintText: 'enter_name'.tr,
                                hintStyle: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'Cairo',
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'phone'.tr,
                              style: TextStyle(
                                color: extraDarkBlue,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            TextField(
                              controller: TextEditingController()..text = phone,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Container(
                                  margin: EdgeInsets.all(10.0),
                                  height: 22,
                                  width: 61,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'confirmed'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                                hintText: '+966 121 222 55',
                                hintStyle: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                  letterSpacing: 0.2,
                                ),
                              ),
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontFamily: 'Cairo',
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 20.0),
                            CheckboxListTile(
                                value: isArabic,
                                title: Text('arabic'.tr),
                                onChanged: (val) {
                                  setState(() {
                                    isArabic = val;
                                    _setLanguage();
                                  });
                                }),
                            SizedBox(height: 20.0),
                            ExpansionTile(
                              title: Text(
                                'change_password'.tr,
                                style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18.0,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'current_password'.tr,
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    TextFormField(
                                      onTap: () {
                                        passwordCheck = 1;
                                      },
                                      controller: _oldPasswordController,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "enter_current_password".tr;
                                        } else if (value.length < 6) {
                                          return "short_password".tr;
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'Cairo',
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'new_password'.tr,
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "enter_new_password".tr;
                                        } else if (value.length < 6) {
                                          return "short_password".tr;
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'Cairo',
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text(
                                      'confirm_new_password'.tr,
                                      style: TextStyle(
                                        color: extraDarkBlue,
                                        fontSize: 14,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "enter_confirm_new_password"
                                              .tr;
                                        } else if (value !=
                                            _newPasswordController.text) {
                                          return "password_not_match".tr;
                                        } else {
                                          return null;
                                        }
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: '*******',
                                        hintStyle: TextStyle(
                                          color: darkBlue,
                                          fontSize: 18,
                                          fontFamily: 'Cairo',
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 18,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: 40.0),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              if (proPicChange == 1) {
                updateImage();
              }
              if (passwordCheck == 1) {
                apiPassword = {
                  "old_password": "${_oldPasswordController.text}",
                  "password": "${_newPasswordController.text}",
                  "password_confirmation": "${_confirmPasswordController.text}"
                };
                updatePassword(apiPassword);
              }
              if (nameChange == 1) {
                apiName = {"name": "$changeName"};
                updateName(apiName);
              }
            }
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
