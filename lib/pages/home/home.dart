library;

export 'footer/footer.dart';
export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';
export 'widgets/avatar_editor/avatar_editor.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';
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
    if (keys.isEmpty) {
      roomCode = '';
      validity = .empty;
      return;
    }

    roomCode = keys[0].toLowerCase();
    validity = RegExp(r'^[a-z0-9]{4,}$').hasMatch(roomCode) ? .valid : .unvalid;
  }

  late final String roomCode;
  late final RoomCodeValidity validity;
}

enum RoomCodeValidity { empty, valid, unvalid }

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  bool isWebLayout(BuildContext context) {
    if (context.width >= context.height) {
      OverlayController.scale = (_) => 1.0;
      return true;
    }

    OverlayController.scale = (ct) => PanelStyles.widthOnMobile(ct) / PanelStyles.width;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Background(child: isWebLayout(context) ? const HomeWeb() : const HomeMobile());
  }
}
