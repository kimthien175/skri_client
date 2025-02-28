import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/player_card.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'report/report.dart';

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
  static const double minWidth = 240;
  static const double minHeight = 22;
  static const BoxConstraints inputConstraints =
      BoxConstraints(minWidth: minWidth, minHeight: minHeight);
  @override
  Widget build(BuildContext context) {
    var gameInst = Game.inst;
    var infoDialog = OverlayWidget.of<PlayerInfoDialog>(context);
    var info = infoDialog.info;
    var space = const SizedBox(width: 6, height: 6);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      info.avatarModel.builder.init().fit(width: GameDialog.minWidth - 240),
      (info.id == MePlayer.inst.id)
          ? const _MePlayerCardInput()
          : Column(children: [
              if (gameInst is PrivateGame && (gameInst.hostPlayerId.value == MePlayer.inst.id)) ...[
                Row(children: [
                  // KICK
                  _KickButton(id: info.id),
                  space,
                  // BAN
                  _BanButton(id: info.id)
                ]),
                space
              ],

              // vote kick
              _VoteKickButton(),
              space,
              // mute
              StatefulBuilder(
                  builder: (ct, setState) => HoverButton(
                      constraints: inputConstraints,
                      onTap: () {
                        setState(() {
                          info.isMuted = !(info.isMuted ?? false);
                        });
                      },
                      child: Text((info.isMuted == true ? 'Unmute' : 'Mute').tr))),
              space,
              // report
              info.isReported == true
                  ? HoverButton(
                      constraints: inputConstraints,
                      isDisabled: true,
                      child: Text('you_reported'.tr),
                    )
                  : HoverButton(
                      constraints: inputConstraints,
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
        constraints: _InfoDialogContent.inputConstraints,
        isDisabled: info.isKickVoted == true,
        onTap: () {
          info.isKickVoted = true;
          SocketIO.inst.socket.emitWithAck('vote_kick', info.id, ack: (data) {});
        },
        child: Text('Votekick'.tr));
  }
}

class _MePlayerCardInput extends StatelessWidget {
  const _MePlayerCardInput();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('invite_your_friends'.tr, style: const TextStyle(
          fontSize: 19.5,
          //    color: Colors.white,
          fontVariations: [FontVariation.weight(500)])),
      const SizedBox(height: 7.5),
      HoverButton(
          onTap: Game.inst.copyLink,
          height: 34.5,
          constraints: _InfoDialogContent.inputConstraints,
          child: Text(
            'click_to_copy_invite'.tr,
            style: const TextStyle(fontSize: 15),
          ))
    ]);
  }
}

class _KickButton extends StatefulWidget {
  const _KickButton({required this.id});
  final String id;

  @override
  State<_KickButton> createState() => __KickButtonState();
}

class __KickButtonState extends State<_KickButton> {
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return HoverButton(
        isDisabled: isSending,
        constraints: const BoxConstraints(
            minWidth: _InfoDialogContent.minWidth / 2 - 3, minHeight: _InfoDialogContent.minHeight),
        onTap: () {
          setState(() {
            isSending = true;
          });
          SocketIO.inst.socket.emitWithAck('host_kick', widget.id, ack: (data) {
            setState(() {
              isSending = false;
            });
            if (!data['success']) {
              var dialog = OverlayController.cache(
                  tag: 'host_kick',
                  builder: () =>
                      GameDialog.error(content: Center(child: Text(data['reason'].toString()))));
              if (!dialog.isShowing) dialog.show();
            }
          });
        },
        child: Text('Kick'.tr));
  }
}

class _BanButton extends StatefulWidget {
  const _BanButton({required this.id});
  final String id;

  @override
  State<_BanButton> createState() => __BanButtonState();
}

class __BanButtonState extends State<_BanButton> {
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return HoverButton(
        isDisabled: isSending,
        constraints: const BoxConstraints(
            minWidth: _InfoDialogContent.minWidth / 2 - 3, minHeight: _InfoDialogContent.minHeight),
        child: Text('Ban'.tr),
        onTap: () {
          setState(() {
            isSending = true;
          });
          SocketIO.inst.socket.emitWithAck('host_ban', widget.id, ack: (data) {
            setState(() {
              isSending = false;
            });
            if (!data['success']) {
              var dialog = OverlayController.cache(
                  tag: 'host_ban',
                  builder: () =>
                      GameDialog.error(content: Center(child: Text(data['reasson'].toString()))));
              if (!dialog.isShowing) dialog.show();
            }
          });
        });
  }
}
