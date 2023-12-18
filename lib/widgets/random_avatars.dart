import 'dart:math';

import 'package:cd_mobile/models/avatar.dart';
import 'package:cd_mobile/models/gif.dart';
import 'package:cd_mobile/models/gif_manager.dart';

import 'package:flutter/widgets.dart';

class RandomAvatars extends StatelessWidget {
  RandomAvatars({super.key}) {
    avatars = [];
    var rd = Random();

    //int winnerId = -1;
    // consider the group has winner or not
    // if (rd.nextBool()) {
    //   winnerId = rd.nextInt(8);
    // }

    // TODO: special avatar for random avatars

    // int specialPlayerId = -1;
    // int specialIndex = -1;
    // // consider the group has a player with special item or not
    // if (rd.nextBool()) {
    //   specialPlayerId = rd.nextInt(8);
    //   specialIndex = rd.nextInt(GifManager.inst.specialLength);
    // }

    //first 8 avatars base on color
    for (var i = 0; i < 8; i++) {
      var eyes = rd.nextInt(GifManager.inst.eyesLength);
      var mouth = rd.nextInt(GifManager.inst.mouthLength);
      var avatar = GifManager.inst.color(i).widget();

      //avatar.withShadow();

      // if (winnerId == i) {
      //   avatar.withCrown();
      // }

      avatars.add(avatar);
    }

  }

  late final List<ChildGif> avatars;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: avatars);
  }
}
