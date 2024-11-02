library dropdown;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/overlay/overlay.dart';
import 'package:skribbl_client/widgets/overlay/position.dart';
import '../widgets.dart';

part 'list.dart';
part 'item.dart';

class Dropdown<T> extends StatefulWidget {
  const Dropdown(
      {this.menuOffset = 0.0,
      this.onChange,
      this.value,
      required this.items,
      this.width,
      this.height,
      this.unactiveColor = Colors.white,
      this.activeColor = GlobalStyles.colorPanelButton,
      this.scale = Dropdown.defaultScale,
      super.key})
      : assert(items.length > 0, 'List of items must be not empty');

  final void Function(T value)? onChange;
  final T? value;
  final List<DropdownItem<T>> items;

  final double menuOffset;

  final double? height;
  final double? width;

  final Color unactiveColor;
  final Color activeColor;

  final double Function() scale;
  static double defaultScale() => 1.0;

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<Dropdown<T>> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late FocusNode focusNode;
  GlobalKey key = GlobalKey();
  late Rx<DropdownItem<T>> value;

  late _DropdownList menu;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: AnimatedButton.duration);
    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          var key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter) {
            toggleMenu();
          }
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        print('button focus');
      } else {
        print('button UNFOCUS');
      }
    });

    if (widget.value == null) {
      value = widget.items.first.obs;
    } else {
      value = widget.items.firstWhere((e) => e.value == widget.value).obs;
    }

    menu = _DropdownList<T>(parent: this);
  }

  void toggleMenu() {
    if (controller.isDismissed || controller.velocity < 0) {
      // forward
      menu.show();
      // request focus first item
      // menu.focusNode.requestFocus();
      return;
    }
    // reverse
    menu.hide();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (!focusNode.hasFocus) focusNode.requestFocus();
          toggleMenu();
        },
        child: InputContainer(
            key: key,
            padding: const EdgeInsets.only(left: 10),
            height: widget.height,
            width: widget.width,
            focusNode: focusNode,
            child: Focus(
                focusNode: focusNode,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Obx(() => value.value.child),
                  RotationTransition(
                      turns: controller.drive(Tween<double>(begin: 0.0, end: -0.5)),
                      child: ColorTransition(
                          builder: (color) => Icon(Icons.keyboard_arrow_down_rounded, color: color),
                          listenable: controller.drive(ColorTween(
                              begin: InputStyles.color, end: InputContainer.activeColor))))
                ]))));
  }
}
