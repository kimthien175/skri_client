import 'dart:convert';

import 'package:cd_mobile/pages/gameplay/widgets/game_settings.dart';
import 'package:cd_mobile/utils/api.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

class GameCanvas extends StatelessWidget {
  const GameCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 600,
        width: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: GlobalStyles.borderRadius,
        ),
        child: FutureBuilder(
            future: API.inst.get('room_settings'),
            builder: (ct, snapshots) {
              if (snapshots.hasData) {
                if (snapshots.data!.statusCode == 200) {
                  GameSettings.fetchedSettings = jsonDecode(snapshots.data!.body);
                  return const GameSettings();
                }
              }
              return Container();
            }));
  }
}
