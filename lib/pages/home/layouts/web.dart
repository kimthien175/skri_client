import 'package:cd_mobile/pages/home/home.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/footer/footer.dart';
import 'package:cd_mobile/pages/home/footer/triangle.dart';
import 'package:cd_mobile/pages/home/widgets/create_private_room_button.dart';
import 'package:cd_mobile/pages/home/widgets/lang_selector.dart';
import 'package:cd_mobile/pages/home/widgets/name_input.dart';
import 'package:cd_mobile/pages/home/widgets/play_button.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:cd_mobile/pages/home/widgets/random_avatars.dart';
import 'package:cd_mobile/widgets/measure_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class WebController extends GetxController {
  final RxBool isHeightFit = false.obs;
  final RxBool isWidthFit = false.obs;
  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainSize = homeController.mainContentKey.currentContext?.size;
    var footerSize = homeController.footerKey.currentContext?.size;
    if (mainSize != null && footerSize != null) {
      isHeightFit.value = mainSize.height + footerSize.height <= Get.height;
      isWidthFit.value = Footer.webWidth <= Get.width;
    } else {
      isHeightFit.value = false;
      isWidthFit.value = false;
    }
  }

  final horizontalScrollController = ScrollController();
  final verticalScrollController = ScrollController();

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}

class Web extends GetView<WebController> {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WebController());
    var homeController = Get.find<HomeController>();
    var mainContent =
        Column(key: homeController.mainContentKey, mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 25),
      const Logo(Logo.clearUrl),
      const SizedBox(height: 10),
      const RandomAvatars(),
      const SizedBox(height: 40),
      Container(
          padding: PanelStyles.padding,
          decoration: PanelStyles.webDecoration,
          width: PanelStyles.width,
          child: const Column(
            children: [
              Row(children: [NameInput(), LangSelector()]),
              AvatarEditor(),
              PlayButton(),
              SizedBox(height: 10),
              CreatePrivateRoomButton(),
            ],
          )),
      const SizedBox(height: 20)
    ]);

    var footer = Column(
      key: homeController.footerKey,
      mainAxisSize: MainAxisSize.min,
      children: const [Triangle(), Footer()],
    );

    return Obx(() {
      // print('____');
      // print('width ${controller.isWidthFit.value}');
      // print('height ${controller.isHeightFit.value}');
      return MeasureSize(
        onChange: controller.processLayout,
        child: controller.isWidthFit.value
            ? (controller.isHeightFit.value
                ? ClipRect(
                    child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [Positioned(top: 0, child: mainContent), footer],
                  ))
                : Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    controller: controller.verticalScrollController,
                    child: SingleChildScrollView(
                        controller: controller.verticalScrollController,
                        child: ClipRect(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [mainContent, footer],
                        )))))
            : (controller.isHeightFit.value
                ? Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    controller: controller.horizontalScrollController,
                    child: SingleChildScrollView(
                        controller: controller.horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [Positioned(top: 0, child: mainContent), footer],
                        )))
                : _SingleChildTwoDimensionalScrollView.builder(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [mainContent, footer],
                  ))
            // Scrollbar(
            //     thumbVisibility: true,
            //     trackVisibility: true,
            //     controller: controller.verticalScrollController,
            //     child: Scrollbar(
            //         thumbVisibility: true,
            //         trackVisibility: true,
            //         controller: controller.horizontalScrollController,
            //         child: SingleChildScrollView(
            //             controller: controller.horizontalScrollController,
            //             scrollDirection: Axis.horizontal,
            //             child: SingleChildScrollView(
            //                 controller: controller.verticalScrollController,
            //                 child: Column(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [mainContent, footer],
            //                 )))))
            ),
      );
    });
  }
}

class _SingleChildTwoDimensionalScrollView extends TwoDimensionalScrollView {
  static _SingleChildTwoDimensionalScrollView builder({required Widget child}) {
    return _SingleChildTwoDimensionalScrollView._internal(
        delegate: _TwoDimensionalChildDelegate(child), child: child);
  }

  const _SingleChildTwoDimensionalScrollView._internal({
    required this.child,
    required super.delegate,
  });
  final Widget child;
  @override
  Widget buildViewport(
          BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) =>
      // ClipRect(
      //     child: Transform.translate(
      //         offset: Offset(-horizontalOffset.pixels, -verticalOffset.pixels)));
      _TwoDimensionalViewport(
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalDetails.direction,
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalDetails.direction,
        delegate: delegate,
        mainAxis: mainAxis,
      );
}

class _TwoDimensionalChildDelegate extends TwoDimensionalChildDelegate {
  _TwoDimensionalChildDelegate(this.child);
  Widget child;
  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) => null;

  @override
  bool shouldRebuild(covariant _TwoDimensionalChildDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _TwoDimensionalViewport extends TwoDimensionalViewport {
  const _TwoDimensionalViewport(
      {required super.verticalOffset,
      required super.verticalAxisDirection,
      required super.horizontalOffset,
      required super.horizontalAxisDirection,
      required super.delegate,
      required super.mainAxis});

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) =>
      _RenderTwoDimensionalViewport(
          horizontalOffset: horizontalOffset,
          horizontalAxisDirection: horizontalAxisDirection,
          verticalOffset: verticalOffset,
          verticalAxisDirection: verticalAxisDirection,
          delegate: delegate,
          mainAxis: mainAxis,
          childManager: context as TwoDimensionalChildManager);
}

class _RenderTwoDimensionalViewport extends RenderTwoDimensionalViewport {
  _RenderTwoDimensionalViewport(
      {required super.horizontalOffset,
      required super.horizontalAxisDirection,
      required super.verticalOffset,
      required super.verticalAxisDirection,
      required super.delegate,
      required super.mainAxis,
      required super.childManager});

  @override
  void layoutChildSequence() {
    // TODO: implement layoutChildSequence
  }
}
