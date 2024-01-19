import 'package:cd_mobile/models/game_play/game.dart';
import 'package:cd_mobile/models/game_play/message.dart';
import 'package:cd_mobile/models/game_play/player.dart';
import 'package:cd_mobile/utils/socket_io.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameChat extends StatelessWidget {
  const GameChat({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: GlobalStyles.borderRadius,
        child: Container(
            width: 300,
            height: 600,
            color: Colors.white,
            child: Column(
              children: [Expanded(child: Center(child: Messages())), GuessInput()],
            )));
  }
}

class Messages extends StatelessWidget {
  Messages({super.key});
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      return ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: Game.inst.messages,
      );
    });
  }
}

class GuessInput extends StatelessWidget {
  GuessInput({super.key});
  final controller = Get.put(GuessInputController());
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerRight, children: [
      Container(
          margin: const EdgeInsets.only(left: 2.8, right: 2.8, bottom: 2.8),
          child: TextField(
            textInputAction: TextInputAction.send,
            onSubmitted: controller.submit,
            controller: controller.textController,
            onChanged: (text) => controller.text.value = text,
            maxLength: 100,
            minLines: 1,
            maxLines: 3, // Allow for multiple lines
            keyboardType: TextInputType.multiline, // Enable multiline input
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
      Obx(() => Positioned(
          right: 2.8,
          child: Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                  controller.text.value.isNotEmpty ? controller.text.value.length.toString() : '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))))
    ]);
  }
}

class GuessInputController extends GetxController {
  var text = ''.obs;
  var textController = TextEditingController(text: '');
  void submit(String text) {
    // submit
    Game.inst.addMessage( {'type': 'guess', 'player_name': MePlayer.inst.name, 'guess':text});
    // emit to server
    SocketIO.inst.socket.emit('guess',{'player':MePlayer.inst.toJSON(),'guess':text});

    // clear the text
    this.text.value = '';
    textController.clear();
  }
}
