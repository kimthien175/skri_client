import 'package:cd_mobile/models/gif/avatar/builder.dart';

class Player {
  Player({required String name, required this.avatar, required this.isOwner}) {
    this.name = name.isEmpty ? randomName() : name;
  }
  final AvatarBuilder avatar;
  late final String name;
  final bool isOwner;
  //int index;
  int points = 0;
  static String randomName() {
    return '';
  }
}
