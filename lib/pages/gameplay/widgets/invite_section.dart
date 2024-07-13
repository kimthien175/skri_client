import 'package:skribbl_client/models/game/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/animated_button/animated_button.dart';

class InviteSection extends StatelessWidget {
  const InviteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        'invite_your_friends'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
      ),
      const SizedBox(
          height: 33,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 85, child: _InviteLink()),
            Expanded(
              flex: 15,
              child: _CopyButton(),
            )
          ]))
    ]);
  }
}

class _InviteLink extends StatelessWidget {
  const _InviteLink();
  @override
  Widget build(BuildContext context) {
    bool isHover = false;
    return StatefulBuilder(
        builder: (ct, setState) => MouseRegion(
            onEnter: (event) => setState(() => isHover = true),
            onExit: (event) => setState(() => isHover = false),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromRGBO(112, 112, 112, 1)),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3), bottomLeft: Radius.circular(3))),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                    duration: AnimatedButton.duration,
                    child: isHover
                        ? Text(Game.inst.inviteLink,
                            style: const TextStyle(
                                fontSize: 18.2,
                                color: Color.fromRGBO(44, 44, 44, 1),
                                fontWeight: FontWeight.w400))
                        : Text('hover_over_me_to_see_the_invite_link'.tr,
                            style: const TextStyle(
                                color: Color.fromRGBO(44, 141, 231, 1),
                                fontWeight: FontWeight.w800,
                                fontSize: 18.2))))));
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: Game.inst.copyLink,
            child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(44, 141, 231, 1),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(3), bottomRight: Radius.circular(3))),
                alignment: Alignment.center,
                child: Text('Copy'.tr,
                    style: const TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(offset: Offset(2, 2), color: Color.fromRGBO(0, 0, 0, 0.17))
                        ])))));
  }
}
