import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

// TODO: showing effects on child widget
class GameCanvas extends StatelessWidget {
  const GameCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 600,
        width: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: GlobalStyles.borderRadius,
        ),
        child: const GameSettings());
  }
}
