library;

export 'footer/footer.dart';
export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';
export 'widgets/avatar_editor/avatar_editor.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/page_background.dart';

class HomeBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}

// TODO: UNKNOWN, IF CHANGE PRIVATE ROOM AND THE CONTROLLER STILL EXIST THE OLD INSTANCE, THEN USER WOULD JOIN OLD ROOM INSTEAD OF NEW ROOM
class HomeController extends GetxController {
  HomeController() : super() {
    Get.put(RandomAvatarsController());
    Get.put(HowToPlayContentController());
    Get.put(AvatarEditorController());

    // init roomCode
    var keys = Get.parameters.keys.toList();
    _roomCode = keys.isEmpty ? '' : keys[0].toLowerCase();
  }

  late final String _roomCode;

  bool get hasCode => _roomCode != '';
  bool get isPrivateRoomCodeValid => RegExp(r'^[a-z0-9]{4,}$').hasMatch(_roomCode);
  String get privateRoomCode => _roomCode;
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
        child: context.width >= context.height ? const HomeWeb() : const HomeMobile());
  }
}
