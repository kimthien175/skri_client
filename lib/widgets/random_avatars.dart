import 'dart:math';
import 'package:cd_mobile/models/avatar.dart';
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
    var firstAvatar = AvatarWithShadow(
      0,
      rd.nextInt(GifManager.inst.eyesLength),
      39,
    );
    // controller = firstAvatar.controller;

    avatars.add(firstAvatar);

    for (var i = 1; i < 8; i++) {
      var avatar = AvatarWithShadow(
        i,
        rd.nextInt(GifManager.inst.eyesLength),
        rd.nextInt(GifManager.inst.mouthLength),
      );

      // if (winnerId == i) {
      //   avatar.withCrown();
      // }

      avatars.add(avatar);
    }
  }

  // late final AvatarController controller;

  late final List<Avatar> avatars;

  @override
  Widget build(BuildContext context) {
    return
        // VisibilityDetector(
        //     key: Key(hashCode.toString()),
        //     onVisibilityChanged: (visibilityInfo) {
        //       if (visibilityInfo.visibleFraction == 0) {
        //         controller.pauseTimer();
        //       } else {
        //         controller.startTimer();
        //       }
        //     },
        //     child: Obx(() =>
        Row(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: avatars)
        //));
        ;
  }
}
