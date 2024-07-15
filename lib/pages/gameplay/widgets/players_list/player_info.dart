import 'package:skribbl_client/models/game/player.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:flutter/material.dart';

class PlayerInfo extends StatelessWidget {
  const PlayerInfo({super.key, required this.info});
  static show(PlayerInfo info) {}
  final Player info;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 380,
        decoration: const BoxDecoration(
            color: PanelStyles.color, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 13.5, left: 13.5, right: 13.5),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text('Name', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700)))),
            Padding(
                padding: const EdgeInsets.only(top: 7.5, left: 15, right: 15, bottom: 15),
                child: Row(
                  children: [
                    info.avatar.fit(width: 150),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Invite your friend!'),
                          HoverButton(
                              color: const Color(0xff2a51d1),
                              hoverColor: const Color(0xff1e44be),
                              borderRadius: BorderRadius.circular(3.0),
                              child: const Text('Click to copy Invite'))
                        ])
                  ],
                ))
          ],
        ));
  }
}
