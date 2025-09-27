import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../game.dart';

class PublicLobbyState extends GameState {
  PublicLobbyState({required super.data});

  @override
  void onClose() {
    Game.inst.messages.removeWhere((msg) => msg is _PlayerJoinLobby);
  }

  @override
  Future<DateTime> onStart(DateTime startDate) async {
    Game.inst.addMessage((color) => _PlayerJoinLobby(data: {}, backgroundColor: color));
    return startDate;
  }

  @override
  Future<DateTime> onEnd(DateTime endDate) async {
    onClose();
    if (Game.inst.endGameData != null) return super.onEnd(endDate);

    return endDate;
  }
}

class _PlayerJoinLobby extends Message {
  const _PlayerJoinLobby({required super.data, required super.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: paddingLeft),
        child: const _AnimatedJoiningLobbyMessage());
  }
}

class _AnimatedJoiningLobbyMessage extends StatefulWidget {
  const _AnimatedJoiningLobbyMessage();

  @override
  State<_AnimatedJoiningLobbyMessage> createState() => __LoadingThreeDotsState();
}

class __LoadingThreeDotsState extends State<_AnimatedJoiningLobbyMessage> {
  int dotCount = 1;

  late final Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(milliseconds: 600),
        (_) => setState(() {
              dotCount++;
              if (dotCount > 3) dotCount = 0;
            }));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '';
    for (var i = 0; i < dotCount; i++) {
      dots = '$dots.';
    }
    return RichText(
        text: TextSpan(
            style: DefaultTextStyle.of(context).style.merge(const TextStyle(
                fontSize: 14, fontVariations: [FontVariation.weight(700)], color: Message.green)),
            children: <TextSpan>[
          TextSpan(text: "message_finding_player".tr),
          TextSpan(text: dots)
        ]));
  }
}
