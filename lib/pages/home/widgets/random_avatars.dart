import 'dart:math';
import 'package:cd_mobile/models/avatar/avatar.dart';
import 'package:cd_mobile/models/gif_manager.dart';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RandomAvatarsController extends GetxController {
  RandomAvatarsController() {
    avatars = [];
    var rd = Random();

    int winnerId = -1;
    // consider the group has winner or not
    if (rd.nextBool()) {
      winnerId = rd.nextInt(8);
    }

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
      var avatar = AvatarWithShadow(
          i, rd.nextInt(GifManager.inst.eyesLength), rd.nextInt(GifManager.inst.mouthLength),
          winner: winnerId == i);

      avatars.add(avatar);
    }
  }

  late final List<Avatar> avatars;
}

class RandomAvatars extends StatelessWidget {
  const RandomAvatars({super.key});

  @override
  Widget build(BuildContext context) {
    var avatars = Get.find<RandomAvatarsController>().avatars;
    return SizedBox(
        height: avatars[0].height, child: Row(mainAxisSize: MainAxisSize.min, children: avatars));
  }
}
