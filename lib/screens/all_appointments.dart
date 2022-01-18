import 'dart:convert';

import 'package:driverapp/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';

import 'appointment_detail.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class AppointmentsScreen extends StatefulWidget {
  AppointmentsScreen({Key key}) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  bool showSpinner = true;
  List<Map<String, dynamic>> ongoing = [];
  List<Map<String, dynamic>> past = [];

  TabController _tabController;
  bool mapView = false;

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _mapController = Completer();
  static const LatLng _center = const LatLng(45.343434, -122.545454);
  LatLng _lastMapPosition = _center;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.6169529, 46.543946),
    zoom: 14.4746,
  );

  Animation<double> _animation;
  AnimationController _animationController;

  List<Map<String, dynamic>> _ongoing = [];
  List<Map<String, dynamic>> _past = [];

  Map<String, dynamic> _selectedAppointment = null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchData();

    getCurrentLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    CallApi.emitter.on('notification', context, (ev, context) {
      fetchData();
    });
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _mapController.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        ),
      ));
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  Future<void> fetchData() async {
    try {
      var res = await CallApi().getWithToken('coworker_appointment');
      setState(() {
        _ongoing = List<Map<String, dynamic>>.from(
            json.decode(res.body)['data']['ongoing']);
        _past = List<Map<String, dynamic>>.from(
            json.decode(res.body)['data']['past']);

        _ongoing = _ongoing.map((e) {
          DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm a");
          e['full_date'] = inputFormat.parse(
              '${e['date']} ${e['start_time'].toString().toUpperCase()}');
          return e;
        }).toList();
        _past = _past.map((e) {
          DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm a");
          e['full_date'] = inputFormat.parse(
              '${e['date']} ${e['start_time'].toString().toUpperCase()}');
          return e;
        }).toList();

        _ongoing.sort((a, b) => a['full_date'].compareTo(b['full_date']));
        _past.sort((a, b) => a['full_date'].compareTo(b['full_date']));

        ongoing = _ongoing.toList();
        past = _past.toList();
      });

      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          setState(() {
            mapView = !mapView;
          });
        },
        child: Icon(mapView ? Icons.list : Icons.map),
      ),
      appBar: !mapView
          ? AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(.6),
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Colors.white.withOpacity(.6),
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
                indicatorColor: Colors.white,
                isScrollable: true,
                controller: _tabController,
                tabs: [
                  Tab(
                    text: 'حجوزات اليوم',
                  ),
                  Tab(
                    text: 'الحجوزات السابقة',
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => fetchData(),
                ),
              ],
            )
          : null,
      backgroundColor: Colors.grey.shade100,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: !mapView
            ? TabBarView(
                controller: _tabController,
                children: [
                  buildList(ongoing),
                  buildList(past),
                ],
              )
            : renderMap(),
      ),
    );
  }

  Widget renderMap() {
    return Stack(
      children: [
        GoogleMap(
          markers: Set<Marker>.of(_markers.values),
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          // padding: EdgeInsets.only(bottom: 70, top: 130, left: 5, right: 5),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
        ),
        if (_selectedAppointment != null)
          Container(
            height: 150,
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => AppointmentDetailScreen(
                        appoinmentId: _selectedAppointment['id'],
                      ),
                    ),
                  );
                  fetchData();
                },
                contentPadding: EdgeInsets.all(10.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedAppointment["appointment_id"] ?? "",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 18,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      '${_selectedAppointment["amount"]} ريال',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 7.0),
                    Text(
                      '${_selectedAppointment["date"]} - ${_selectedAppointment["start_time"].toString().toUpperCase()}',
                      style: TextStyle(
                        color: extraDarkBlue,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                      textDirection: material.TextDirection.ltr,
                    ),
                    Text(
                      'الخدمة: ${_selectedAppointment["service"]["service_name"]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: extraDarkBlue,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    )
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedAppointment = null;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_mapController.isCompleted) {
      return;
    }
    _mapController.complete(controller);
    // controller.animateCamera(
    //   CameraUpdate.newCameraPosition(
    //     CameraPosition(
    //       target: new LatLng(lat, lng),
    //       zoom: 17.0,
    //     ),
    //   ),
    // );

    _ongoing.forEach((coworker) {
      String lat = coworker["lat"];
      String lng = coworker["lang"];
      if (lat != null && lat.isNotEmpty && lng != null && lng.isNotEmpty) {
        MarkerId markerId = MarkerId(coworker["id"].toString());
        Marker marker = Marker(
          markerId: markerId,
          position: new LatLng(double.parse(lat), double.parse(lng)),
          draggable: false,
          onTap: () {
            setState(() {
              _selectedAppointment = coworker;
            });
          },
        );
        setState(() {
          _markers[markerId] = marker;
        });
      }
    });
  }

  Widget buildList(List<Map<String, dynamic>> list, {bool isPast = false}) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "لا يوجد حجوزات",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(5),
      itemBuilder: (ctx, count) {
        Map<String, dynamic> apt = list[count];
        return Card(
          child: ListTile(
            onTap: () async {
              if (!isPast)
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => AppointmentDetailScreen(
                      appoinmentId: apt['id'],
                    ),
                  ),
                );
              fetchData();
            },
            contentPadding: EdgeInsets.all(10.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  apt["appointment_id"],
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  '${apt["amount"]} ريال',
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${apt["date"]} - ${apt["start_time"].toString().toUpperCase()}',
                  style: TextStyle(
                    color: extraDarkBlue,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                  textDirection: material.TextDirection.ltr,
                ),
                Text(
                  'الخدمة: ${apt["service"]["service_name"]}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: extraDarkBlue,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'الحالة: ${renderStatus(apt['appointment_status'])}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                )
              ],
            ),
          ),
        );
      },
      itemCount: list.length,
    );
  }

  renderStatus(AppointmentDetailScreenStatus) {
    if (AppointmentDetailScreenStatus == 'PENDING') {
      return "قيد الانتظار";
    } else if (AppointmentDetailScreenStatus == 'ACCEPT') {
      return "تم قبول الطلب";
    } else if (AppointmentDetailScreenStatus == 'APPROVE') {
      return "قيد التنفيذ";
    } else if (AppointmentDetailScreenStatus == 'CANCEL') {
      return "تم الإلغاء";
    } else if (AppointmentDetailScreenStatus == 'COMPLETE') {
      return "تم الإنتهاء";
    }
  }
}
