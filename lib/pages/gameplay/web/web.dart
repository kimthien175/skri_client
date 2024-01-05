import 'package:cd_mobile/models/gif_manager.dart';
import 'package:flutter/material.dart';

class Web extends StatelessWidget {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 200,
            width: 200,
            child: FittedBox(child: GifManager.inst.misc('logo').builder.withFixedSize()))
      ],
    );
  }
}
