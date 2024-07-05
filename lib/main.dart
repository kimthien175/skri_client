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
    defaultTransition: Transition.noTransition,
    getPages: [
      GetPage(name: '/', page: () => const HomePage(), binding: HomeBindings()),
      GetPage(
        name: '/terms',
        page: () => const TermsPage(),
      ),
      GetPage(
        name: '/credits',
        page: () => const CreditsPage(),
      ),
      GetPage(
          name: '/gameplay', page: () => const GameplayPage(), binding: GameplayBinding())
    ],
    navigatorObservers: [NavObserver],
  ));
}
