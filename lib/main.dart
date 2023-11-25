import 'package:cd_mobile/pages/loading.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:cd_mobile/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startUp();
  runApp(GetMaterialApp(
    // Locales
    translations: GameTranslations.inst,
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),

    debugShowCheckedModeBanner: false,
    title: 'Material App',
    home: const Loading(),
  ));
}
