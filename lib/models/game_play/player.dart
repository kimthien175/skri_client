import 'package:cd_mobile/models/gif/avatar/builder.dart';
import 'package:get/get.dart';
import 'package:word_generator/word_generator.dart';

class Player {
  Player({required this.name, required this.avatar, this.isOwner = false, this.points = 0});
  final AvatarBuilder avatar;
  String name;
  String get nameForCard => name;

  bool isOwner;
  int points;
}

class MePlayer extends Player {
  static MePlayer? _inst;
  static MePlayer get inst => _inst!;
  static void init(AvatarBuilder avatarBuilder) =>
      _inst = MePlayer._internal(name: '', avatar: avatarBuilder);

  MePlayer._internal({super.name = '', required super.avatar});

  @override
  String get nameForCard => '$name (${'you'.tr})';

  String randomName() => WordGenerator().randomNoun();

  void processName() {
    name = name.trim();
    if (name.isEmpty) {
      name = randomName();
    }
  }

  static bool get isCreated => _inst != null;

  Map<String, dynamic> toJSON(){
    return {
      'name':name,
      'avatar':avatar.model.toJSON()
    };
  }
}
