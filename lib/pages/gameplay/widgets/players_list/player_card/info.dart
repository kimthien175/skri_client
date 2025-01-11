import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/player_card.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'report.dart';

class PlayerInfoDialog extends GameDialog {
  PlayerInfoDialog._internal(this.info)
      : super(title: Text(info.nameForCard), content: const _InfoDialogContent());

  static PlayerInfoDialog factory(Player info) {
    return OverlayController.cache(
        tag: 'card_info_${info.id}', builder: () => PlayerInfoDialog._internal(info));
  }

  final Player info;

  @override
  void onClose() {
    Get.delete<PlayerController>(tag: info.id);
    OverlayController.deleteCache('report ${info.id}');
    super.onClose();
  }
}

class _InfoDialogContent extends StatelessWidget {
  const _InfoDialogContent();
  @override
  Widget build(BuildContext context) {
    var gameInst = Game.inst;
    var infoDialog = OverlayWidget.of<PlayerInfoDialog>(context);
    var info = infoDialog.info;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      info.avatarModel.builder.init().fit(width: 150),
      Column(
          children: (info.id == MePlayer.inst.id)
              ? [
                  Text('invite_your_friends'.tr, style: const TextStyle(
                      fontSize: 19.5,
                      //    color: Colors.white,
                      fontVariations: [FontVariation.weight(500)])),
                  const SizedBox(height: 7.5),
                  HoverButton(
                      onTap: Game.inst.copyLink,
                      height: 34.5,
                      width: 200,
                      child: Text(
                        'click_to_copy_invite'.tr,
                        style: const TextStyle(fontSize: 15),
                      ))
                ]
              : [
                  if (gameInst is PrivateGame && (gameInst.hostPlayerId.value == MePlayer.inst.id))
                    Row(children: [
                      HoverButton(
                          onTap: () {
                            SocketIO.inst.socket.emitWithAck('host_kick', info.id, ack: (data) {
                              if (data['success']) {
                                Game.inst.removePlayer(info.id);
                                Game.inst.addMessage((color) => PlayerGotKicked(
                                    backgroundColor: color,
                                    data: data['data']['\$push']['messages']));
                              }
                            });
                          },
                          child: Text('Kick'.tr)),
                      HoverButton(child: Text('Ban'.tr))
                    ]),
                  // vote kick
                  _VoteKickButton(),
                  // mute
                  StatefulBuilder(
                      builder: (ct, setState) => HoverButton(
                          width: 200,
                          onTap: () {
                            setState(() {
                              info.isMuted = !(info.isMuted ?? false);
                            });
                          },
                          child: Text((info.isMuted == true ? 'Unmute' : 'Mute').tr))),
                  // report
                  info.isReported == true
                      ? HoverButton(
                          width: 200,
                          isDisabled: true,
                          child: Text('you_reported'.tr),
                        )
                      : HoverButton(
                          width: 200,
                          onTap: () {
                            if (infoDialog.isShowing) {
                              infoDialog.hideInstantly();
                              ReportFormDialog.factory(info)
                                  .showInstantly()
                                  .then((value) => info.isReported = value);
                            }
                          },
                          child: Text('Report'.tr))
                ])
    ]);
  }
}

class _VoteKickButton extends StatefulWidget {
  const _VoteKickButton();

  @override
  State<_VoteKickButton> createState() => __VoteKickButtonState();
}

class __VoteKickButtonState extends State<_VoteKickButton> {
  @override
  Widget build(BuildContext context) {
    var info = OverlayWidget.of<PlayerInfoDialog>(context).info;
    return HoverButton(
        width: 200,
        isDisabled: info.isKickVoted == true,
        onTap: () {
          info.isKickVoted = true;
          SocketIO.inst.socket.emitWithAck('vote_kick', info.id, ack: (data) {});
        },
        child: Text('Votekick'.tr));
  }
}
