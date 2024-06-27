import 'package:cd_mobile/generated/locales.g.dart';
import 'package:cd_mobile/pages/credits/credits.dart';
import 'package:cd_mobile/pages/gameplay/gameplay.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/terms/terms.dart';
import 'package:cd_mobile/utils/navigator_observer.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ResourcesController.inst;
  usePathUrlStrategy();
  runApp(GetMaterialApp(
    theme: ThemeData(fontFamily: 'Nunito'),
    // Locales
    translationsKeys: AppTranslation.translations,
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),
    debugShowCheckedModeBanner: false,
    title: 'Material App',
    initialRoute: '/gameplay ',
    getPages: [
      GetPage(
          name: '/',
          page: () => const HomePage(),
          transition: Transition.noTransition,
          binding: HomeBindings()),
      GetPage(name: '/terms', page: () => const TermsPage(), transition: Transition.noTransition),
      GetPage(
          name: '/credits', page: () => const CreditsPage(), transition: Transition.noTransition),
      GetPage(
          name: '/gameplay',
          page: () => const GameplayPage(),
          transition: Transition.noTransition,
          binding: GameplayBinding())
    ],
    navigatorObservers: [MyNavigatorObserver.inst],
  ));
}
