import 'dart:math';

import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/gif_manager.dart';

class Player {
  Player({required this.id, required this.name, required this.avatarModel, this.score = 0});
  final AvatarModel avatarModel;
  String name;
  String get nameForCard => name;
  bool? isMuted;
  bool? isReported;
  bool? isKickVoted;

  // bool get isOwner {
  //   var inst = Game.inst;
  //   assert(inst is PrivateGame);
  //   return (inst as PrivateGame).hostPlayerId.value == id;
  // }

  int score;
  String id;
  static Player fromJSON(rawPlayer) {
    var rawAvatar = rawPlayer['avatar'];
    return Player(
        id: rawPlayer['id'],
        name: rawPlayer['name'],
        avatarModel: AvatarModel(rawAvatar['color'], rawAvatar['eyes'], rawAvatar['mouth']),
        score: rawPlayer['score'] ?? 0);
  }

  static List<Player> listFromJSON(dynamic rawPlayers) {
    List<Player> players = [];

    (rawPlayers as Map).forEach((id, player) {
      if (id == MePlayer.inst.id) {
        players.add(MePlayer.inst);
      } else {
        players.add(Player.fromJSON(player));
      }
    });

    return players;
  }

  Map<String, dynamic> toJSON() {
    return {'name': name, 'avatar': avatarModel.toJSON(), 'id': id};
  }
}

class MePlayer extends Player {
  static MePlayer? _inst;
  static MePlayer get inst => _inst!;
  static set inst(MePlayer value) {
    assert(isEmpty);
    _inst = value;
  }

  static bool get isEmpty => _inst == null;

  static void random() {
    var rd = Random();
    var color = rd.nextInt(GifManager.inst.color.length);
    var eyes = rd.nextInt(GifManager.inst.eyes.length);
    var mouth = rd.nextInt(GifManager.inst.mouth.length);
    _inst = MePlayer(avatarModel: AvatarModel(color, eyes, mouth));
  }

  MePlayer({super.name = '', required super.avatarModel, super.id = ''});

  factory MePlayer.fromJSON(Map<String, dynamic> data) => MePlayer(
      name: data['name'], avatarModel: AvatarModel.fromJSON(data['avatar']), id: data['id']);

  @override
  String get nameForCard => '$name (${'You'.tr})';
}
