import 'package:cd_mobile/generated/locales.g.dart';
import 'package:cd_mobile/pages/credits/credits.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/terms/terms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(GetMaterialApp(
    theme: ThemeData(fontFamily: 'Nunito'),
    // Locales
    translationsKeys: AppTranslation.translations,
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),
    debugShowCheckedModeBanner: false,
    title: 'Material App',
    initialRoute: '/',
    getPages: [
      GetPage(
          name: '/',
          page: () => HomePage(),
          transition: Transition.noTransition),
      GetPage(
          name: '/terms',
          page: () => const TermsPage(),
          transition: Transition.noTransition),
      GetPage(
          name: '/credits',
          page: () => const CreditsPage(),
          transition: Transition.noTransition),
      // GetPage(name: '/gameplay', page: () => GameplayPage(), transition: Transition.noTransition)
    ],
  ));
}
