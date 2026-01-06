// ignore_for_file: library_private_types_in_public_api

part of 'dropdown.dart';

class DropdownItem<T> {
  DropdownItem({required this.value, required this.child});

  final T value;
  final Widget child;
}

class _DropdownItemController<T> extends GetxController {
  _DropdownItemController({required this.item, required this.listController}) {
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
  }

  final DropdownItem<T> item;
  final _DropdownListController<T> listController;
  Rx<Color> backgroundColor = defaultColor.obs;
  static Color get defaultColor => Colors.white;

  late final FocusNode focusNode;

  Color getNewColor() => listController.currentItem.value.value == item.value
      ? Colors.blue.shade100
      : (focusNode.hasFocus ? Colors.amber.shade300 : defaultColor);

  @override
  onClose() {
    focusNode.dispose();
    super.onClose();
  }

  void updateColor() {
    backgroundColor.value = getNewColor();
  }

  void onTap() {
    // make changes
    if (listController.currentItem.value == item) return;

    var oldItemController = listController.itemControllers[listController.currentItem.value.value];
    if (oldItemController == null) return;

    listController.currentItem.value = item;
    updateColor();

    oldItemController.updateColor();

    var onChange = listController.onChange;
    if (onChange != null) onChange(item.value);

    // close menu
    listController.hide();
  }
}

class _DropdownItemWidget<T> extends StatelessWidget {
  const _DropdownItemWidget({super.key, required this.item});

  final DropdownItem<T> item;

  @override
  Widget build(BuildContext context) {
    final listController = OverlayWidget.of<_DropdownListController<T>>(context)!;
    final itemController = listController.itemControllers[item.value]!;
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        if (!listController.focusScopeNode.hasFocus) return;

        itemController.focusNode.requestFocus();
      },
      child: GestureDetector(
        onTap: itemController.onTap,
        child: Focus(
          focusNode: itemController.focusNode,
          child: Obx(
            () => Container(
              color: itemController.backgroundColor.value,
              padding: const EdgeInsets.only(left: 12),
              child: item.child,
            ),
          ),
        ),
      ),
    );
  }
}
