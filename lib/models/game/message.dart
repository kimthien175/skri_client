import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.backgroundColor});

  final Color backgroundColor;
  final double paddingLeft = 10;

  static const String newHost = 'new_host';
  static const String playerJoin = 'player_join';
  static const String playerLeave = 'player_leave';
  static const String playerGuess = 'player_guess';
  static const String min2Players = 'min_2_players';
  //static const String drawing = 'drawing';

  //static const String correctGuess = 'correct_guess';

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
// TODO: COLOR LIKE PLAYER LEAVE: DISLIKE DRAWING, GETTING KICKED BY THE HOST, SPAWN,
// TODO: COLOR LIKE PLAYER JOIN: LIKE DRAWING, GUESS CORRECTLY, REVEAL WORD
// TODO: YELLOW COLOR: GUESS CLOSE, VOTE KICK
// TODO: BLUE COLOR: PLAYER IS BEGINNING TO DRAW
// TODO: COLOR LIKE NEWHOSTMSG: notify who won

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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(255, 168, 68, 1))));
  }
}

// class DrawingMessage extends Message {
//   final String playerName;

//   const DrawingMessage({required this.playerName, super.key, super.backgroundColor});
//   @override
//   Widget build(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

class PlayerGuessMessage extends Message {
  final String playerName;
  final String guess;

  const PlayerGuessMessage(
      {required this.playerName, required this.guess, super.key, required super.backgroundColor});

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
                      fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
              TextSpan(
                  text: guess,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
            ],
          ),
        ));
  }
}

// class CorrectGuessMessage extends Message {
//   const CorrectGuessMessage({required this.playerName, super.key, super.backgroundColor});
//   final String playerName;
//   @override
//   Widget build(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

// TODO: SPAM DETECT
// class SpamWarningMessage extends Message {
//   const SpamWarningMessage({super.key, super.backgroundColor});

//   @override
//   Widget build(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

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
                fontSize: 14, fontWeight: FontWeight.w700, color: Color.fromRGBO(86, 206, 39, 1))));
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
                color: Color.fromRGBO(206, 79, 10, 1), fontSize: 14, fontWeight: FontWeight.w700)));
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
                color: Color.fromRGBO(206, 79, 10, 1), fontSize: 14, fontWeight: FontWeight.w700)));
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
                color: Color.fromRGBO(226, 203, 0, 1), fontSize: 14, fontWeight: FontWeight.w700)));
  }
}
