import 'package:flutter/material.dart';
import 'package:skribbl_client/models/gif/controlled_gif/avatar/avatar.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/player_card/report/report.dart';
import 'package:skribbl_client/utils/storage.dart';
import 'package:skribbl_client/widgets/hover_button.dart';
import 'package:skribbl_client/widgets/resources_ensurance.dart';

import 'models/game/player.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResourcesEnsurance(
        child: Center(
            child: Column(children: [
      Text(Storage.data.toString()),
      HoverButton(
          onTap: () {
            Storage.set(['def', 'xyz'], 'hehe');
          },
          child: Text('show'))
    ])));
  }
}
