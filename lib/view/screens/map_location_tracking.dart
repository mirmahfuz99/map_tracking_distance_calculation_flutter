import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/controller/map_tracking_controller.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/constants.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/dimensions.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/images.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/styles.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/view/base/custom_button.dart';
import 'dart:math' show cos, sqrt, asin;


class MapLocationTrackingScreen extends StatefulWidget {
  const MapLocationTrackingScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapLocationTrackingScreen> {
  late GoogleMapController mapController;
  static LatLng sourceLocation = LatLng(23.76852131771742, 90.3673231832651); // initial dummy location
  static LatLng destination = LatLng(23.989312321830415,  90.3821892500332); // Destination Point B will be selected with Search


  // double _originLatitude = 26.48424, _originLongitude = 50.04551;
  // double _destLatitude = 26.46423, _destLongitude = 50.06358;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = google_api_key;


  LocationData? currentLocation;


  @override
  void initState() {
    super.initState();




    // getCurrentLocation();
  }

  void getCurrentLocation () async {
    Location location = Location();


    location.getLocation().then((location) {
      currentLocation = location;
      sourceLocation =  LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      setState(() {});
    });


    location.onLocationChanged.listen((event) {
      currentLocation = event;
      // _getPolyline();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapTrackingController>(
      builder: (mapTrackingController){
        return SafeArea(
          child: Scaffold(
              extendBodyBehindAppBar: true,
              body: Stack(
                children: [
                  LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                    return SizedBox(
                      height: constraints.maxHeight / 1.5,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: sourceLocation, zoom: 15),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polylines.values),
                        onLongPress: (latlang){
                          destination = LatLng(latlang.latitude, latlang.longitude); //
                          /// destination marker
                          _addMarker(destination, "destination",
                            BitmapDescriptor.defaultMarker,
                            // BitmapDescriptor.defaultMarkerWithHue(90)
                          );

                          double destance =  calculateDistance(currentLocation!.latitude, currentLocation!.longitude, destination.latitude, destination.longitude);

                          print("distance: $destance km");



                          setState(() {});
                        },
                      ),
                    );
                  }),

                  DraggableScrollableSheet(
                      initialChildSize: 0.3,

                      builder: (BuildContext context, ScrollController scrollController){

                        return Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Distance Between Point A & Point B",style: robotoBold,),
                                const SizedBox(height: Dimensions.paddingSizeLarge,),


                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(Images.distance,scale: 3,),
                                    const SizedBox(width: Dimensions.paddingSizeExtraLarge,),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Text("Short Distance 34.4 km",style: robotoMedium,),
                                        Text("Medium Distance 34.4 km",style: robotoMedium,),
                                        Text("Long Distance 34.4 km",style: robotoMedium,),
                                      ],
                                    )

                                  ],
                                ),

                                const SizedBox(height: Dimensions.paddingSizeLarge,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomButton(
                                      fontSize: Dimensions.fontSizeDefault,
                                      radius: Dimensions.radiusExtraLarge,
                                      height: 45,
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.1),
                                      width: MediaQuery.of(context).size.width / 2.2,
                                      onPressed: (){
                                        getCurrentLocation();
                                        /// origin marker point A
                                        _addMarker(sourceLocation, "origin", BitmapDescriptor.defaultMarker);
                                      },
                                      buttonText: "Start Tracking",
                                    ),
                                    CustomButton(
                                      fontSize: Dimensions.fontSizeDefault,
                                      radius: Dimensions.radiusExtraLarge,
                                      height: 45,
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.1),
                                      width: MediaQuery.of(context).size.width / 2.2,
                                      onPressed: (){
                                        polylineCoordinates.clear();
                                      },
                                      buttonText: "End Tracking",
                                    )
                                  ],
                                ),
                                const Text("You Can Start Tracking By Click Start Tracking !", style: robotoMedium,)
                              ],
                            ),
                          ),
                        );

                      })
                ],
              )
          ),
        );
      },
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!), // real time updated current location lat & long
        // const PointLatLng(23.76852131771742, 90.3673231832651), // to test polyline works fine
        travelMode: TravelMode.driving);

    print(result.points);

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      print("inside_result_not_empty");
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}