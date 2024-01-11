import 'package:cd_mobile/models/gif/avatar/builder.dart';

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
  String get nameForCard => '$name (You)';

  String randomName() {
    return 'RANDOM NAME';
  }

  void processName() {
    name = name.trim();
    if (name.isEmpty) {
      name = randomName();
    }
  }

  static bool get isCreated => _inst != null;
}
