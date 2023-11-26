import 'dart:math';

import 'package:cd_mobile/models/avatar.dart';
import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class LandingLogo extends StatelessWidget {
  LandingLogo({super.key}) {
    var rd = Random();

    int winnerId = -1;
    // consider the group has winner or not
    if (rd.nextBool()) {
      winnerId = rd.nextInt(8);
    }

    int specialPlayerId = -1;
    int specialIndex = -1;
    // consider the group has a player with special item or not
    if (rd.nextBool()) {
      specialPlayerId = rd.nextInt(8);
      specialIndex = rd.nextInt(GifManager.inst.specialLength);
    }

    // first 8 avatars base on color
    for (var i = 0; i < 8; i++) {
      var eyes = rd.nextInt(GifManager.inst.eyesLength);
      var mouth = rd.nextInt(GifManager.inst.mouthLength);
      avatars.add(Avatar(i, eyes, mouth, crown: winnerId == i, special: (specialPlayerId == i) ? specialIndex : null));
    }
  }

  late List<Avatar> avatars = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => 
          FittedBox( fit: BoxFit.scaleDown,
            child: Column(mainAxisSize: MainAxisSize.min, 
              children: [
                FittedBox(fit: BoxFit.scaleDown,
                  child: GifManager.inst.misc('logo')),
                FittedBox(fit: BoxFit.scaleDown,
                  child:Row(mainAxisSize: MainAxisSize.min, children: avatars))
            ])));
  }
}
