import 'package:cd_mobile/generated/locales.g.dart';
import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/loading.dart';
import 'package:cd_mobile/pages/terms/terms.dart';
import 'package:cd_mobile/utils/start_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startUp();
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
        GetPage(name: '/loading', page: () => const Loading()),
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/terms', page: ()=>const TermsPage())
      ],
      // home: const Scaffold(body: Center(child: Text('English')),)
    ));
}