library;

export 'layouts/web.dart';
export 'layouts/mobile.dart';
export 'widgets/widgets.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/gameplay/widgets/draw_view/like_dislike.dart';
import 'package:skribbl_client/pages/pages.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/page_background.dart';

import 'widgets/draw/manager.dart';

class GameplayBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GameplayController());
  }
}

class GameplayController extends GetxController {
  GameplayController() : super() {
    Get.put(PlayersListController());
    Get.put(GameClockController());
    Get.put(GameChatController());

    Get.put(DrawViewController());
    DrawManager.init();

    Get.put(TopWidgetController());
  }

  void loadChildrenControllers() {
//#region test room

//     Map<String, dynamic> roomResult = {
//       "success": true,
//       "data": {
//         "settings": {
//           "_id": "659fcabc0d82dc3d3ecf05a4",
//           "default": {
//             "players": 8,
//             "language": "English",
//             "drawtime": 80,
//             "rounds": 3,
//             "word_mode": "Normal",
//             "word_count": 3,
//             "hints": 2
//           },
//           "options": {
//             "players": {"min": 2, "max": 20},
//             "language": {
//               "list": ["English"]
//             },
//             "drawtime": {
//               "list": [15, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 150, 180, 210, 240]
//             },
//             "rounds": {"min": 2, "max": 10},
//             "word_mode": {
//               "list": ["Normal", "Hidden", "Combination"]
//             },
//             "word_count": {"min": 1, "max": 5},
//             "hints": {"min": 0, "max": 5},
//             "custom_words_rules": {
//               "min_words": 10,
//               "min_char_per_word": 1,
//               "max_char_per_word": 32,
//               "max_char": 20000
//             }
//           }
//         },
//         "ownerName": "suggest",
//         "player_id": "yNari4wJ5k3ZE4eyAAAK",
//         "message": {
//           "type": "new_host",
//           "player_id": "yNari4wJ5k3ZE4eyAAAK",
//           "timestamp": "2024-12-02T04:57:04.913Z",
//           "player_name": "suggest"
//         },
//         "code": "9eah"
//       }
//     };

//     var createdRoom = roomResult['data'];

//     Map<String, dynamic> settings = createdRoom['settings']['default'];

//     var me = MePlayer.inst;

// //#region set up player
//     // set room owner name if empty
//     if (me.name.isEmpty) {
//       me.name = createdRoom['ownerName'];
//     }
//     me.id = createdRoom['player_id'];
//     me.isOwner = true;
// //#endregion

//     Game.inst = PrivateGame.internal(
//         roomCode: createdRoom['code'],
//         settings: settings.obs,
//         currentRound: RxInt(1),
//         rounds: RxInt(settings['rounds']),
//         // ignore: unnecessary_cast
//         playersByList: [me as Player].obs,
//         // ignore: unnecessary_cast
//         state: (WaitForSetupState() as GameState).obs,
//         options: createdRoom['settings']['options']);

//     Game.inst.addMessage((color) =>
//         NewHostMessage(playerName: createdRoom['message']['player_name'], backgroundColor: color));

//     // Get.to(() => const GameplayPage(),
//     //     binding: GameplayBinding(), transition: Transition.noTransition);
//#endregion
  }

  @override
  void onReady() {
    super.onReady();

    Game.inst.runState();
  }
}

// TODO: test changes after replacing deprecated property
class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) => Background(
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            Game.inst.confirmLeave();
          },
          child: const GameplayWeb()));
  //return context.width >= context.height ? const Web() : const Mobile();
}
