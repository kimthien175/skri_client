library;

export 'jiggle_avatar.dart';

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class JiggleController extends GetxController with GetSingleTickerProviderStateMixin {
  JiggleController() {
    animController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.06),
    ).animate(CurvedAnimation(parent: animController, curve: Curves.decelerate));
  }
  late final AnimationController animController;
  late final Animation<Offset> animation;

  void jiggle() {
    animController.forward(from: 0).then((_) => animController.reverse());
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}

class AvatarEditorController extends GetxController {
  late final JiggleController jiggleEyes;
  late final JiggleController jiggleMouth;

  AvatarEditorController() {
    var model = MePlayer.inst.avatarModel;
    color = model.color.index!.obs;
    eyes = model.eyes.index!.obs;
    mouth = model.mouth.index!.obs;
  }

  late final RxInt color;
  late final RxInt eyes;
  late final RxInt mouth;

  @override
  void onInit() {
    super.onInit();

    jiggleEyes = JiggleController();
    jiggleMouth = JiggleController();
  }

  @override
  void onClose() {
    jiggleEyes.dispose();
    jiggleMouth.dispose();
    super.onClose();
  }

  void onPreviousEyes() {
    var eyesModel = MePlayer.inst.avatarModel.eyes;
    var gifs = GifManager.inst.eyes;

    MePlayer.inst.avatarModel.eyes = (gifs.first == eyesModel)
        ? gifs.last
        : gifs[eyesModel.index! - 1];

    eyes.value = MePlayer.inst.avatarModel.eyes.index!;
    jiggleEyes.jiggle();
  }

  void onNextEyes() {
    var eyesModel = MePlayer.inst.avatarModel.eyes;
    var gifs = GifManager.inst.eyes;

    MePlayer.inst.avatarModel.eyes = gifs.last == eyesModel
        ? gifs.first
        : gifs[eyesModel.index! + 1];

    eyes.value = MePlayer.inst.avatarModel.eyes.index!;
    jiggleEyes.jiggle();
  }

  void onPreviousMouth() {
    var mouthModel = MePlayer.inst.avatarModel.mouth;
    var gifs = GifManager.inst.mouth;

    MePlayer.inst.avatarModel.mouth = gifs.first == mouthModel
        ? gifs.last
        : gifs[mouthModel.index! - 1];

    mouth.value = MePlayer.inst.avatarModel.mouth.index!;
    jiggleMouth.jiggle();
  }

  void onNextMouth() {
    var mouthModel = MePlayer.inst.avatarModel.mouth;
    var gifs = GifManager.inst.mouth;

    MePlayer.inst.avatarModel.mouth = gifs.last == mouthModel
        ? gifs.first
        : gifs[mouthModel.index! + 1];

    mouth.value = MePlayer.inst.avatarModel.mouth.index!;
    jiggleMouth.jiggle();
  }

  void onPreviousColor() {
    var colorModel = MePlayer.inst.avatarModel.color;
    var gifs = GifManager.inst.color;

    MePlayer.inst.avatarModel.color = gifs.first == colorModel
        ? gifs.last
        : gifs[colorModel.index! - 1];

    color.value = MePlayer.inst.avatarModel.color.index!;
  }

  void onNextColor() {
    var colorModel = MePlayer.inst.avatarModel.color;
    var gifs = GifManager.inst.color;

    MePlayer.inst.avatarModel.color = gifs.last == colorModel
        ? gifs.first
        : gifs[colorModel.index! + 1];

    color.value = MePlayer.inst.avatarModel.color.index!;
  }

  void randomize() {
    var rd = Random();
    var gif = GifManager.inst;

    color.value = rd.nextInt(gif.color.length);
    eyes.value = rd.nextInt(gif.eyes.length);
    mouth.value = rd.nextInt(gif.mouth.length);

    var model = MePlayer.inst.avatarModel;

    model.color = gif.color[color.value];
    model.eyes = gif.eyes[eyes.value];
    model.mouth = gif.mouth[mouth.value];
  }
}

class AvatarEditor extends StatelessWidget {
  const AvatarEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AvatarEditorController>();
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            borderRadius: GlobalStyles.borderRadius,
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousEyes),
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousMouth),
                  _SwitchButton('left_arrow', 'chosen_left_arrow', controller.onPreviousColor),
                ],
              ),
              const SizedBox(height: 96, width: 96, child: FittedBox(child: JiggleAvatar())),
              Column(
                children: [
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextEyes),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextMouth),
                  _SwitchButton('right_arrow', 'chosen_right_arrow', controller.onNextColor),
                ],
              ),
            ],
          ),
        ),
        const Positioned(right: 4, top: 14, child: _RandomButton()),
      ],
    );
  }
}

class _SwitchButton extends StatefulWidget {
  const _SwitchButton(this.path, this.onHoverPath, this.callback);

  final String path;
  final String onHoverPath;
  final void Function() callback;

  @override
  State<_SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<_SwitchButton> with SingleTickerProviderStateMixin {
  late final GifBuilder child = GifManager.inst.misc(widget.path).builder.init();
  late final GifBuilder onHoverChild = GifManager.inst.misc(widget.onHoverPath).builder.init();

  late AnimationController animController;
  late final Animation<double> animation = CurvedAnimation(
    parent: animController,
    curve: Curves.linear,
  );

  late Widget visual;

  late final FocusNode focusNode;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    visual = child;

    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.callback();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.addListener(() {
      if (isHovered) return;
      if (focusNode.hasFocus) {
        change(onHoverChild);
      } else {
        change(child);
      }
    });

    if (focusNode.hasFocus) change(onHoverChild);
  }

  @override
  void dispose() {
    animController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void change(Widget newWidget) {
    setState(() {
      visual = Stack(
        children: [
          newWidget,
          FadeTransition(opacity: animation, child: visual),
        ],
      );
    });
    animController.reverse(from: 1).then((_) {
      visual = newWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: SizedBox(
        height: 34,
        width: 34,
        child: FittedBox(
          child: GestureDetector(
            onTap: widget.callback,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) {
                isHovered = true;
                if (focusNode.hasFocus) return;
                change(onHoverChild);
              },
              onExit: (_) {
                isHovered = false;
                if (focusNode.hasFocus) return;
                change(child);
              },
              child: visual,
            ),
          ),
        ),
      ),
    );
  }
}

class _RandomButton extends GetView<AvatarEditorController> {
  const _RandomButton();

  @override
  Widget build(BuildContext context) => AnimatedButton(
    onTap: controller.randomize,
    decorators: const [
      AnimatedButtonScaleDecorator(max: 1.2),
      AnimatedButtonTooltipDecorator(
        tooltip: _RandomButtonToolTipContent(),
        position: GameTooltipPosition.centerBottom(),
      ),
      AnimatedButtonOpacityDecorator(minOpacity: 0.6),
    ],
    child: GifManager.inst.misc('randomize').builder.init(height: 32, width: 32),
  );
}

class _RandomButtonToolTipContent extends StatelessWidget {
  const _RandomButtonToolTipContent();
  @override
  Widget build(BuildContext context) {
    return Text('randomize_your_avatar'.tr);
  }
}
