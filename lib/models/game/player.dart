import 'package:skribbl_client/models/gif/controlled_gif/avatar/builder.dart';
import 'package:skribbl_client/models/gif/controlled_gif/avatar/model.dart';
import 'package:get/get.dart';

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
        avatar: AvatarModel.init(rawAvatar['color'], rawAvatar['eyes'], rawAvatar['mouth'])
            .builder
            .init(),
        isOwner: rawPlayer['isOwner']);
  }
}

class MePlayer extends Player {
  static MePlayer? _inst;
  static MePlayer get inst => _inst!;
  static void init(AvatarBuilder avatarBuilder) =>
      _inst = MePlayer._internal(name: '', avatar: avatarBuilder, id: 'empty id');

  MePlayer._internal({super.name = '', required super.avatar, required super.id});

  @override
  String get nameForCard => '$name (${'you'.tr})';

  static bool get isCreated => _inst != null;

  Map<String, dynamic> toJSON() {
    return {'name': name, 'avatar': avatar.model.toJSON(), 'id': id};
  }
}
