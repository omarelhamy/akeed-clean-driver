import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:driverapp/api/api.dart';
import 'package:map_launcher/map_launcher.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);
const ratingStar = Color(0xFFFECD03);

class AppointmentDetailScreen extends StatefulWidget {
  final appoinmentId;
  AppointmentDetailScreen({this.appoinmentId});
  @override
  _AppointmentDetailScreenState createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  var showSpinner;
  var previousAppointmentDetailScreenId;
  var image = '';
  var employeeName = '';
  var AppointmentDetailScreenDate = '';
  var AppointmentDetailScreenId = '';
  var AppointmentDetailScreenStatus = '';
  var AppointmentDetailScreenStatusKey = '';
  var AppointmentDetailScreenTime = '';
  var selectedServiceName;
  var selectedServiceAmount;
  var selectedServiceDescription;
  var totalCharge = 0;
  var totalDiscount = '';
  var totalPay = '';
  var totalDuration = '';
  var paymentDoneBy = '';
  var rate;
  var comment;
  var sendData;
  var visible = 0;
  var cancel = 0;
  var lng = '';
  var lat = '';
  var clientNotes = '';

  List<Map<String, dynamic>> vas = [];

  @override
  void initState() {
    previousAppointmentDetailScreenId = widget.appoinmentId;
    GetAppointmentDetailScreenData();
    super.initState();
  }

  Future<void> GetAppointmentDetailScreenData() async {
    setState(() {
      showSpinner = true;
    });

    CallApi.updateLocation();
    var res = await CallApi().getWithToken(
        'get_coworker_appointment/$previousAppointmentDetailScreenId');
    var body = json.decode(res.body);

    if (body['data'] == null) {
      Fluttertoast.showToast(msg: 'appointment_not_found'.tr);
      return Navigator.pop(context);
    }

    var theData = body['data'];
    var coworker = theData['coworker'];
    AppointmentDetailScreenId = theData['appointment_id'];
    AppointmentDetailScreenStatus = theData['appointment_status'];
    AppointmentDetailScreenStatusKey = theData['appointment_status'];

    lng = theData['lang'];
    lat = theData['lat'];

    if (AppointmentDetailScreenStatus == 'PENDING') {
      setState(() {
        AppointmentDetailScreenStatus = 'pending'.tr;
      });
    } else if (AppointmentDetailScreenStatus == 'ACCEPT') {
      setState(() {
        AppointmentDetailScreenStatus = 'accepted'.tr;
      });
    } else if (AppointmentDetailScreenStatus == 'APPROVE') {
      setState(() {
        AppointmentDetailScreenStatus = 'approved'.tr;
      });
    } else if (AppointmentDetailScreenStatus == 'CANCEL') {
      setState(() {
        AppointmentDetailScreenStatus = 'canceled'.tr;
      });
    } else if (AppointmentDetailScreenStatus == 'COMPLETE') {
      setState(() {
        AppointmentDetailScreenStatus = 'completed'.tr;
      });
    }

    image = coworker['completeImage'];
    employeeName = coworker['name'];
    AppointmentDetailScreenDate = theData['date'];
    AppointmentDetailScreenTime = theData['start_time'];
    totalDiscount = theData['discount'] ?? "";
    totalDuration = theData['duration'];
    totalPay = theData['amount'];
    clientNotes = theData['address'];
    try {
      totalCharge = (totalDiscount != null && totalDiscount.isNotEmpty
          ? double.parse(totalDiscount) + double.parse(totalPay)
          : 0);
    } catch (_) {
      totalCharge = (totalDiscount != null && totalDiscount.isNotEmpty
          ? int.parse(totalDiscount) + int.parse(totalPay)
          : 0);
    }
    paymentDoneBy = theData['payment_type'];
    rate = coworker['rate'];
    var showStatus = theData['appointment_status'];
    if (showStatus == 'COMPLETE' || showStatus == 'CANCEL') {
      visible = 1;
    }

    if (showStatus == 'PENDING') {
      cancel = 1;
    }

    vas.clear();
    for (int i = 0; i < theData['service'].length; i++) {
      Map<String, dynamic> map = theData['service'][i];
      vas.add(map);
    }

    setState(() {
      showSpinner = false;
    });
  }

