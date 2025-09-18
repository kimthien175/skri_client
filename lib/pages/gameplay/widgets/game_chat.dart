import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/models/models.dart';

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
    _scrollController.addListener(() {
      if ( // check scrolling touch the top the continue
          _scrollController.position.pixels != 0 ||
              // if the msg is first msg of game data then skip
              Game.inst.messages.first.data['first'] == true ||
              // if the loading progress is running then skip
              Game.inst.messages.first is DummyLoadingIndicator) {
        return;
      }

      _loadMoreMessages();
    });

    _textController = TextEditingController();
    _textController.addListener(() => counter.value = _textController.text.length);
    focusNode = FocusNode();
  }

  // TODO: SMOOTH LOADING, SAVE OLD PIXELS, ADD BUNCH OF MSG THEN JUMPTO OLD POSITION
  void _loadMoreMessages() {
    // add dummy loading indicator
    Game.inst.messages.insert(0, const DummyLoadingIndicator());

    SocketIO.inst.socket.emitWithAck('load_messages', Game.inst.messages[1].id, ack: (List list) {
      // remove dummy loading indicator
      if (Game.inst.messages.first is! DummyLoadingIndicator) {
        // we have a problem here
        return;
      }

      Game.inst.messages.removeAt(0);

      if (list.isEmpty) {
        // whatever it is error or not, turn off loading feature by setting isFirst = true
        Game.inst.messages.first.data['first'] = true;
        return;
      }

      for (var i = list.length - 1; i >= 0; i--) {
        Game.inst.addMessage((color) => Message.fromJSON(data: list[i], backgroundColor: color),
            head: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
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
            data: {'player_name': MePlayer.inst.name, 'text': text}, backgroundColor: color));
        Get.find<PlayerController>(tag: MePlayer.inst.id).showMessage(text);
        // emit to server
        Game.inst.state.value.submitMessage(text);
      }

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

  static const double _height = 600;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: GlobalStyles.borderRadius, color: Colors.white),
        width: width,
        height: _height,
        child: const Column(children: [
          Expanded(child: Center(child: Messages())),
          SizedBox(height: 10),
          GuessInput()
        ]));
  }
}

class GameChatMobile extends StatelessWidget {
  const GameChatMobile({super.key, this.height = GameChat._height});

  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: GlobalStyles.borderRadius, color: Colors.white),
        width: GameChat.width,
        height: height,
        alignment: Alignment.center,
        child: Messages());
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
            children: Game.inst.messages)));
  }
}

class GuessInput extends StatelessWidget {
  const GuessInput({super.key});

  static const double height = 38.6;

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<GameChatController>();
    return Stack(alignment: Alignment.centerRight, children: [
      Container(
          margin: const EdgeInsets.all(2.8),
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
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(3)) // Set border radius
                      ),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black87, // Adjust color as desired
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(3)) // Set border radius
                      )))),
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

class GuessInputMobile extends StatelessWidget {
  const GuessInputMobile({super.key});

  static double getHeight(double width) => GameplayMobile.scaleRatio * width;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (ct, constraints) => SizedBox(
            height: getHeight(context.width),
            child: FittedBox(
                child: Container(
                    decoration:
                        BoxDecoration(borderRadius: GlobalStyles.borderRadius, color: Colors.white),
                    height: GuessInput.height,
                    width: GuessInput.height / GameplayMobile.scaleRatio,
                    child: const GuessInput()))));
  }
}
