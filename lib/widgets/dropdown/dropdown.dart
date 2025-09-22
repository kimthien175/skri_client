library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/styles.dart';
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

  static double defaultScale() => 1.0;

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<Dropdown<T>> {
  late FocusNode focusNode;
  GlobalKey key = GlobalKey();
  late DropdownItem<T> currentItem;
  void _setCurrentItem() {
    currentItem = (widget.value == null)
        ? widget.items.first
        : widget.items.firstWhere((e) => e.value == widget.value);
  }

  late final _DropdownListController listController = _DropdownListController<T>(anchorState: this);
  @override
  void didUpdateWidget(Dropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _setCurrentItem();
  }

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          var key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter) {
            listController.toggle();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    _setCurrentItem();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dropdownButton = GestureDetector(
        onTap: () {
          if (!focusNode.hasFocus) focusNode.requestFocus();
          listController.toggle();
        },
        child: Focus(
            focusNode: focusNode,
            child: InputContainer(
                key: key,
                padding: const EdgeInsets.only(left: 10),
                height: widget.height,
                width: widget.width,
                focusNode: focusNode,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  currentItem.child,
                  RotationTransition(
                      turns: listController.slideController
                          .drive(Tween<double>(begin: 0.0, end: -0.5)),
                      child: ColorTransition(
                          builder: (color) => Icon(Icons.keyboard_arrow_down_rounded, color: color),
                          listenable: listController.slideController.drive(ColorTween(
                              begin: InputStyles.color, end: InputContainer.activeColor))))
                ]))));
    return listController.attach(dropdownButton);
  }
}
