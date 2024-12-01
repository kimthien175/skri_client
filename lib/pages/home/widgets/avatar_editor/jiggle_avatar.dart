import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/home/home.dart';

class JiggleAvatar extends StatelessWidget {
  const JiggleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      GifManager gif = GifManager.inst;
      var controller = Get.find<AvatarEditorController>();
      return Stack(children: [
        gif.color[controller.color.value].builder.init(),
        SlideTransition(
            position: controller.jiggleEyes.animation,
            child: gif.eyes[controller.eyes.value].builder.init()),
        SlideTransition(
          position: controller.jiggleMouth.animation,
          child: gif.mouth[controller.mouth.value].builder.init(),
        )
      ]);
    });
  }
}
