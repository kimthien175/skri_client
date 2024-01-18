import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';


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
        alignment: Alignment.center,
        child: const Text('game cnvas')
        );
  }
}
