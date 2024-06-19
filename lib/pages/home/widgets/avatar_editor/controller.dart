import 'dart:math';

import 'package:cd_mobile/models/game/player.dart';
import 'package:cd_mobile/models/gif/avatar/model.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/avatar_editor.dart';
import 'package:cd_mobile/pages/home/widgets/avatar_editor/jiggle_avatar.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/animated_button/builder.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/opacity.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/scale.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/tooltip.dart';
import 'package:cd_mobile/widgets/animated_button/decorators/tooltip/position.dart';
import 'package:get/get.dart';

class AvatarEditorController extends GetxController {
  AvatarEditorController() {
    var rd = Random();
    color = rd.nextInt(GifManager.inst.colorLength).obs;
    eyes = rd.nextInt(GifManager.inst.eyesLength).obs;
    mouth = rd.nextInt(GifManager.inst.mouthLength).obs;

    MePlayer.init(AvatarModel.init(color.value, eyes.value, mouth.value).builder.init());

    randomizeBtnBuilder = AnimatedButtonBuilder(
        child: GifManager.inst.misc('randomize').builder.init().doFitSize(height: 36, width: 36),
        onTap: randomize,
        decorators: [
          AnimatedButtonScaleDecorator(),
          AnimatedButtonTooltipDecorator(
              tooltip: 'randomize_your_avatar'.tr,
              position: TooltipPositionBottom(),
              scale: () =>
                  Get.width >= Get.height ? 1.0 : PanelStyles.widthOnMobile / PanelStyles.width),
          AnimatedButtonOpacityDecorator(),
        ]);

    Get.put(SwitchButtonController(), tag: onPreviousEyes.hashCode.toString());
    Get.put(SwitchButtonController(), tag: onPreviousMouth.hashCode.toString());
    Get.put(SwitchButtonController(), tag: onPreviousColor.hashCode.toString());
    Get.put(SwitchButtonController(), tag: onNextEyes.hashCode.toString());
    Get.put(SwitchButtonController(), tag: onNextMouth.hashCode.toString());
    Get.put(SwitchButtonController(), tag: onNextColor.hashCode.toString());
  }

  late final RxInt color;
  late final RxInt eyes;
  late final RxInt mouth;

  @override
  void onClose() {
    jiggleEyes.dispose();
    jiggleMouth.dispose();
    randomizeBtnBuilder.controller.dispose();
    super.onClose();
  }

  final JiggleController jiggleEyes = JiggleController();
  final JiggleController jiggleMouth = JiggleController();

  void onPreviousEyes() {
    if (eyes.value == 0) {
      eyes.value = GifManager.inst.eyesLength - 1;
    } else {
      eyes - 1;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes.value);

    jiggleEyes.jiggle();
  }

  void onNextEyes() {
    if (eyes.value == GifManager.inst.eyesLength - 1) {
      eyes.value = 0;
    } else {
      eyes + 1;
    }
    MePlayer.inst.avatar.model.eyes = GifManager.inst.eyes(eyes.value);

    jiggleEyes.jiggle();
  }

  void onPreviousMouth() {
    if (mouth.value == 0) {
      mouth.value = GifManager.inst.mouthLength - 1;
    } else {
      mouth - 1;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth.value);

    jiggleMouth.jiggle();
  }

  void onNextMouth() {
    if (mouth.value == GifManager.inst.mouthLength - 1) {
      mouth.value = 0;
    } else {
      mouth + 1;
    }
    MePlayer.inst.avatar.model.mouth = GifManager.inst.mouth(mouth.value);

    jiggleMouth.jiggle();
  }

  void onPreviousColor() {
    if (color.value == 0) {
      color.value = GifManager.inst.colorLength - 1;
    } else {
      color - 1;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color.value);
  }

  void onNextColor() {
    if (color.value == GifManager.inst.colorLength - 1) {
      color.value = 0;
    } else {
      color + 1;
    }
    MePlayer.inst.avatar.model.color = GifManager.inst.color(color.value);
  }

  late final AnimatedButtonBuilder randomizeBtnBuilder;
  void randomize() {
    var rd = Random();
    color.value = rd.nextInt(GifManager.inst.colorLength);
    eyes.value = rd.nextInt(GifManager.inst.eyesLength);
    mouth.value = rd.nextInt(GifManager.inst.mouthLength);
    MePlayer.inst.avatar.model = AvatarModel.init(color.value, eyes.value, mouth.value);
  }
}
