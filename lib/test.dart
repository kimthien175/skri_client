import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/widgets/dropdown/dropdown.dart';

class _Controller extends GetxController {
  RxInt value = 1.obs;
}

class TestPage extends StatelessWidget {
  TestPage({super.key});

  final _Controller controller = _Controller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
      Obx(() {
        print('render dropdown');
        print(controller.value.value);
        return Dropdown(
            value: controller.value.value,
            items: <int>[1, 2, 3]
                .map((e) => DropdownItem(value: e, child: Text(e.toString())))
                .toList());
      }),
      TextField(
        onSubmitted: (value) {
          controller.value.value = int.parse(value);
          print(controller.value.value);
        },
      )
    ])));
  }
}
