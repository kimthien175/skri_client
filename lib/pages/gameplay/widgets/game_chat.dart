import 'package:skribbl_client/models/game/game.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';

import 'players_list/player_card.dart';

// TODO: LAZY LOADING OLD MSG
class GameChatController extends GetxController {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  late final FocusNode focusNode;
  final RxInt counter = 0.obs;

  // anti msg spam
  DateTime? lastMsgDate;
  final Duration safeMsgDuration = const Duration(seconds: 2);

  @override
  void onInit() {
    super.onInit();
    _scrollController = ScrollController();
    _textController = TextEditingController();
    _textController.addListener(
      () => counter.value = _textController.text.length,
    );
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void submit(String text) {
    text = text.trim();
    if (text.isNotEmpty) {
      var now = DateTime.now();

      if (lastMsgDate != null && now.difference(lastMsgDate!) < safeMsgDuration) {
        Game.inst.addMessage((color) => PlayerSpamMessage(backgroundColor: color));
      } else {
        // submit
        Game.inst.addMessage((color) => PlayerChatMessage(
              data: {'player_name': MePlayer.inst.name, 'text': text},
              backgroundColor: color,
            ));
        Get.find<PlayerController>(tag: MePlayer.inst.id).showMessage(text);
        // emit to server
        SocketIO.inst.socket.emit('player_chat', text);
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

      lastMsgDate = now;
    }

    // clear the text
    _textController.clear();
    focusNode.requestFocus();
  }
}

class GameChat extends StatelessWidget {
  const GameChat({super.key});

  static const double width = 300;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: GlobalStyles.borderRadius,
        child: Container(
            width: width,
            height: 600,
            color: Colors.white,
            child: const Column(
              children: [Expanded(child: Center(child: Messages())), GuessInput()],
            )));
  }
}

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameChatController>();
    return Scrollbar(
        controller: controller._scrollController,
        thumbVisibility: true,
        child: Obx(() => ListView(
              controller: controller._scrollController,
              shrinkWrap: true,
              children: Game.inst.messages,
            )));
  }
}

class GuessInput extends StatelessWidget {
  const GuessInput({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameChatController>();
    return Stack(alignment: Alignment.centerRight, children: [
      Container(
          margin: const EdgeInsets.only(left: 2.8, right: 2.8, bottom: 2.8),
          child: TextField(
            // cursorColor: Colors.blue.shade900,
            focusNode: controller.focusNode,
            textInputAction: TextInputAction.send,
            onSubmitted: controller.submit,
            controller: controller._textController,
            maxLength: 100,
            minLines: 1,
            maxLines: 3, // Allow for multiple lines
            //keyboardType: TextInputType.multiline, // Enable multiline input
            style: const TextStyle(
                fontSize: 14,
                fontVariations: [FontVariation.weight(800)]), // Set text and hint text font size
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 22),
              hintText: 'guess_input_placeholder'.tr, // Use the hint text from the image
              hintStyle: const TextStyle(
                  fontSize: 14,
                  fontVariations: [FontVariation.weight(700)]), // Set hint text font size
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueAccent, // Adjust color as desired
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(3)), // Set border radius
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87, // Adjust color as desired
                  width: 1.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(3)), // Set border radius
              ),
            ),
          )),
      Positioned(
          right: 2.8,
          child: Container(
              width: 30,
              alignment: Alignment.center,
              child: Obx(() => Text(
                  controller.counter.value == 0 ? '' : controller.counter.value.toString(),
                  style:
                      const TextStyle(fontSize: 12, fontVariations: [FontVariation.weight(700)])))))
    ]);
  }
}
