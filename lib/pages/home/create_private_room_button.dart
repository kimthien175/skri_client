import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePrivateRoomButton extends StatelessWidget {
  const CreatePrivateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
        width: double.infinity, 
        margin: const EdgeInsets.only(top: 10),
        child: TextButton(
          style: ButtonStyle(   backgroundColor: const MaterialStatePropertyAll(Color(0xff2c8de7)),shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: GlobalStyles.borderRadius,
                ))),
            onPressed: () {},
            child: Text('create_private_room_button'.tr,
                style: TextStyle( color: PanelStyles.textColor,fontSize: 19.2, fontWeight: FontWeight.w700, shadows: [GlobalStyles.textShadow]))));
  }
}
