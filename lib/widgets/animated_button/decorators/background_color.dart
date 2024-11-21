// import 'package:flutter/material.dart';
// import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

// import '../../../utils/utils.dart';

// class AnimatedButtonBackgroundColorDecorator extends AnimatedButtonDecorator {
//   const AnimatedButtonBackgroundColorDecorator(
//       {this.height,
//       this.width,
//       this.borderRadius = GlobalStyles.borderRadius,
//       this.color = GlobalStyles.colorPanelButton,
//       this.hoverColor = GlobalStyles.colorPanelButtonHover});

//   final double? height;
//   final double? width;
//   final BorderRadius borderRadius;

//   final Color color;
//   final Color hoverColor;
//   @override
//   void decorate(AnimatedButtonState state) {
//     state.child = BackgroundColorTransition(
//         listenable: state.curvedAnimation.drive(ColorTween(begin: color, end: hoverColor)),
//         height: height,
//         width: width,
//         borderRadius: borderRadius,
//         child: state.child);
//   }
// }