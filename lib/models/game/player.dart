import 'dart:math';

import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/gif_manager.dart';

class Player {
  Player({required this.name, required this.id, required this.score, required this.avatarModel});

  final AvatarModel avatarModel;
  String name;
  String get nameForCard => name;
  bool? isMuted;
  bool? isReported;
  bool? isKickVoted;

  int score;

  String id;
  factory Player.fromJSON(dynamic rawPlayer) {
    var rawAvatar = rawPlayer['avatar'];
    return Player(
        name: rawPlayer['name'],
        id: rawPlayer['id'],
        score: rawPlayer['score'] ?? 0,
        avatarModel: AvatarModel(rawAvatar['color'], rawAvatar['eyes'], rawAvatar['mouth']));
  }

  // static List<Player> listFromJSON(dynamic rawPlayers) {
  //   List<Player> players = [];

  //   (rawPlayers as Map).forEach((id, player) {
  //     if (id == MePlayer.inst.id) {
  //       players.add(MePlayer.inst);
  //     } else {
  //       players.add(Player.fromJSON(player));
  //     }
  //   });

  //   return players;
  // }

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
    _inst = MePlayer(name: '', id: '', score: 0, avatarModel: AvatarModel(color, eyes, mouth));
  }

  MePlayer(
      {required super.name, required super.id, required super.score, required super.avatarModel});

  factory MePlayer.fromJSON(Map<String, dynamic> data) => MePlayer(
      name: data['name'],
      id: data['id'],
      score: data['score'] ?? 0,
      avatarModel: AvatarModel.fromJSON(data['avatar']));

  @override
  String get nameForCard => '$name (${'You'.tr})';
}
