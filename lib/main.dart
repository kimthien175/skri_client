import 'dart:async';

import 'package:skribbl_client/generated/locales.g.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/models/sound.dart';
import 'package:skribbl_client/test.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'pages/pages.dart';

// TODO: reload gameplay page feature
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  String? parameter;
  if (const bool.hasEnvironment('code')) {
    var fromHost = const String.fromEnvironment('code');
    parameter = fromHost.substring(fromHost.indexOf('?'));
  }

  var initialRoute = "/${parameter ?? ''}";

  Future.wait([
    GifManager.init().then((_) async {
      //FOR TESTING, TO SWITCH TO PRODUCTION, UNCOMMENT THE LINE BELOW AND IT IS THE ONLY LINE IN THIS CALLBACK BODY
      MePlayer.random();
      //await PrivateGame.setupTesting();
    }),
    SocketIO.initSocket(),
    Sound.inst.load()
  ]).then((_) {
    var next = Get.arguments['next'];
    if (Get.currentRoute == '/loading' && next != null) {
      Get.offAndToNamed(next);
    }
  });

  usePathUrlStrategy();
  runApp(GetMaterialApp(
      theme: ThemeData(fontFamily: 'Nunito-var'),
      // Locales
      translationsKeys: AppTranslation.translations,
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: initialRoute,
      defaultTransition: Transition.noTransition,
      getPages: [
        GetPage(
            name: '/',
            page: () => const HomePage(),
            binding: HomeBindings(),
            middlewares: [HomeMiddleware()]),
        GetPage(
          name: '/terms',
          page: () => const TermsPage(),
        ),
        GetPage(
          name: '/credits',
          page: () => const CreditsPage(),
        ),
        GetPage(
            name: '/GameplayPage',
            page: () => const GameplayPage(),
            binding: GameplayBinding(),
            middlewares: [GameplayMiddleware()]),
        GetPage(name: '/test', page: () => TestPage()),
        GetPage(
            name: '/loading', page: () => Background(child: LoadingOverlay.inst.widgetBuilder()))
      ]));
}

class HomeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (GifManager.isEmpty || MePlayer.isEmpty) {
      return RouteSettings(name: '/loading', arguments: {'next': route});
    }
    return null;
  }
}

class GameplayMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (GifManager.isEmpty || MePlayer.isEmpty || Game.isEmpty) {
      return RouteSettings(name: '/loading', arguments: {'next': route});
    }
    return null;
  }
}
