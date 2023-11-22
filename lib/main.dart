import 'package:cd_mobile/pages/landing/index.dart';
import 'package:cd_mobile/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GameTranslations.inst.init();
  runApp(GetMaterialApp(
    // Locales
    translations: GameTranslations.inst,
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),

    debugShowCheckedModeBanner: false,
    title: 'Material App',
    home: LandingPage.inst,
  ));
}
