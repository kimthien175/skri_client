import 'dart:math';

import 'package:skribbl_client/models/gif/controlled_gif/avatar/builder.dart';
import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/gif_manager.dart';
import 'package:skribbl_client/pages/home/home.dart';

class Player {
  Player(
      {required this.id, required this.name, required this.avatar, this.isOwner, this.points = 0});
  final AvatarBuilder avatar;
  String name;
  String get nameForCard => name;

  bool? isOwner;
  int points;
  String id;
  static Player fromJSON(rawPlayer) {
    var rawAvatar = rawPlayer['avatar'];
    return Player(
        id: rawPlayer['id'],
        name: rawPlayer['name'],
        avatar:
            AvatarModel(rawAvatar['color'], rawAvatar['eyes'], rawAvatar['mouth']).builder.init(),
        isOwner: rawPlayer['isOwner']);
  }
}

class MePlayer extends Player {
  static final MePlayer inst = MePlayer._freshInit();

  factory MePlayer._freshInit() {
    var rd = Random();
    var color = rd.nextInt(GifManager.inst.colorLength);
    var eyes = rd.nextInt(GifManager.inst.eyesLength);
    var mouth = rd.nextInt(GifManager.inst.mouthLength);
    Get.lazyPut<AvatarEditorController>(() => AvatarEditorController(color, eyes, mouth));
    return MePlayer._internal(avatar: AvatarModel(color, eyes, mouth).builder.init());
  }

  MePlayer._internal({super.name = '', required super.avatar, super.id = ''});

  @override
  String get nameForCard => '$name (${'you'.tr})';

  Map<String, dynamic> toJSON() {
    return {'name': name, 'avatar': avatar.model.toJSON(), 'id': id};
  }
}
