import 'package:skribbl_client/models/game/game.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/utils.dart';

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
            child: Column(
              children: [const Expanded(child: Center(child: Messages())), GuessInput()],
            )));
  }
}

// TODO: TEST SCROLL UPDATE
class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: Obx(() => ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: Game.inst.messages,
            )));
  }
}

class GuessInput extends StatelessWidget {
  GuessInput({super.key});
  final controller = Get.put(GuessInputController());
  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(alignment: Alignment.centerRight, children: [
          Container(
              margin: const EdgeInsets.only(left: 2.8, right: 2.8, bottom: 2.8),
              child: TextField(
                focusNode: controller.focusNode.value,
                textInputAction: TextInputAction.send,
                onSubmitted: controller.submit,
                controller: controller.textController,
                onChanged: (text) => controller.text.value = text,
                maxLength: 100,
                minLines: 1,
                maxLines: 3, // Allow for multiple lines
                //keyboardType: TextInputType.multiline, // Enable multiline input
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600), // Set text and hint text font size
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 22),
                  hintText: 'guess_input_placeholder'.tr, // Use the hint text from the image
                  hintStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700), // Set hint text font size
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
                  child: Text(
                      controller.text.value.isNotEmpty
                          ? controller.text.value.length.toString()
                          : '',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
        ]));
  }
}

class GuessInputController extends GetxController {
  var text = ''.obs;
  var textController = TextEditingController(text: '');
  var focusNode = FocusNode().obs;
  void submit(String text) {
    text = text.trim();
    if (text.isNotEmpty) {
      // submit
      Game.inst.addMessage((color) => PlayerChatMessage(
            playerName: MePlayer.inst.name,
            chat: text,
            backgroundColor: color,
          ));
      // emit to server
      SocketIO.inst.socket.emit('player_chat', text);
    }

    // clear the text
    this.text.value = '';
    textController.clear();
    focusNode.value = FocusNode();
    focusNode.value.requestFocus();
  }
}
