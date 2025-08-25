library;

export 'private_game.dart';

export 'package:skribbl_client/models/game/message.dart';
export 'package:skribbl_client/models/game/player.dart';
export 'state/state.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/utils.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

import 'package:web/web.dart' as html;

import '../../widgets/widgets.dart';

// TODO: lost connection and try to continue the game again
class Game extends GetxController {
  Game({required this.data}) {
    state = GameState.fromJSON(henceforthStates[currentStateId]).obs;

    var playersByList = <Player>[];
    playersByMap = {};
    (data['players'] as Map).forEach((id, rawPlayer) {
      Player player = id == MePlayer.inst.id ? MePlayer.inst : Player.fromJSON(rawPlayer);

      playersByList.add(player);
      playersByMap[id] = player;
    });
    this.playersByList = playersByList.obs;

    quitPlayers = {};
    (data['quit_players'] as Map?)
        ?.forEach((id, rawPlayer) => quitPlayers[id] = Player.fromJSON(rawPlayer));

    settings = (data['settings'] as Map<String, dynamic>).obs;

    messages = Message.listFromJSON(data['messages']).obs;

    currentRound = (data['current_round'] as int).obs;

    DrawReceiver.inst.load(data['latest_draw_data']);
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game game) => _inst = game;

  final Map<String, dynamic> data;

  String get roomCode => data['code'];
  set roomCode(String value) {
    data['code'] = value;
  }

  Map<String, dynamic> get system => data['system'];
  Map<String, dynamic> get options => data['options'];

  late final RxInt currentRound;

  String get inviteLink => '${html.window.location.host}/?$roomCode';

  copyLink() {
    Clipboard.setData(ClipboardData(text: inviteLink))
        .then((value) => addMessage((color) => LinkCopiedMessage(backgroundColor: color)));
  }

  late final RxList<Player> playersByList;
  late final Map<String, Player> playersByMap;
  void removePlayer(String id) {
    playersByList.removeWhere((player) => player.id == id);
    quitPlayers[id] = playersByMap.remove(id)!;

    // remove PlayerController
    Get.delete<PlayerController>(tag: id);

    // remove info dialog controller
    OverlayController.deleteCache('card_info_$id');

    // remove report dialog controller
    OverlayController.deleteCache('report $id');
  }

  late Map<String, Player> quitPlayers;

  late final RxMap<String, dynamic> settings;

  /// edit on this won't cause emiting to socketio
  late final RxList<Message> messages;

  void addMessage(Message Function(Color color) callback) {
    messages.add(callback(messages.length % 2 == 0 ? Colors.white : const Color(0xffececec)));
  }

  late Rx<GameState> state;
  Map<String, dynamic> get henceforthStates => data['henceforth_states'] as Map<String, dynamic>;

  Map<String, dynamic> get status => data['status'] as Map<String, dynamic>;
  set status(Map<String, dynamic> value) => data['status'] = value;

  String get currentStateId => status['current_state_id'];
  String get nextStateId => status['next_state_id'];
  String get stateCommand => status['command'];
  DateTime get date => DateTime.parse(status['date']);

  static bool get isEmpty => _inst == null;

  void confirmLeave() {
    var dialog = OverlayController.cache(
        tag: 'confirm_leave',
        builder: () => GameDialog(
            title: Text("dialog_title_confirm_leave".tr),
            content: Center(child: Text('dialog_content_confirm_leave'.tr)),
            buttons: const RowRenderObjectWidget(
                children: [GameDialogButton.yes(), GameDialogButton.no()])));

    dialog.show().then((value) {
      if (value) leave();
    });
  }

  static Future<void> leave() async {
    //state.value.clear();
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    MePlayer.inst.score = 0;

    var homeController = Get.find<HomeController>();
    await Get.offAllNamed(
        "/${homeController.isPrivateRoomCodeValid ? '?${homeController.privateRoomCode}' : ''}");
    Game._inst = null;
  }

  /// trigger at GameplayerPage controller onStart, or SocketIO receive new state
  runState() {
    switch (stateCommand) {
      case 'start':
        state.value.onStart(DateTime.now() - date);
        break;
      case 'end':
        state.value.onEnd(DateTime.now() - date).then((duration) {
          // henceforthStates.remove(state.value.id);
          // state.value = GameState.fromJSON(henceforthStates[nextStateId]);
          // state.value.onStart(duration);
        });
        break;
      default:
        break;
    }
  }

  void receiveStatusAndStates(dynamic pkg) {
    henceforthStates.addAll(pkg['henceforth_states']);

    status = pkg['status'];

    if (state.value.id != currentStateId) {
      henceforthStates.remove(state.value.id);
      state.value = GameState.fromJSON(henceforthStates[currentStateId]);
    }

    runState();
  }
}

typedef GameStateInitCallback = GameState Function();
