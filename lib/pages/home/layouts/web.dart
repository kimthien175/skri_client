import 'dart:math';

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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class WebController extends GetxController {
  static bool get checkWidth => Get.width >= Web.minWidth;
  static bool get checkHeight => Get.height >= Web.minHeight;

  final RxBool isHeightFit = checkHeight.obs;
  final RxBool isWidthFit = checkWidth.obs;

  void processLayout() {
    var homeController = Get.find<HomeController>();
    var mainSize = homeController.mainContentKey.currentContext?.size;
    var footerSize = homeController.footerKey.currentContext?.size;
    if (mainSize != null && footerSize != null) {
      isHeightFit.value = mainSize.height + footerSize.height <= Get.height;
      isWidthFit.value = checkWidth;
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

  static double minHeight = 1052.0;
  static const double minWidth = 1040.0;

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

    var footer = SizedBox(
        key: homeController.footerKey,
        width: max(context.width, minWidth),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [Triangle(), Footer()],
        ));

    return Obx(() {
      print('____');
      print('width ${controller.isWidthFit.value}');
      print('height ${controller.isHeightFit.value}');
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
                  : ClipRect(
                      child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          controller: controller.verticalScrollController,
                          child: SingleChildScrollView(
                              controller: controller.verticalScrollController,
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
                  :
                  // Scrollbar(
                  //   thumbVisibility: true,
                  //   trackVisibility: true,
                  //     controller: controller.horizontalScrollController,
                  //       child: Scrollbar(
                  //         thumbVisibility: true,
                  //         trackVisibility: true,
                  //         controller: controller.verticalScrollController,
                  //         child: SingleChildScrollView(
                  //             controller: controller.verticalScrollController,
                  //             child: SingleChildScrollView(
                  //                 scrollDirection: Axis.horizontal,
                  //                 controller: controller.horizontalScrollController,
                  //                 child: Column(
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   children: [mainContent, footer],
                  //                 )))),
                  //   )
                  _SingleChildTwoDimensionalScrollView.builder(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [mainContent, footer],
                    ))));
    });
  }
}

class _SingleChildTwoDimensionalScrollView extends TwoDimensionalScrollView {
  static _SingleChildTwoDimensionalScrollView builder({required Widget child}) =>
      _SingleChildTwoDimensionalScrollView._internal(delegate: _TwoDimensionalChildDelegate(child));

  const _SingleChildTwoDimensionalScrollView._internal({
    required super.delegate,
  });
  @override
  Widget buildViewport(
          BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) =>
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
  _TwoDimensionalChildDelegate(Widget child) {
    this.child = Container(key: key, child: child);
  }
  late final Widget child;
  GlobalKey key = GlobalKey();
  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) => child;

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

  @override
  void updateRenderObject(BuildContext context, RenderTwoDimensionalViewport renderObject) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
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
    var child = buildOrObtainChildFor(const ChildVicinity(xIndex: 0, yIndex: 0))!;
    child.layout(constraints.loosen());
    parentDataOf(child).layoutOffset = Offset.zero;
    verticalOffset.applyContentDimensions(
        0, clampDouble(Web.minHeight - viewportDimension.height, 0.0, double.infinity));
    horizontalOffset.applyContentDimensions(
        0, clampDouble(Web.minWidth - viewportDimension.width, 0.0, double.infinity));
  }
}
