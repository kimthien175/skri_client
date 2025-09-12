library;

export 'private_game.dart';

export 'package:skribbl_client/models/game/message.dart';
export 'package:skribbl_client/models/game/player.dart';
export 'state/state.dart';

import 'package:async/async.dart';
import 'package:skribbl_client/models/game/state/draw/game_result.dart';

import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/pages/gameplay/widgets/utils.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';

import 'package:web/web.dart' as html;

import '../../widgets/widgets.dart';

class Game extends GetxController {
  Game({required this.data}) {
    state = GameState.fromJSON(henceforthStates[currentStateId]).obs;

    Map<String, Player> playersByMap = {};
    (data['players'] as Map).forEach((id, rawPlayer) {
      Player player = id == MePlayer.inst.id ? MePlayer.inst : Player.fromJSON(rawPlayer);

      playersByMap[id] = player;
    });
    this.playersByMap = playersByMap.obs;

    settings = (data['settings'] as Map<String, dynamic>).obs;

    messages = Message.listFromJSON(data['messages']).obs;

    currentRound = (data['current_round'] as int).obs;

    DrawReceiver.inst.load(data['latest_draw_data']);
  }
  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game? game) => _inst = game;

  final Map<String, dynamic> data;

  String get roomCode => data['code'];
  set roomCode(String value) {
    data['code'] = value;
  }

  Map<String, dynamic> get system => data['system'];
  Map<String, dynamic> get options => data['options'];

  late final RxInt currentRound;

  String get inviteLink => '${html.window.location.host}/?$roomCode';

  void copyLink() {
    Clipboard.setData(ClipboardData(text: inviteLink))
        .then((value) => addMessage((color) => LinkCopiedMessage(backgroundColor: color)));
  }

  //late final RxList<Player> playersByList;
  late final RxMap<String, Player> playersByMap;
  Map<String, Player> quitPlayers = {};
  void removePlayer(String id) {
    var removed = playersByMap.remove(id);
    if (removed != null) {
      quitPlayers[id] = removed;
      Get.find<PlayersListController>().remove(id);
    }
  }

  void addPlayer(dynamic rawPlayer) {
    var player = Player.fromJSON(rawPlayer);
    playersByMap[player.id] = player;

    Get.find<PlayersListController>().add(player);
  }

  void playerPlusPoint(String id, int point) {
    playersByMap[id]!.score += point;

    Get.find<PlayersListController>().sortFrom(id);
  }

  late final RxMap<String, dynamic> settings;

  /// edit on this won't cause emiting to socketio
  late final RxList<Message> messages;

  Color get secondaryColor => const Color(0xffececec);

  T addMessage<T extends Message>(T Function(Color color) callback, {bool head = false}) {
    late T msg;
    if (head) {
      msg =
          callback(messages.first.backgroundColor == Colors.white ? secondaryColor : Colors.white);
      messages.insert(0, msg);
    } else {
      msg = callback(messages.isEmpty
          ? Colors.white
          : (messages.last.backgroundColor == Colors.white ? secondaryColor : Colors.white));
      messages.add(msg);

      Get.find<GameChatController>().scrollToBottom();
    }

    return msg;
  }

  late Rx<GameState> state;
  Map<String, dynamic> get henceforthStates => data['henceforth_states'] as Map<String, dynamic>;

  Map<String, dynamic> get status => data['status'] as Map<String, dynamic>;
  set status(Map<String, dynamic> value) => data['status'] = value;
  Map<String, dynamic>? get endGameData {
    var bonus = status['bonus'];
    if (bonus == null) return null;
    return bonus['end_game'];
  }

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
    await Future.wait([
      Get.offAllNamed(
              "/${homeController.isPrivateRoomCodeValid ? '?${homeController.privateRoomCode}' : ''}")
          as Future<void>,
      Game.inst.stopState()
    ]);

    await LoadingOverlay.inst.show();

    Game.inst = null;
    await LoadingOverlay.inst.hide();
  }

  void runState() {
    if (stateCommand == 'start') {
      return _start(date);
    }

    // ignore: body_might_complete_normally_catch_error
    _onEndOperation = CancelableOperation.fromFuture(state.value.onEnd(date))
      ..then((date) {
        henceforthStates.remove(state.value.id);
        state.value = GameState.fromJSON(henceforthStates[nextStateId]);
        _start(date);
      }, onError: (e, _) {
        assert(e is TickerCanceled);
      });
  }

  void _start(DateTime date) {
    // ignore: body_might_complete_normally_catch_error
    _onStartOperation = CancelableOperation.fromFuture(state.value.onStart(date).catchError((e) {
      assert(e is TickerCanceled);
    }));
  }

  Future<void> receiveStatusAndStates(dynamic pkg) async {
    await stopState();

    henceforthStates.addAll(pkg['henceforth_states']);

    status = pkg['status'];
    if (Game.inst.endGameData != null) GameResult.init();

    if (state.value.id != currentStateId) {
      henceforthStates.remove(state.value.id);
      state.value = GameState.fromJSON(henceforthStates[currentStateId]);
    }

    runState();
  }

  Future<void> stopState() async {
    // close logic of current state immediately
    state.value.onClose();

    // cancel animation chain
    Get.find<TopWidgetController>().stop();
    await _onStartOperation?.cancel();
    await _onEndOperation?.cancel();
  }

  CancelableOperation? _onStartOperation;
  CancelableOperation<DateTime>? _onEndOperation;

  // TODO: RELOAD GAME
  void reload() {}
}

typedef GameStateInitCallback = GameState Function();
