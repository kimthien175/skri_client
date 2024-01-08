import 'package:cd_mobile/models/gif_manager.dart';
import 'package:get/get.dart';

Future<void> startUp() async {
  await Future.wait([GifManager.inst.loadResources()]);

  // TODO: POTENTIAL GETX'S FAULT, WHEN YOU REPLACE '/' TO OTHER ROUTE NAME, THEN DO HOT RELOAD/RESTART, THE SYSTEM WOULD NOT GO BACK TO '/loading' CAUSING LACKING RESOURCES FOR MOMENT, IT SEEMS TO BE THAT GETX TREAT '/' IN A SPECIAL WAY MORE THAN OTHER ROUTES
  Get.offAndToNamed('/');
}
