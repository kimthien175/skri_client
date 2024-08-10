import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/gif_manager.dart';

import 'overlay/loading.dart';

class ResourcesEnsurance extends StatelessWidget {
  const ResourcesEnsurance({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    scale: 1.2,
                    repeat: ImageRepeat.repeat,
                    image: AssetImage('assets/background.png'))),
            child: SafeArea(
                child: Obx(() => ResourcesController.inst.isLoaded.value
                    ? child
                    : LoadingOverlay.inst.builder()))));
  }
}

class ResourcesController extends GetxController {
  ResourcesController._internal() {
    load();
  }

  static final ResourcesController _inst = ResourcesController._internal();
  static ResourcesController get inst => _inst;

  Future<void> load() async {
    await Future.wait([GifManager.inst.loadResources()]);

    for (int i = 0; i < onDone.length; i++) {
      onDone[i]();
    }
    isLoaded.value = true;
    onDone.clear();
  }

  var isLoaded = false.obs;
  List<Function()> onDone = [];
}
