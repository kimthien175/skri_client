import 'package:cd_mobile/generated/locales.g.dart';
import 'package:cd_mobile/pages/credits/credits.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/loading/loading.dart';
import 'package:cd_mobile/pages/terms/terms.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startUp();
  setPathUrlStrategy();
  runApp(GetMaterialApp(
    theme: ThemeData(fontFamily: 'Nunito'),
    // Locales
    translationsKeys: AppTranslation.translations,
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),
    debugShowCheckedModeBanner: false,
    title: 'Material App',
    initialRoute: '/loading',
    getPages: [
      GetPage(name: '/loading', page: () => const LoadingPage()),
      GetPage(name: '/', page: () => HomePage()),
      GetPage(name: '/terms', page: () => const TermsPage()),
      GetPage(name: '/credits', page: () => const CreditsPage()),
      GetPage(name:'/gameplay', page: ()=>GameplayPage())
    ],
  ));
}