  Future<void> UpdateAppintment(status) async {
    CallApi.updateLocation();
    showDialog(
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr),
        content: Text('confirm_status'.tr),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                showSpinner = true;
              });

              var res = await CallApi().postDataWithToken({},
                  'update_appointment_status/$previousAppointmentDetailScreenId/$status');
              var body = json.decode(res.body);
              if (body['success'] == true) {
                GetAppointmentDetailScreenData();
              }
              else {
                Fluttertoast.showToast(msg: 'try_again'.tr);
              }

              setState(() {
                showSpinner = false;
              });
            },
            child: Text('ok'.tr),
          )
        ],
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          'appointment_details'.tr,
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${'status'.tr} : $AppointmentDetailScreenStatus',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (await MapLauncher.isMapAvailable(
                                    MapType.google)) {
                                  await MapLauncher.showMarker(
                                    mapType: MapType.google,
                                    coords: Coords(
                                        double.parse(lat), double.parse(lng)),
                                    title: 'client_location'.tr,
                                    description: 'client_location'.tr,
                                  );
                                } else if (await MapLauncher.isMapAvailable(
                                    MapType.apple)) {
                                  await MapLauncher.showMarker(
                                    mapType: MapType.apple,
                                    coords: Coords(
                                        double.parse(lat), double.parse(lng)),
                                    title: 'client_location'.tr,
                                    description: 'client_location'.tr,
                                  );
                                }
                              },
                              icon: Icon(Icons.pin_drop_sharp),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        if (clientNotes != null && clientNotes.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                clientNotes,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        SizedBox(height: 20),
                        Text(
                          '${'appointment_number'.tr} : $AppointmentDetailScreenId',
                          style: TextStyle(
                            color: extraDarkBlue,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'date'.tr,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18.0,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          '$AppointmentDetailScreenDate - ${AppointmentDetailScreenTime.toString().toUpperCase()}',
                          style: TextStyle(
                            color: extraDarkBlue,
                            fontSize: 14.0,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'services'.tr,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 10.0),
                        ListView.separated(
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.0),
                          shrinkWrap: true,
                          itemCount: vas.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic>
                                viewAppointmentDetailScreenservice = vas[index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                  )
                                ],
                              ),
                              child: Container(
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).primaryColor,
                                        spreadRadius: -1.0,
                                        offset: Offset(-5, 0)),
                                  ],
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          viewAppointmentDetailScreenservice[
                                              "service_name"],
                                          style: TextStyle(
                                            color: darkBlue,
                                            fontSize: 18,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${totalCharge} ${'riyal'.tr}',
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontFamily: 'Cairo',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${'duration'.tr} : ${viewAppointmentDetailScreenservice["duration"]} دقيقة',
                                              style: TextStyle(
                                                color: extraDarkBlue,
                                                fontSize: 14,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          viewAppointmentDetailScreenservice[
                                              "description"],
                                          style: TextStyle(
                                            color: extraDarkBlue,
                                            fontSize: 14,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'invoice_details'.tr,
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 18.0,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '${'payment_done_by'.tr} $paymentDoneBy.',
                            style: TextStyle(
                              color: darkBlue,
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Center(
                            child: Text(
                              'subtotal'.tr,
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 14.0,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '$totalPay ${'riyal'.tr}',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 30.0,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    if (AppointmentDetailScreenStatusKey == 'PENDING')
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                UpdateAppintment('ACCEPT');
                              },
                              child: Text(
                                'accept_appointment'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              onPressed: () {
                                UpdateAppintment('CANCEL');
                              },
                              child: Text(
                                'cancel_appointment'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (AppointmentDetailScreenStatusKey == 'ACCEPT')
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            UpdateAppintment('APPROVE');
                          },
                          child: Text(
                            'start_appointment'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    if (AppointmentDetailScreenStatusKey == 'APPROVE' &&
                        paymentDoneBy == 'COD')
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () {
                            showDialog(
                              builder: (context) => AlertDialog(
                                title: Text('confirm'.tr),
                                content: Text(
                                    '${'payment_collected'.tr} $totalPay ${'ryial'.tr} ؟'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('no'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      UpdateAppintment('COMPLETE');
                                    },
                                    child: Text('ok'.tr),
                                  )
                                ],
                              ),
                              context: context,
                            );
                          },
                          child: Text(
                            'collect_payment'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    if (AppointmentDetailScreenStatusKey == 'APPROVE' &&
                        paymentDoneBy != 'COD')
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () {
                            UpdateAppintment('COMPLETE');
                          },
                          child: Text(
                            'complete_appointment'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
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
}
