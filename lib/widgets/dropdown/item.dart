// ignore_for_file: library_private_types_in_public_api

part of 'dropdown.dart';

class DropdownItem<T> {
  DropdownItem({required this.value, required this.child}) {
    Get.lazyPut(() => _DropdownItemController(item: this), tag: tag);
  }

  final T value;
  final Widget child;

  _DropdownItemWidget<T> get widget => _DropdownItemWidget(item: this);
  _DropdownItemController<T> get controller => Get.find<_DropdownItemController<T>>(tag: tag);

  String get tag => value.toString();
}

/// ID by item.value
class _DropdownItemController<T> extends GetxController {
  _DropdownItemController({required this.item});
  final DropdownItem<T> item;

  late FocusNode focusNode;

  late Rx<Color> backgroundColor;

  @override
  void onInit() {
    super.onInit();

    focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );

    focusNode.addListener(updateColor);

    backgroundColor = defaultColor.obs;
  }

  @override
  void onClose() {
    focusNode.dispose();
    super.onClose();
  }

  _DropdownList<T> get list {
    String? tag = focusNode.enclosingScope?.debugLabel;
    return Get.find<OverlayController>(tag: tag) as _DropdownList<T>;
  }

  void onTap() {
    // close menu
    list.hide();

    // make changes
    var parent = list.parent;
    if (parent.value.value != item) {
      // change color of current item
      var oldItemController = parent.value.value.controller;

      parent.value.value = item;

      var onChange = parent.widget.onChange;
      if (onChange != null) {
        onChange(item.value);
      }

      updateColor();
      oldItemController.updateColor();
    }
  }

  Color get defaultColor => Colors.white;

  void updateColor() {
    backgroundColor.value = (list.parent.value.value == item)
        ? Colors.blue.shade100
        : (focusNode.hasFocus)
            ? Colors.amber.shade300
            : defaultColor;
  }

  void onEnter(PointerEnterEvent event) {
    focusNode.requestFocus();
  }
}

class _DropdownItemWidget<T> extends StatelessWidget {
  const _DropdownItemWidget({required this.item});
  final DropdownItem<T> item;

  @override
  Widget build(BuildContext context) {
    var c = item.controller;
    return MouseRegion(
        onEnter: c.onEnter,
        child: GestureDetector(
            onTap: c.onTap,
            child: Focus(
                focusNode: c.focusNode,
                child: Obx(() => Container(
                    color: c.backgroundColor.value,
                    padding: const EdgeInsets.only(left: 12),
                    child: c.item.child)))));
  }
}
