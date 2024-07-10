import 'package:skribbl_client/widgets/animated_button/builder.dart';
import 'package:flutter/material.dart';

class LikeAndDislikeButtons extends StatefulWidget {
  const LikeAndDislikeButtons({super.key});

  @override
  State<LikeAndDislikeButtons> createState() => _LikeAndDislikeButtonsState();
}

class _LikeAndDislikeButtonsState extends State<LikeAndDislikeButtons> {
  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: isVisible,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedButtonBuilder(
                child: Image.asset('assets/gif/thumbsup.gif'),
                onTap: () {
                  setState(() {
                    isVisible = false;
                  });
                  // TODO: SEND LIKE MSG
                },
                decorators: [
                  // TODO: ADD SCALE DECORATOR
                ]).build(),
            AnimatedButtonBuilder(
                child: Image.asset('assets/gif/thumbsdown.gif'),
                onTap: () {
                  setState(() {
                    isVisible = false;
                  });
// TODO: SEND DISLIKE MSG
                },
                decorators: [
                  // TODO: ADD SCALE DECORATOR
                ]).build()
          ],
        ));
  }
}
