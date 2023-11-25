import 'package:cd_mobile/models/avatar_editor.dart';
import 'package:cd_mobile/utils/translations.dart';
import 'package:cd_mobile/widgets/landing_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  var locale = Get.deviceLocale.toString().obs; // update when translations loading finish
  String name = "";
}

class LandingPage extends StatelessWidget {
  //#region Singleton
  // LandingPage._internal();
  // static final LandingPage _inst = LandingPage._internal();
  // static LandingPage get inst => _inst;
  //#endregion

  final LandingController controller = LandingController();

  LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration:
                const BoxDecoration(image: DecorationImage(scale: 1.2, repeat: ImageRepeat.repeat, image: AssetImage('assets/background.png'))),
            child: Center(
                child: Column(children: [
                  LandingLogo(),      
                  AvatarEditor(),
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
            ]))));
  }
}
