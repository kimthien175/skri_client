import 'package:cd_mobile/widgets/animated_button.dart';
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
              child: Image.asset('assets/gif/thumbsup.gif'),
              onTap: () {
                setState(() {
                  isVisible = false;
                });
  // TODO: SEND LIKE MSG
              },
            ),
            AnimatedButton(
              child: Image.asset('assets/gif/thumbsdown.gif'),
              onTap: () {
                setState(() {
                  isVisible = false;
                });
// TODO: SEND DISLIKE MSG
              },
            )
          ],
        ));
  }
}