import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Message extends StatelessWidget {
  const Message({super.key, required this.backgroundColor});

  final Color backgroundColor;
  final double paddingLeft = 10;

  // relating to server
  static const String newHost = 'new_host';
  static const String playerJoin = 'player_join';
  static const String playerLeave = 'player_leave';
  static const String playerChat = 'player_chat';
  static const String playerWin = 'player_win';
  static const String playerDraw = 'player_draw';

  static const Color darkOrange = Color.fromRGBO(206, 79, 10, 1);
  static const Color orange = Color.fromRGBO(255, 168, 68, 1);
  static const Color green = Color.fromRGBO(86, 206, 39, 1);
  static const Color yellow = Color.fromRGBO(226, 203, 0, 1);
  static const Color blue = Color.fromRGBO(57, 117, 206, 1);
  static const Color guessedRightBackgroundColor = Color(0xffe7ffdf);
}

// TODO: OLIVE???

class NewHostMessage extends Message {
  const NewHostMessage({super.key, required this.playerName, required super.backgroundColor});
  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_room_owner_statement'.trParams({'room_owner': playerName}),
            style: const TextStyle(
                fontSize: 14, fontVariations: [FontVariation.weight(700)], color: Message.orange)));
  }
}

class PlayerChatMessage extends Message {
  final String playerName;
  final String chat;

  const PlayerChatMessage(
      {required this.playerName, required this.chat, super.key, required super.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: '$playerName: ',
                  style: const TextStyle(
                      fontSize: 14,
                      fontVariations: [FontVariation.weight(700)],
                      fontFamily: 'Nunito-var')),
              TextSpan(
                  text: chat,
                  style: const TextStyle(
                      fontSize: 14,
                      fontVariations: [FontVariation.weight(500)],
                      fontFamily: 'Nunito-var')),
            ],
          ),
        ));
  }
}

class PlayerJoinMessage extends Message {
  const PlayerJoinMessage({required this.playerName, super.key, required super.backgroundColor});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text("message_new_player_joined".trParams({'player_name': playerName}),
            style: const TextStyle(
                fontSize: 14, fontVariations: [FontVariation.weight(700)], color: Message.green)));
  }
}

class PlayerLeaveMessage extends Message {
  const PlayerLeaveMessage({required this.playerName, super.key, required super.backgroundColor});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text("message_player_leave".trParams({'player_name': playerName}),
            style: const TextStyle(
                color: Message.darkOrange,
                fontSize: 14,
                fontVariations: [FontVariation.weight(700)])));
  }
}

class Minimum2PlayersToStartMessage extends Message {
  const Minimum2PlayersToStartMessage({super.key, required super.backgroundColor});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text("message_you_need_at_least_2_players".tr,
            style: const TextStyle(
                color: Message.darkOrange,
                fontSize: 14,
                fontVariations: [FontVariation.weight(700)])));
  }
}

class LinkCopiedMessage extends Message {
  const LinkCopiedMessage({super.key, required super.backgroundColor});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text("message_link_copied".tr,
            style: const TextStyle(
                color: Message.yellow, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

class PlayerWinMessage extends Message {
  const PlayerWinMessage(
      {required this.playerName, required this.score, super.key, required super.backgroundColor});
  final String playerName;
  final int score;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text(
            "message_player_won".trParams({'playerName': playerName, 'score': score.toString()}),
            style: const TextStyle(
                color: Message.orange, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

class PlayerDrawMessage extends Message {
  const PlayerDrawMessage({super.key, required this.playerName, required super.backgroundColor});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text("message_player_draw".trParams({"playerName": playerName}),
            style: const TextStyle(
                color: Message.blue, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

class PlayerSpamMessage extends Message {
  const PlayerSpamMessage({super.key, required super.backgroundColor});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_spam'.tr,
            style: const TextStyle(
                color: Message.darkOrange,
                fontSize: 14,
                fontVariations: [FontVariation.weight(700)])));
  }
}

// TODO: APPLY
class PlayerDislikeMessage extends Message {
  const PlayerDislikeMessage({super.key, required super.backgroundColor, required this.playerName});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_dislike'.trParams({"playerName": playerName}),
            style: const TextStyle(
                color: Message.darkOrange,
                fontSize: 14,
                fontVariations: [FontVariation.weight(700)])));
  }
}

// TODO: APPLY
class PlayerLikeMessage extends Message {
  const PlayerLikeMessage({super.key, required super.backgroundColor, required this.playerName});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_like'.trParams({"playerName": playerName}),
            style: const TextStyle(
                color: Message.green, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

// TODO: APPLY
class PlayerGuessedRight extends Message {
  const PlayerGuessedRight({super.key, required this.playerName})
      : super(backgroundColor: Message.guessedRightBackgroundColor);
  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_guessed_right'.trParams({"playerName": playerName}),
            style: const TextStyle(
                color: Message.green, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

// TODO: kick countdown
class PlayerGotKicked extends Message {
  const PlayerGotKicked({super.key, required super.backgroundColor, required this.playerName});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_got_kicked'.trParams({"playerName": playerName}),
            style: const TextStyle(
                color: Message.darkOrange,
                fontSize: 14,
                fontVariations: [FontVariation.weight(700)])));
  }
}

/// TODO: private message,
class PlayerGuessClose extends Message {
  const PlayerGuessClose({super.key, required this.word, required super.backgroundColor});
  final String word;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_player_guess_close'.trParams({"word": word}),
            style: const TextStyle(
                color: Message.yellow, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

// TODO: APPLY
class PlayerVoteKick extends Message {
  const PlayerVoteKick(
      {super.key,
      required this.voterName,
      required this.victimName,
      required this.votedCount,
      required this.notVictimPlayerCount,
      required super.backgroundColor});
  final String voterName;
  final String victimName;
  final int votedCount;
  final int notVictimPlayerCount;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text(
            'message_player_guess_close'.trParams({
              "voterName": voterName,
              "victimName": victimName,
              "votedCount": votedCount.toString(),
              "notVictimPlayerCount": notVictimPlayerCount.toString()
            }),
            style: const TextStyle(
                color: Message.yellow, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}

class WordRevealMessage extends Message {
  const WordRevealMessage({super.key, required this.word, required super.backgroundColor});
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: Text('message_word_reveal'.trParams({"word": word}),
            style: const TextStyle(
                color: Message.green, fontSize: 14, fontVariations: [FontVariation.weight(700)])));
  }
}
