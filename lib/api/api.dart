import 'dart:convert';
import 'package:background_location/background_location.dart';
import 'package:eventify/eventify.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class CallApi {
  static final EventEmitter emitter = new EventEmitter();
  // final String _url = 'http://192.168.1.20:8000/api/';
  // static const String noImageUrl = 'http://192.168.1.20:8000/images/upload/noimage.jpg';
  final String _url = 'https://akeed-clean.com/api/';
  static final String noImageUrl =
      'https://akeed-clean.com/images/upload/noimage.jpg';

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  postDataWithHeader(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(Uri.parse(fullUrl),
        body: data, headers: _setHeaders());
  }

  postDataWithToken(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token') ?? "";
    var req =
        await http.post(Uri.parse(fullUrl), body: json.encode(data), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token
    });

    if (req.statusCode == 401) {
      return logout();
    }

    return req;
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(Uri.parse(fullUrl), headers: _setHeader());
  }

  _setHeaders() => {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
      };

  _setHeader() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  Future getWithToken(apiUrl) async {
    var fullUrl = _url + apiUrl;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    // print('token from api $token');
    return await http.get(Uri.parse(fullUrl), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
  }

  logout() async {
    await CallApi().postDataWithToken({
      "status": "0",
    }, 'set_coworker_status');
    BackgroundLocation.stopLocationService();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    localStorage.remove('token');
  }
}
