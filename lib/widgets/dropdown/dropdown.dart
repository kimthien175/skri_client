library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
import '../widgets.dart';

part 'list.dart';
part 'item.dart';

class Dropdown<T> extends StatefulWidget {
  const Dropdown({
    this.menuOffset = 0.0,
    this.onChange,
    this.value,
    required this.items,
    this.width,
    this.height,
    this.unactiveColor = Colors.white,
    this.activeColor = GlobalStyles.colorPanelButton,
    super.key,
  }) : assert(items.length > 0, 'List of items must be not empty');

  final void Function(T value)? onChange;
  final T? value;
  final List<DropdownItem<T>> items;

  final double menuOffset;

  final double? height;
  final double? width;

  final Color unactiveColor;
  final Color activeColor;

  static double defaultScale() => 1.0;

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<Dropdown<T>> {
  late final _DropdownListController<T> listController = _DropdownListController<T>(
    value: widget.value,
    items: widget.items,
    onChange: widget.onChange,
  );

  @override
  void didUpdateWidget(Dropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (listController.items != widget.items) listController.items = widget.items;

    listController.currentItem.value = (widget.value == null)
        ? listController.items.first
        : listController.items.firstWhere((e) => e.value == widget.value);

    if (listController.onChange != widget.onChange) listController.onChange = widget.onChange;
  }

  @override
  Widget build(BuildContext context) {
    var dropdownButton = GestureDetector(
      onTap: () {
        if (!listController.anchorFocusNode.hasFocus) listController.anchorFocusNode.requestFocus();
        listController.toggle();
      },
      child: Focus(
        focusNode: listController.anchorFocusNode,
        child: InputContainer(
          key: listController.key,
          padding: const EdgeInsets.only(left: 10),
          height: widget.height,
          width: widget.width,
          focusNode: listController.anchorFocusNode,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => listController.currentItem.value.child),
              RotationTransition(
                turns: listController.slideController.drive(Tween<double>(begin: 0.0, end: -0.5)),
                child: ColorTransition(
                  builder: (color) => Icon(Icons.keyboard_arrow_down_rounded, color: color),
                  listenable: listController.slideController.drive(
                    ColorTween(begin: InputStyles.color, end: InputContainer.activeColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return listController.attach(dropdownButton);
  }
}
