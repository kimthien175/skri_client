library;

export 'private_game.dart';
export 'public_game.dart';
export 'message.dart';
export 'player.dart';
export 'state/state.dart';

import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as html;

import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

abstract class Game extends GetxController {
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

  void reload(Map<String, dynamic> result) async {
    if (!result['success']) return leave();

    await LoadingOverlay.inst.show();

    final room = result['room'];

    data = room;

    if (state.value.id != currentStateId) {
      state.value = GameState.fromJSON(henceforthStates[currentStateId]);
    }

    Map<String, Player> playersByMap = {};
    (data['players'] as Map).forEach((id, rawPlayer) {
      Player player = id == MePlayer.inst.id ? MePlayer.inst : Player.fromJSON(rawPlayer);

      playersByMap[id] = player;
    });
    this.playersByMap.value = playersByMap;
    Get.find<PlayersListController>().reload();

    settings.value = data['settings'];

    messages.value = Message.listFromJSON(data['messages']);

    currentRound.value = data['current_round'];

    DrawReceiver.inst.load(data['latest_draw_data']);

    runState();
    await LoadingOverlay.inst.hide();
  }

  static Game? _inst;
  static Game get inst => _inst!;
  static set inst(Game? game) => _inst = game;

  Map<String, dynamic> data;

  String get roomCode => data['code'];
  set roomCode(String value) {
    data['code'] = value;
  }

  Map<String, dynamic> get system => data['system'];
  Map<String, dynamic> get options => data['options'];

  late final RxInt currentRound;

  String get inviteLink => '${html.window.location.host}/?$roomCode';

  void copyLink() {
    Clipboard.setData(
      ClipboardData(text: inviteLink),
    ).then((value) => addMessage((color) => LinkCopiedMessage(backgroundColor: color)));
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
    // plus point only on draw state
    final drawState = Game.inst.state.value;
    if (drawState is! DrawStateMixin) throw Exception('wrong state');

    playersByMap[id]!.score += point;
    drawState.addScore(id, point);

    final listController = Get.find<PlayersListController>();
    listController.sortFrom(id);
    listController.list.refresh();
  }

  late final RxMap<String, dynamic> settings;

  /// edit on this won't cause emiting to socketio
  late final RxList<Message> messages;

  Color get secondaryColor => const Color(0xffececec);

  T addMessage<T extends Message>(T Function(Color color) callback, {bool head = false}) {
    late T msg;
    if (head) {
      msg = callback(
        messages.first.backgroundColor == Colors.white ? secondaryColor : Colors.white,
      );
      messages.insert(0, msg);
    } else {
      msg = callback(
        messages.isEmpty
            ? Colors.white
            : (messages.last.backgroundColor == Colors.white ? secondaryColor : Colors.white),
      );
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
    OverlayController.put(
      tag: 'confirm_leave',
      permanent: true,
      builder: () => GameDialog(
        title: Text("dialog_title_confirm_leave".tr),
        content: Text('dialog_content_confirm_leave'.tr),
        buttons: const RowRenderObjectWidget(children: [.yes(), .no(autoFocus: true)]),
      ),
    ).show().then((value) {
      if (value) leave();
    });
  }

  static Future<void> leave() async {
    Sound.inst.play(Sound.inst.leave);
    SocketIO.inst.socket.disconnect();

    // reset meplayer as well
    MePlayer.inst.score = 0;

    await Future.wait([LoadingOverlay.inst.show(), Game.inst.stopState()]);

    if (inst is PrivateGame && inst.playersByMap.length == 1) {
      // in private game, player as the lonly one in the room,
      // the room will be deleted, so the room code is useless
      Get.offAllNamed("/");
    } else {
      // get back to home page normally
      Get.until((route) => Get.currentRoute == '/');
    }

    await LoadingOverlay.inst.hide();
  }

  void runState() {
    if (stateCommand == 'start') {
      return _start(date);
    }

    // ignore: body_might_complete_normally_catch_error
    _onEndOperation = CancelableOperation.fromFuture(state.value.onEnd(date))
      ..then(
        (date) {
          henceforthStates.remove(state.value.id);
          state.value = GameState.fromJSON(henceforthStates[nextStateId]);
          _start(date);
        },
        onError: (e, _) {
          print(e);
          //assert(e is TickerCanceled);
        },
      );
  }

  void _start(DateTime date) {
    // ignore: body_might_complete_normally_catch_error
    _onStartOperation = CancelableOperation.fromFuture(
      state.value.onStart(date).catchError((e) {
        print(e);
        //assert(e is TickerCanceled);
        return DateTime.now();
      }),
    );
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

  static Future<void> requestReload() async {
    print('something is wrong, reload');
    await LoadingOverlay.inst.show();
    SocketIO.inst.socket.emitWithAck('reload', null, ack: Game.inst.reload);
  }

  static Map<String, dynamic> get requestRoomPackage => {
    'player': MePlayer.inst.toJSON(),
    'lang': Get.locale!.toString(),
  };

  /// use for join and host starting connecting to server
  /// disconnect immediately and hide loading overlay, show dialog notifying error
  static void connect(
    String event,
    Map<String, dynamic> requestPackage,
    Game Function({required Map<String, dynamic> room}) loader,
  ) {
    LoadingOverlay.inst.show();

    var socket = SocketIO.inst.socket;

    socket.once('connect_error', (data) {
      SocketIO.inst.socket.disconnect();

      OverlayController.put(
        tag: 'connect_error_dialog',
        builder: () => GameDialog.error(
          onQuit: (hide) async {
            await hide();

            if (Get.currentRoute != '/') {
              Game.leave();
            }
            return true;
          },
          content: Builder(builder: (_) => Text('dialog_content_no_server_connection'.tr)),
        ),
      ).show();

      LoadingOverlay.inst.hide();
    });

    socket.once(
      'connect',
      (_) => SocketIO.inst.socket.emitWithAck(
        event,
        requestPackage,
        ack: (data) => Game._load(data, loader),
      ),
    );

    socket.connect();
  }

  static void _load(
    Map<String, dynamic> data,
    Game Function({required Map<String, dynamic> room}) loader,
  ) {
    if (data['success']) {
      var me = MePlayer.inst;

      //#region set up player
      // set room owner name if empty
      if (me.name.isEmpty) {
        me.name = data['player']['name'];
      }
      me.id = data['player']['id'];
      //#endregion

      Game.inst = loader(room: data['room']);

      Get.to(() => const GameplayPage(), transition: Transition.noTransition);

      // save metadata to local storage
      Storage.set(['system'], Game.inst.data['system']);
    } else {
      SocketIO.inst.socket.disconnect();

      var reason = data['reason'];
      if (reason is Map) {
        var encoder = JsonEncoder.withIndent('  ');
        reason = encoder.convert(reason);
      }
      GameDialog.error(content: Text(reason.toString())).show();
    }

    LoadingOverlay.inst.hide();
  }
}

typedef GameStateInitCallback = GameState Function();
