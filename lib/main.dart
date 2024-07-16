import 'package:skribbl_client/generated/locales.g.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:skribbl_client/widgets/resources_ensurance.dart';

import 'pages/pages.dart';
import 'utils/utils.dart';

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
    initialRoute: '/',
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
