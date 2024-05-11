import 'package:get/instance_manager.dart';
import 'package:map_tracking_distance_calculation_flutter_bloc/controller/map_tracking_controller.dart';


class MapTrackingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapTrackingController());
  }
}