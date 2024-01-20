import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Message extends StatelessWidget {
  const Message({this.backgroundColor = Colors.white, super.key});
  final Color backgroundColor;
  final double paddingLeft = 10;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class HostingMessage extends Message {
  const HostingMessage({super.key, required this.playerName, super.backgroundColor});
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

class DrawingMessage extends Message {
  final String playerName;

  const DrawingMessage({required this.playerName, super.key, super.backgroundColor});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class GuessMessage extends Message {
  final String playerName;
  final String guess;

  const GuessMessage(
      {required this.playerName, required this.guess, super.key, super.backgroundColor});

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

class CorrectGuessMessage extends Message {
  const CorrectGuessMessage({required this.playerName, super.key, super.backgroundColor});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class SpamWarningMessage extends Message {
  const SpamWarningMessage({super.key, super.backgroundColor});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
