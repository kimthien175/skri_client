//import 'dart:math';

import 'package:cd_mobile/models/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/widgets.dart';
//import 'package:get/get.dart';

// class AvatarController extends GetxController {
//   AvatarController({int? color, int? eyes, int? mouth, bool crown = false}) {
//     this.crown = crown.obs;

//     if (color == null) {
//       this.color = rdNumber.nextInt(GifManager.inst.colorLength).obs;
//     } else {
//       this.color = color.obs;
//     }

//     if (eyes == null) {
//       this.eyes = rdNumber.nextInt(GifManager.inst.eyesLength).obs;
//     } else {
//       this.eyes = eyes.obs;
//     }

//     if (mouth == null) {
//       this.mouth = rdNumber.nextInt(GifManager.inst.mouthLength).obs;
//     } else {
//       this.mouth = mouth.obs;
//     }

//     crownTopOffset = -crownWidget.height! / 2 + 2; // NOTE: offset for crown, must be the better way rather than hardcode
//   }

//   late RxInt color;
//   ChildGif get colorWidget => GifManager.inst.color(color.value);

//   late RxInt eyes;
//   ChildGif get eyesWidget => GifManager.inst.eyes(eyes.value);

//   late RxInt mouth;
//   ChildGif get mouthWidget => GifManager.inst.mouth(mouth.value);

//   late RxBool crown;
//   Image get crownWidget => GifManager.inst.misc('crown') as Image;
//   late final double crownTopOffset;

//   final rdNumber = Random();
//   random() {
//     color.value = rdNumber.nextInt(GifManager.inst.colorLength);
//     eyes.value = rdNumber.nextInt(GifManager.inst.eyesLength);
//     mouth.value = rdNumber.nextInt(GifManager.inst.mouthLength);
//   }
// }

// // ignore: must_be_immutable
// class Avatar extends StatelessWidget {
//   Avatar({super.key, int? color, int? eyes, int? mouth, bool crown = false, this.beingEdited = false}) {
//     controller = AvatarController(color: color, eyes: eyes, mouth: mouth, crown: crown);
//   }

//   bool beingEdited;
//   late AvatarController controller;

//   int? special;

//   @override
//   Widget build(BuildContext context) {
//     // NOTE: to optimize rendering performance, change this code into CustomPaint instead of using Stack
//     return Obx(() {
//       if (controller.crown.value) {
//         return Container(
//             alignment: Alignment.bottomCenter,
//             height: controller.colorWidget.height - controller.crownTopOffset,
//             width: controller.colorWidget.width,
//             child: Stack(clipBehavior: Clip.none, children: [
//               controller.colorWidget,
//               controller.eyesWidget,
//               controller.mouthWidget,
//               Positioned(top: controller.crownTopOffset, child: controller.crownWidget)
//             ]));
//       } else {
//         return Container(
//             alignment: Alignment.bottomCenter,
//             height: controller.colorWidget.height - (beingEdited ? 0 : controller.crownTopOffset),
//             width: controller.colorWidget.width,
//             child: Stack(clipBehavior: Clip.none, children: [
//               controller.colorWidget,
//               controller.eyesWidget,
//               controller.mouthWidget,
//             ]));
//       }
//     });
//   }
// }

class Avatar extends StatelessWidget {
  Avatar(this.color, this.eyes, this.mouth, {super.key, this.crown = false, this.special, this.beingEdited = false}){
    var gifs = GifManager.inst;
    colorWidget = gifs.color(color);
    eyesWidget = gifs.eyes(eyes);
    mouthWidget = gifs.mouth(mouth);
  }

  final int color;
  late final ChildGif colorWidget;

  final int eyes;
  late final ChildGif eyesWidget;

  final int mouth;
  late final ChildGif mouthWidget;

  final bool crown;
  // NOTE: HARD CODE, NEED SOMEWAY BETTER
  final double crownTopOffset = -GifManager.inst.misc('crown').height / 2 + 2;
  final double crownLeftOffset = -3;

  final bool beingEdited;

  final int? special;

  double get width => colorWidget.width;
  double get height =>colorWidget.height -(beingEdited?0: crownTopOffset);

  @override
  Widget build(BuildContext context) {
    // NOTE: to optimize rendering performance, change this code into CustomPaint instead of using Stack
    if (crown) {
      return Container(
          alignment: Alignment.bottomCenter,
          height: colorWidget.height - crownTopOffset,
          width: colorWidget.width,
          child: Stack(clipBehavior: Clip.none, children: [
            colorWidget,
            eyesWidget,
            mouthWidget,
            Positioned(top: crownTopOffset, left: crownLeftOffset, child: GifManager.inst.misc('crown'))
          ]));
    } else {
      return Container(
          alignment: Alignment.bottomCenter,
          height: colorWidget.height - (beingEdited ? 0 : crownTopOffset),
          width: colorWidget.width,
          child: Stack(clipBehavior: Clip.none, children: [
            colorWidget,
            eyesWidget,
            mouthWidget,
          ]));
    }
  }
}
