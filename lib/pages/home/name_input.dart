import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: InputStyles.decoration,
            height: 34,
            child: TextField(
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(fontWeight: FontWeight.w800, color: Colors.black38)),
            )));
  }
}
