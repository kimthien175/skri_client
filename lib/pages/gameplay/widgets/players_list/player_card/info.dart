import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import 'report/report.dart';

class PlayerInfoDialog extends GameDialog {
  PlayerInfoDialog._internal(this.info)
      : super(title: Text(info.fullNameForCard), content: const _InfoDialogContent());

  static PlayerInfoDialog factory(Player info) {
    return OverlayController.cache(
        tag: 'card_info_${info.id}', builder: () => PlayerInfoDialog._internal(info));
  }

  final Player info;
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
    var infoDialog = OverlayWidget.of<PlayerInfoDialog>(context)!;
    var info = infoDialog.info;
    const space = SizedBox(width: 6, height: 6);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      info.avatarModel.builder.init().fit(width: GameDialog.minWidth - 240),
      (info.id == MePlayer.inst.id)
          ? const _MePlayerCardInput()
          : Column(children: [
              if (gameInst is PrivateGame && (gameInst.hostPlayerId.value == MePlayer.inst.id)) ...[
                const Row(children: [
                  // KICK
                  _KickButton(),
                  space,
                  // BAN
                  _BanButton()
                ]),
                space
              ],

              // vote kick
              _VoteKickButton(),
              space,
              // mute
              StatefulBuilder(builder: (ct, setState) {
                var mutedPlayerIds = MePlayer.inst.mutedPlayerIds;
                return HoverButton(
                    constraints: inputConstraints,
                    onTap: () {
                      setState(() {
                        if (mutedPlayerIds.contains(info.id)) {
                          mutedPlayerIds.remove(info.id);
                        } else {
                          mutedPlayerIds.add(info.id);
                        }
                      });
                    },
                    child: Text((mutedPlayerIds.contains(info.id) ? 'Unmute' : 'Mute').tr));
              }),
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

class __VoteKickButtonState extends State<_VoteKickButton>
    with APIButtonStateMixin<_VoteKickButton> {
  @override
  Widget build(BuildContext context) {
    var dialog = OverlayWidget.of<PlayerInfoDialog>(context);

    return HoverButton(
        constraints: _InfoDialogContent.inputConstraints,
        isDisabled: dialog!.info.isKickVoted == true || isDisabled,
        onTap: () {
          if (isDisabled) return;
          pauseFncBeforeSending();

          SocketIO.inst.socket.emitWithAck('vote_kick', dialog.info.id, ack: (data) {
            if (data['success']) {
              onSuccess(dialog);
            } else {
              onFailed(dialog);
              GameDialog.error(content: Center(child: Text(data['reason'].toString()))).show();
            }
          });
        },
        child: child);
  }

  @override
  Widget get primaryChild => Text(key: key, 'Votekick'.tr);

  @override
  void onSuccess(PlayerInfoDialog dialog) {
    // check if the dialog is still there, in case the player get kicked and its controller is gone
    var controller = OverlayWidget.of<PlayerInfoDialog>(context);
    if (controller == null) return;

    setState(() {
      if (child == loadingChild) {
        child = primaryChild;
      }

      dialog.info.isKickVoted = true;
    });
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
  const _KickButton();

  @override
  State<_KickButton> createState() => __KickButtonState();
}

class __KickButtonState extends State<_KickButton> with APIButtonStateMixin<_KickButton> {
  @override
  Widget build(BuildContext context) {
    var dialog = OverlayWidget.of<PlayerInfoDialog>(context)!;
    return HoverButton(
        isDisabled: isDisabled,
        constraints: const BoxConstraints(
            minWidth: _InfoDialogContent.minWidth / 2 - 3, minHeight: _InfoDialogContent.minHeight),
        onTap: () {
          if (isDisabled) return;
          pauseFncBeforeSending();

          SocketIO.inst.socket.emitWithAck('host_kick', dialog.info.id, ack: (data) {
            if (data['success']) {
              onSuccess(dialog);
            } else {
              onFailed(dialog);
              GameDialog.error(content: Center(child: Text(data['reason'].toString()))).show();
            }
          });
        },
        child: child);
  }

  @override
  Widget get primaryChild => Text(key: key, 'Kick'.tr);
}

class _BanButton extends StatefulWidget {
  const _BanButton();

  @override
  State<_BanButton> createState() => __BanButtonState();
}

class __BanButtonState extends State<_BanButton> with APIButtonStateMixin<_BanButton> {
  @override
  Widget build(BuildContext context) {
    var dialog = OverlayWidget.of<PlayerInfoDialog>(context);
    return HoverButton(
        isDisabled: isDisabled,
        constraints: const BoxConstraints(
            minWidth: _InfoDialogContent.minWidth / 2 - 3, minHeight: _InfoDialogContent.minHeight),
        child: child,
        onTap: () {
          if (isDisabled) return;
          pauseFncBeforeSending();

          SocketIO.inst.socket.emitWithAck('host_ban', dialog!.info.id, ack: (data) {
            if (data['success']) {
              onSuccess(dialog);
            } else {
              onFailed(dialog);
              GameDialog.error(content: Center(child: Text(data['reasson'].toString()))).show();
            }
          });
        });
  }

  @override
  Widget get primaryChild => Text(key: key, 'Ban'.tr);
}

mixin APIButtonStateMixin<T extends StatefulWidget> on State<T> {
  bool isDisabled = false;

  /// attach this key to child
  final GlobalKey key = GlobalKey();

  LoadingIndicator? loadingChild;

  late Widget child = primaryChild;

  Widget get primaryChild;

  @nonVirtual
  void pauseFncBeforeSending() {
    setState(() {
      if (loadingChild != null) {
        child = loadingChild!;
      }
      isDisabled = true;
    });
  }

  void onSuccess(PlayerInfoDialog dialog) {
    // check the dialog is still there, in case player got kicked and the controller is gone
    var controller = OverlayWidget.of<PlayerInfoDialog>(context);
    if (controller == null || !controller.isShowing) return;

    setState(() {
      if (child == loadingChild) {
        child = primaryChild;
      }
    });
  }

  void onFailed(PlayerInfoDialog dialog) {
    // check the dialog is still there, in case player got kicked and the controller is gone
    var controller = OverlayWidget.of<PlayerInfoDialog>(context);
    if (controller == null || !controller.isShowing) return;

    setState(() {
      if (child == loadingChild) {
        child = primaryChild;
      }
      isDisabled = false;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var size = (key.currentContext?.findRenderObject() as RenderBox?)?.size;
      if (size != null) {
        loadingChild = LoadingIndicator(height: size.height, width: size.width);
      }
    });
  }
}
