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

  Color get color => focusNode.hasFocus
      ? Colors.blue
      : isHovered
          ? Colors.amber
          : Colors.white;

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
    focusNode.addListener(() {
      backgroundColor.value = color;
    });

    backgroundColor = color.obs;
  }

  @override
  void onClose() {
    focusNode.dispose();
    super.onClose();
  }

  void onTap() {
    // get current focus scope
    String? tag = focusNode.enclosingScope?.debugLabel;
    var menuController = Get.find<OverlayController>(tag: tag) as _DropdownList<T>;

    // close menu
    menuController.hide();

    // make changes
    var parent = menuController.parent;
    if (parent.value.value != item) {
      parent.value.value = item;

      var onChange = parent.widget.onChange;
      if (onChange != null) {
        onChange(item.value);
      }
    }
  }

  bool isHovered = false;

  void onEnter(PointerEnterEvent event) {
    isHovered = true;
    if (focusNode.hasFocus) return;
    backgroundColor.value = color;
  }

  void onExit(PointerExitEvent event) {
    isHovered = false;
    if (focusNode.hasFocus) return;
    backgroundColor.value = color;
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
        onExit: c.onExit,
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
