import 'package:skribbl_client/widgets/animated_button/animated_button.dart';
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
            AnimatedButton(
                onTap: () {
                  setState(() {
                    isVisible = false;
                  });
                  // TODO: SEND LIKE MSG
                },
                decorators: const [
                  // TODO: ADD SCALE DECORATOR
                ],
                child: Image.asset('assets/gif/thumbsup.gif')),
            AnimatedButton(
                onTap: () {
                  setState(() {
                    isVisible = false;
                  });
                  // TODO: SEND DISLIKE MSG
                },
                decorators: const [
                  // TODO: ADD SCALE DECORATOR
                ],
                child: Image.asset('assets/gif/thumbsdown.gif'))
          ],
        ));
  }
}
