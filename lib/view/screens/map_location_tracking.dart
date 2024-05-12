import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/controller/map_tracking_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapTrackingController>(
      builder: (mapTrackingController){
        double distance = 0.0;
        if(mapTrackingController.currentLocation != null){
          distance = mapTrackingController.calculateDistance();
        }

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
                            target: mapTrackingController.sourceLocation, zoom: 15),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(mapTrackingController.markers!.values),
                        polylines: Set<Polyline>.of(mapTrackingController.polylines.values),
                        onLongPress: (latLng){
                          mapTrackingController.addDestination(latLng);
                          /// destination marker
                          mapTrackingController.addMarker(mapTrackingController.destination, "destination",
                            BitmapDescriptor.defaultMarker,
                          );
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
                                Center(child: Text("You Can Choose Destination By LongPress On Map!", style: robotoBold.copyWith(color: Theme.of(context).primaryColor),)),
                                const SizedBox(height: Dimensions.paddingSizeDefault,),
                                const Text("Distance Between Point A & Point B",style: robotoBold,),
                                const SizedBox(height: Dimensions.paddingSizeDefault,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(Images.distance,scale: 3,),
                                    const SizedBox(width: Dimensions.paddingSizeExtraLarge,),
                                    Expanded(child: Text("Distance Between Current Location to Destination :  ${distance.toPrecision(2)} km",style: robotoMedium,)),
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
                                        mapTrackingController.getCurrentLocation();
                                        /// source marker point A
                                        mapTrackingController.addMarker(mapTrackingController.sourceLocation, "origin", BitmapDescriptor.defaultMarker);
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
                                        mapTrackingController.polylineCoordinates.clear();
                                      },
                                      buttonText: "End Tracking",
                                    )
                                  ],
                                ),
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


  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }
}