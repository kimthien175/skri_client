import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameChat extends StatelessWidget {
  const GameChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: GlobalStyles.borderRadius,
        ),
        child: Column(
          children: [const Expanded(child: Messages()), GuessInput()],
        ));
  }
}

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
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
            controller: TextEditingController(text: controller.text.value),
            onChanged: (text) => controller.text.value = text,
            maxLength: 100,
            maxLines: null, // Allow for multiple lines
            keyboardType: TextInputType.multiline, // Enable multiline input
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), // Set text and hint text font size
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 22),
              hintText: 'guess_input_placeholder'.tr, // Use the hint text from the image
              hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), // Set hint text font size
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
}
