import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';

class Web extends StatelessWidget {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 320,
            child: FittedBox(child: GifManager.inst.misc('logo').builder.withShadow().withFixedSize())),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Container(
        //         width: 200,
        //         decoration: BoxDecoration(
        //             borderRadius: GlobalStyles.borderRadius, color: GlobalStyles.colorPlayerBGBase),
        //         child: Row(
        //           children: [],
        //         ))
        //   ],
        // )
      ],
    );
  }
}
