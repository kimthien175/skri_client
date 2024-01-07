import 'package:cd_mobile/models/gif_manager.dart';
import 'package:get/get.dart';

Future<void> startUp() async {
  await Future.wait([GifManager.inst.loadResources()]);

  Get.offAndToNamed('/gameplay');
}
