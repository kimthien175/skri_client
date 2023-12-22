import 'package:cd_mobile/models/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/lang_selector.dart';
import 'package:cd_mobile/pages/home/name_input.dart';
import 'package:cd_mobile/pages/home/play_button.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/random_avatars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends SuperController {
  // var locale = Get.deviceLocale.toString().obs; // update when translations loading finish
  // String name = "";
  var isWebLayout = _isWebLayout.obs;

  static bool get _isWebLayout => Get.width >= Get.height;

  @override
  void didChangeMetrics() {
    isWebLayout.value = _isWebLayout;
    super.didChangeMetrics();
  }

  //#region Override to sastisfy SuperController, no need to get attention
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
  //#endregion
}

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    scale: 1.2,
                    repeat: ImageRepeat.repeat,
                    image: AssetImage('assets/background.png'))),
            child: SafeArea(
                child: SizedBox(
                    height: Get.height -
                        MediaQuery.of(context).padding.bottom -
                        MediaQuery.of(context)
                            .padding
                            .top, // based on ChatGPT the SafeArea's size is screen's size subtracting paddings
                    width: Get.width -
                        MediaQuery.of(context).padding.left -
                        MediaQuery.of(context).padding.right,
                    child: Obx(
                        () => controller.isWebLayout.value ? const _Web() : const _Mobile())))));
  }
}

class _Web extends StatelessWidget {
  const _Web();

  @override
  Widget build(BuildContext context) {
    // TODO: WEB VIEW, scrollable when user resize or zoom in
    return Column(
      children: [
        const SizedBox(height: 25, width: double.infinity),
        GifManager.inst.misc('logo').widgetWithShadow(),
        const SizedBox(height: 10),
        RandomAvatars(),
        const SizedBox(height: 40),
        Container(
            padding: PanelStyles.padding,
            decoration: PanelStyles.decoration,
            width: 400,
            child: const Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [NameInput(), LangSelector()]),
                AvatarEditor(),
                PlayButton(),
                CreatePrivateRoomButton(),
              ],
            )),
            const Spacer(),
       const Triangle(),
       const Footer(),
      ],
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    //var logo = GifManager.inst.misc('logo').widgetWithShadow();

    return Column(
      children: [
        SizedBox(height: Get.height * 0.06),
        // SizedBox(
        //     width: min(0.65 * Get.height, 0.95 * Get.width),
        //     child: FittedBox(child: SizedBox(height: logo.model.height, child: logo))),
        const SizedBox(height: 10),
        //RandomAvatars()
      ],
    );
  }
}
