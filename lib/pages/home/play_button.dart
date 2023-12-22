import 'package:cd_mobile/models/shadow_info.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

class PlayButton extends StatelessWidget {
  PlayButton({super.key}) {
    var info = const ShadowInfo();
    shadow = Shadow(
        color: Colors.black.withOpacity(info.opacity),
        offset: Offset(info.offsetLeft, info.offsetTop));
  }

  late final Shadow shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 54,
        width: double.infinity,
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(Color(0xff53e237)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: GlobalStyles.borderRadius,
                ))),
            onPressed: () => {},
            child: Text('Play!',
                style: TextStyle(
                    fontSize: 32,
                    color: PanelStyles.textColor,
                    fontWeight: FontWeight.w800,
                    shadows: const [Shadow(color: Color(0x2b000000), offset: Offset(2, 2))]))));
  }
}
