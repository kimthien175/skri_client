import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'decorator.dart';

// class AnimatedButtonBuilder {
//   AnimatedButtonBuilder({
//     required this.child,
//     this.onTap,
//     AnimatedButtonOpacityDecorator? opacityDecorator,
// //AnimatedButtonScaleDecorator scaleDecorator = AnimatedButtonScaleDecorator(),
//     //  this.tooltipDecorator
//   }) {
//     if (opacityDecorator == null) {
//       this.opacityDecorator = AnimatedButtonOpacityDecorator();
//     }
//   }

//   final Widget child;
//   final void Function()? onTap;

//   late final AnimatedButtonOpacityDecorator? opacityDecorator;
//   // AnimatedButtonScaleDecorator? scaleDecorator = AnimatedButtonScaleDecorator();
//   // Rx<AnimatedButtonTooltipDecorator>? tooltipDecorator;

//   // void Function()? onLongPress;
//   // void Function(LongPressEndDetails)? onLongPressEnd;
// }

// class _AnimatedButton extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _AnimatedButtonState();
// }

// class _AnimatedButtonState extends State<_AnimatedButton>
//     with SingleTickerProviderStateMixin {
//   _AnimatedButtonState() {
//     // decoration
//     widget.opacityDecorator?.decorate(this);

//     // finish onEnter, onExit with re render method
//     var prevOnEnter = onEnter!;
//     onEnter = (e) {
//       prevOnEnter(e);
//       setState(() {});
//     };

//     var prevOnExit = onExit!;
//     onExit = (e) {
//       prevOnExit(e);
//       setState(() {});
//     };
//   }

class AnimatedButtonBuilder {
  AnimatedButtonBuilder(
      {required this.child, this.onTap, this.opacityDecorator}) {
    // with opacity for default
    opacityDecorator ??= AnimatedButtonOpacityDecorator();

    onEnter = (e) {
      // controller.update();
      controller._controller.forward();
      print('super onEnter');
    };

    onExit = (e) {
      //    controller.update();
      controller._controller.reverse();
      print('super onExit');
    };

    // decorating
    opacityDecorator?.decorate(this);
  }

  final AnimatedButtonController controller = AnimatedButtonController();

  void Function()? onTap;

  late void Function(PointerEnterEvent) onEnter;
  late void Function(PointerExitEvent) onExit;

  Widget child;

  AnimatedButtonOpacityDecorator? opacityDecorator;

  Widget build() {
    return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: onEnter,
            onExit: onExit,
            child: child));
  }
}

class AnimatedButtonController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //#region anim specs
  late final _controller = AnimationController(
      duration: duration, vsync: this, lowerBound: 0.9, upperBound: 1);
  static const Duration duration = Duration(milliseconds: 130);
  late final Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  //#endregion

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
