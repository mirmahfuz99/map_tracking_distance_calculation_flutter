import 'package:flutter/material.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/map_location_tracking.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MapLocationTrackingScreen(),
    );
  }
}

