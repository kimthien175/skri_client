import 'package:cd_mobile/models/avatar/controller.dart';
import 'package:cd_mobile/models/avatar/custom_painter.dart';
import 'package:cd_mobile/models/gif/custom_painter.dart';
import 'package:cd_mobile/models/gif/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef GifCustomPainterBuilder = GifCustomPainter Function(int frameIndex, Paint paint);

// ignore: must_be_immutable
class Avatar extends StatelessWidget {
  Avatar(int color, int eyes, int mouth, {super.key, this.winner = false}) {
    var gif = GifManager.inst;
    colorModel = gif.color(color);
    eyesModel = gif.eyes(eyes);
    mouthModel = gif.mouth(mouth);

    Avatar.controller ??= Get.put(AvatarController(colorModel.frames.length, colorModel.frames[0].duration));
  }

  late GifModel colorModel;

  late GifModel eyesModel;

  late GifModel mouthModel;

  bool winner;

  static GifCustomPainterBuilder crownCustomPainter() {
    var crown = GifManager.inst.misc('crown');
    return (int frameIndex, Paint paint) =>
        GifCustomPainter(crown.frames[frameIndex].image, paint, offset: const Offset(-3.5, -10.5));
  }

  static AvatarController? controller;
  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomPaint(
        painter: AvatarCustomPainter(this, Avatar.controller!.currentFrameIndex.value, Paint()),
        child: SizedBox(height: colorModel.height, width: colorModel.width)));
  }
}

// ignore: must_be_immutable
class AvatarWithShadow extends Avatar {
  AvatarWithShadow(super.color, super.eyes, super.mouth,
      {super.key, this.shadowInfo = const ShadowInfo(), super.winner});

  final ShadowInfo shadowInfo;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(clipBehavior: Clip.none, children: [
          Transform.translate(
              offset: Offset(shadowInfo.offsetLeft, shadowInfo.offsetTop),
              child: Opacity(
                  opacity: shadowInfo.opacity,
                  child: CustomPaint(
                      painter: AvatarCustomPainter(
                          this,
                          Avatar.controller!.currentFrameIndex.value,
                          Paint()
                            ..colorFilter =
                                const ColorFilter.mode(Colors.black, BlendMode.srcATop)),
                      child: SizedBox(height: colorModel.height, width: colorModel.width)))),
          CustomPaint(
              painter:
                  AvatarCustomPainter(this, Avatar.controller!.currentFrameIndex.value, Paint()))
        ]));
  }
}
