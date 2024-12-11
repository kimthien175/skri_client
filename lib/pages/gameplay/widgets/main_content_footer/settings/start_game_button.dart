import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'dart:ui' as ui;

class StartGameButton extends StatelessWidget {
  const StartGameButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          flex: 7,
          child: HoverButton(
              onTap: () {},
              color: const Color(0xff53e237),
              hoverColor: const Color(0xff38c41c),
              child: Text('start'.tr,
                  style: const TextStyle(
                    fontSize: 25,
                  )))),
      const SizedBox(width: 5),
      Expanded(
          flex: 3,
          child: HoverButton(
              color: const Color(0xff2c8de7),
              hoverColor: const Color(0xff1671c5),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const _LinkIcon(),
                const SizedBox(width: 5),
                Text('invite'.tr, style: const TextStyle(fontSize: 25))
              ])))
    ]);
  }
}

class _LinkIcon extends StatelessWidget {
  const _LinkIcon();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
            offset: const Offset(3, 3),
            child: SvgPicture.asset('assets/link.svg',
                height: 30,
                colorFilter: const ui.ColorFilter.mode(Color(0x40000000), ui.BlendMode.srcIn))),
        SvgPicture.asset('assets/link.svg', height: 30)
      ],
    );
  }
}
