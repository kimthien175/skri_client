import 'dart:math';

import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/gif_manager.dart';

class Player {
  Player({required this.id, required this.name, required this.avatarModel, this.points = 0});
  final AvatarModel avatarModel;
  String name;
  String get nameForCard => name;
  bool? isMuted;
  bool? isReported;

  // bool get isOwner {
  //   var inst = Game.inst;
  //   assert(inst is PrivateGame);
  //   return (inst as PrivateGame).hostPlayerId.value == id;
  // }

  int points;
  String id;
  static Player fromJSON(rawPlayer) {
    var rawAvatar = rawPlayer['avatar'];
    return Player(
        id: rawPlayer['id'],
        name: rawPlayer['name'],
        avatarModel: AvatarModel(rawAvatar['color'], rawAvatar['eyes'], rawAvatar['mouth']));
  }

  static List<Player> listFromJSON(List<dynamic> rawPlayers) {
    List<Player> players = [];
    for (dynamic rawPlayer in rawPlayers) {
      if (rawPlayer['id'] == MePlayer.inst.id) {
        players.add(MePlayer.inst);
      } else {
        players.add(Player.fromJSON(rawPlayer));
      }
    }

    return players;
  }

  Map<String, dynamic> toJSON() {
    return {'name': name, 'avatar': avatarModel.toJSON(), 'id': id};
  }
}

class MePlayer extends Player {
  static final MePlayer inst = MePlayer._random();

  factory MePlayer._random() {
    var rd = Random();
    var color = rd.nextInt(GifManager.inst.color.length);
    var eyes = rd.nextInt(GifManager.inst.eyes.length);
    var mouth = rd.nextInt(GifManager.inst.mouth.length);

    return MePlayer._internal(avatarModel: AvatarModel(color, eyes, mouth));
  }

  MePlayer._internal({super.name = '', required super.avatarModel, super.id = ''});

  @override
  String get nameForCard => '$name (${'You'.tr})';
}
