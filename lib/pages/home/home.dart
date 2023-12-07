import 'package:cd_mobile/widgets/landing_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends SuperController{
  var locale = Get.deviceLocale.toString().obs; // update when translations loading finish
  String name = "";
  var isWebLayout = _isWebLayout.obs;

  static bool get _isWebLayout => Get.width >= Get.height;

  @override
  void didChangeMetrics() {
    isWebLayout.value = _isWebLayout;
    super.didChangeMetrics();
  }
  
  @override
  void onDetached() {}
  
  @override
  void onHidden() {}
  
  @override
  void onInactive() {}
  
  @override
  void onPaused() {}
  
  @override
  void onResumed() {}
}

class HomePage extends StatelessWidget {

  final HomeController controller = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
                child: Container(
            decoration:
                const BoxDecoration(image: DecorationImage(scale: 1.2, repeat: ImageRepeat.repeat, image: AssetImage('assets/background.png'))),
            child: Column(
                  children: [

                  LandingLogo(),

                ],)
                )
            ));
  }
}

