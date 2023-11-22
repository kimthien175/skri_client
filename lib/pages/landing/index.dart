import 'package:cd_mobile/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  var ready = false.obs;
  var locale = Get.deviceLocale.toString().obs; // update when translations loading finish
  String name = "";

  getReady() {
    ready.value = true;
  }
}

class LandingPage extends StatelessWidget {
  //#region Singleton
  LandingPage._internal();
  static final LandingPage _inst = LandingPage._internal();
  static LandingPage get inst => _inst;
  //#endregion

  final LandingController controller = LandingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/background.png'))),
            child: Obx(() => controller.ready.isFalse
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(children: [
                    Image.asset(
                      'assets/landing_logo.gif'
                    ),
                    DropdownButton(
                        value: controller.locale.value,
                        items: GameTranslations.inst.keys.entries.map((entry) {
                          return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value['displayName']!));
                        }).toList(),
                        onChanged: (String? locale) {
                          // switch locale
                          List<String> lanRegion = locale!.split('_');
                          controller.locale.value = locale;
                          Get.updateLocale(Locale(lanRegion[0], lanRegion[1]));
                        }),
                    Text('displayName'.tr)
                  ])))));
  }
}
