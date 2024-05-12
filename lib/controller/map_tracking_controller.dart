import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/constants.dart';

class MapTrackingController extends GetxController implements GetxService {

  LatLng _sourceLocation = const LatLng(23.76852131771742, 90.3673231832651); // initial dummy source location
  LatLng get sourceLocation => _sourceLocation;


  LatLng _destination = const LatLng(23.989312321830415,  90.3821892500332); // initial dummy destination location
  LatLng get destination => _destination;



  LocationData? _currentLocation;
  LocationData? get currentLocation => _currentLocation;

  final Map<MarkerId, Marker> _markers = {};
  Map<MarkerId, Marker>? get markers => _markers;

  final Map<PolylineId, Polyline> _polylines = {};
  Map<PolylineId, Polyline> get polylines => _polylines;

  List<LatLng>? _polylineCoordinates;
  List<LatLng> get polylineCoordinates => _polylineCoordinates!;

  PolylinePoints polylinePoints = PolylinePoints();

  //todo: will be called from start tracking
  void getCurrentLocation () async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text("Google Location Service Is Required To Track Location"),
        ));
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }


    location.getLocation().then((location) {
      _currentLocation = location;
      _sourceLocation =  LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    });

    location.onLocationChanged.listen((event) {
      _currentLocation = event;
      _getPolyline();
    });
  }

  //todo: will be called from start tracking
  void addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    _markers[markerId] = marker;
    update();
  }


  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(_sourceLocation.latitude, _sourceLocation.longitude),
        PointLatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), // real time updated current location lat & long
        // const PointLatLng(23.76852131771742, 90.3673231832651), // to test polyline if works fine
        travelMode: TravelMode.driving);

    // print(result.points);
    if (result.points.isNotEmpty) {
      _polylineCoordinates = [];
      result.points.forEach((PointLatLng point) {
        _polylineCoordinates!.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(polylineId: id, color: Colors.red, points: _polylineCoordinates!);
    _polylines[id] = polyline;
    update();
  }

  void addDestination(LatLng latLng){
    _destination = LatLng(latLng.latitude, latLng.longitude);
    update();
  }

  double calculateDistance(){

    var lat1 = _currentLocation!.latitude;
    var lon1 = _currentLocation!.longitude;
    var lat2 = _destination.latitude;
    var lon2 = _destination.longitude;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1!) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1!) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}