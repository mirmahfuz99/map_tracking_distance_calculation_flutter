import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/utils/map_tracking_binding.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/view/screens/map_location_tracking.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
            name: '/',
            page: () => const MapLocationTrackingScreen(),
            binding: MapTrackingBinding(),
        ),
      ],
    );
  }
}

