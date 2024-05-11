import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/constants.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/dimensions.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/images.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/styles.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/view/base/custom_button.dart';

class MapLocationTrackingScreen extends StatefulWidget {
  const MapLocationTrackingScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapLocationTrackingScreen> {
  late GoogleMapController mapController;
  /*double _originLatitude = 37.4223, _originLongitude = -122.0848;
  double _destLatitude = 37.3346, _destLongitude = -122.0090;
  */
  double _originLatitude = 23.76852131771742, _originLongitude = 90.3673231832651;
  double _destLatitude = 23.989312321830415 , _destLongitude = 90.3821892500332;
  // double _originLatitude = 26.48424, _originLongitude = 50.04551;
  // double _destLatitude = 26.46423, _destLongitude = 50.06358;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = google_api_key;

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
      BitmapDescriptor.defaultMarker,
      // BitmapDescriptor.defaultMarkerWithHue(90)
    );
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
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
                        target: LatLng(_originLatitude, _originLongitude), zoom: 15),
                    myLocationEnabled: true,
                    tiltGesturesEnabled: true,
                    compassEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    onMapCreated: _onMapCreated,
                    markers: Set<Marker>.of(markers.values),
                    polylines: Set<Polyline>.of(polylines.values),
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

                              },
                              buttonText: "End Tracking",
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );

              })
            ],
          )
      ),
    );
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
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving);

    print(result.points);

    if (result.points.isNotEmpty) {
      print("inside_result_not_empty");
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}