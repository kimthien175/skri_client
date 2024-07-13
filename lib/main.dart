import 'package:skribbl_client/generated/locales.g.dart';
import 'package:skribbl_client/pages/credits/credits.dart';
import 'package:skribbl_client/pages/gameplay/gameplay.dart';
import 'package:skribbl_client/pages/home/home.dart';
import 'package:skribbl_client/pages/terms/terms.dart';
import 'package:skribbl_client/utils/navigator_observer.dart';
import 'package:skribbl_client/utils/start_up.dart';
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
    initialRoute: '/gameplay',
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
      GetPage(name: '/gameplay', page: () => const GameplayPage(), binding: GameplayBinding())
    ],
    navigatorObservers: [NavObserver],
  ));
}
