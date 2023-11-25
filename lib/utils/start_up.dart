import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/landing/index.dart';
import 'package:cd_mobile/utils/translations.dart';
import 'package:get/get.dart';

Future<void> startUp() async {
  await Future.wait([GameTranslations.inst.init(), GifManager.inst.loadResources()]);

  Get.off(() => LandingPage());
}
