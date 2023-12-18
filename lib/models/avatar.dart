import 'dart:async';
import 'package:cd_mobile/models/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:visibility_detector/visibility_detector.dart';

class Avatar extends StatelessWidget {
  Avatar({super.key});

  //#region DEAL LATER
  // colorWidget = gifs.color(color);
  // widgets = [colorWidget, gifs.eyes(eyes), gifs.mouth(mouth)];
  // _height = colorWidget.height;
  //   late final ChildGif colorWidget;
  // double get width => colorWidget.width;
  // late double _height;
  // double get height => _height;
  // late final List<Widget> widgets;
  //#region Crown
  // Gif get crown => GifManager.inst.misc('crown');
  // double get crownTopOffset => -crown.height / 2 + 2;
  // static double _crownLeftOffset = -3;
  // Avatar withCrown() {
  //   widgets.add(Positioned(top: 0, left: crownLeftOffset, child: crown));
  //   _height = _height - crownTopOffset;
  //   return this;
  // }
  //#endregion
  //#region Shadow
  // Avatar withShadow({ShadowInfo info = const ShadowInfo()}) {
  //   widgets.insert(0, AvatarShadow(this, info: info));
  //   return this;
  // }
  //#endregion
  //#endregion

  final AvatarController controller = AvatarController(0,0,0);
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(hashCode.toString()),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction == 0) {
            controller.pauseTimer();
          } else {
            controller.startTimer();
          }
        },
        child: Obx(() => CustomPaint(painter: _CustomPainter(controller.color[controller.currentFrameIndex.value].image, controller.colorRect))));
    // SizedBox(
    //     height: _height,
    //     width: colorWidget.width,
    //     child: Stack(
    //         alignment: AlignmentDirectional.bottomStart,
    //         clipBehavior: Clip.none,
    //         children: widgets));
  }
}

class _CustomPainter extends CustomPainter {
  _CustomPainter(this.color, this.colorRect);

  final AvatarController controller = AvatarController(0,0,0);

  static final Paint _paint = Paint();
  final ui.Image color;
  final Rect colorRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(color, colorRect, Rect.fromLTWH(0, 0, colorRect.width, colorRect.height), _paint);

    // canvas.drawImage(
    //     controller.eyesFrames[controller.currentFrameIndex.value].image, Offset.zero, _paint);

    // canvas.drawImage(
    //     controller.mouthFrames[controller.currentFrameIndex.value].image, Offset.zero, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Assume color, eyes, mouth have the same frame time for each frame and frame count as well, for better performance
class AvatarController extends GetxController {
  AvatarController(int color, int eyes, int mouth) {
    var gif = GifManager.inst;
    ChildGifModel colorWidget = gif.color(color);
    this.color = colorWidget.frames;
    colorRect = colorWidget.rect;
    this.eyes = gif.eyes(eyes).frames;
    this.mouth = gif.mouth(mouth).frames;

    frameCount = this.color.length;
    frameTime = this.color[0].duration;
  }

  //late final ChildGif colorWidget;

  // double get width => colorWidget.width;

  // late double _height;
  // double get height => _height;

  late final List<ui.FrameInfo> color;
  late final Rect colorRect;

  late final List<ui.FrameInfo> eyes;
  late final Rect eyesRect;

  late final List<ui.FrameInfo> mouth;
  late final Rect mouthRect;

  late Timer _timer;
  RxInt currentFrameIndex = 0.obs;

  late final int frameCount;
  late final Duration frameTime;

  void switchFrame() {
    currentFrameIndex++;
    if (currentFrameIndex.value == frameCount) {
      currentFrameIndex.value = 0;
    }
    _timer = Timer(frameTime, switchFrame);
  }

  void startTimer() {
    print('start timer');
    _timer = Timer(frameTime, switchFrame);
  }

  void pauseTimer() {
    _timer.cancel();
  }
}

// class AvatarShadow extends StatelessWidget {
//   AvatarShadow(this.avatar, {this.info = const ShadowInfo(), super.key}) {
//     // color, eyes, mouth, crown
//     widgets = avatar.widgets.map((e) => Container()).toList();
//   }

//   late final Avatar avatar;
//   final ShadowInfo info;
//   late final List<Widget> widgets;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(height: avatar.height, width: avatar.width);
//     // Positioned(
//     //           top: info.offsetTop,
//     //           left: info.offsetLeft,
//     //           child: Opacity(
//     //               opacity: info.opacity,
//     //               child: ColorFiltered(
//     //                 colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcATop),
//     //                 child: avatar,
//     //               ),
//     //             ),);
//   }
// }
