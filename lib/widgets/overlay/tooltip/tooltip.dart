library;

export 'position.dart';

// class GameTooltip extends PositionedOverlayController<GameTooltipPosition> {
//   GameTooltip(
//       {required super.childBuilder,
//       super.position = const GameTooltipPosition.centerTop(),
//       required this.controller,
//       required super.anchorKey});

//   @override
//   Widget widgetBuilder() => const _Tooltip();

//   final AnimationController controller;
//   Animation<double> get scaleAnimation => controller.drive(Tween<double>(begin: 0, end: 1));

//   @override
//   Future<bool> show() async {
//     if (await super.show()) {
//       await controller.forward();
//       return true;
//     }
//     return false;
//   }

//   @override
//   Future<bool> hide() async {
//     await controller.reverse();
//     return super.hide();
//   }

//   Future<bool> hideInstancely() => super.hide();
// }

// class _Tooltip extends StatelessWidget {
//   const _Tooltip();
//   @override
//   Widget build(BuildContext context) {
//     var c = OverlayWidget.of<GameTooltip>(context);
//     return c.position.buildAnimation(
//         scaleAnimation: c.scaleAnimation,
//         originalBox: c.originalBox,
//         scale: OverlayController.scale(context),
//         child: DefaultTextStyle(
//           style: const TextStyle(
//               color: Color.fromRGBO(240, 240, 240, 1),
//               fontVariations: [FontVariation.weight(700)],
//               fontSize: 13.0,
//               fontFamily: 'Nunito-var'),
//           child: c.childBuilder(),
//         ));
//   }
// }
