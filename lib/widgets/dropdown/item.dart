// ignore_for_file: library_private_types_in_public_api

part of 'dropdown.dart';

class DropdownItem<T> {
  DropdownItem({required this.value, required this.child});

  final T value;
  final Widget child;

  late __DropdownItemWidgetState<T> state;
}

class _DropdownItemWidget<T> extends StatefulWidget {
  const _DropdownItemWidget({super.key, required this.item});

  final DropdownItem<T> item;

  @override
  State<_DropdownItemWidget<T>> createState() => __DropdownItemWidgetState<T>();
}

class __DropdownItemWidgetState<T> extends State<_DropdownItemWidget<T>> {
  Color backgroundColor = defaultColor;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    widget.item.state = this;

    focusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
        onTap();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });

    focusNode.addListener(updateColor);

    backgroundColor = defaultColor;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void updateColor() {
    var newColor = getNewColor();
    if (newColor != backgroundColor) {
      setState(() {
        backgroundColor = newColor;
      });
    }
  }

  void onTap() {
    // close menu
    listController.hide();

    // make changes
    var anchorState = listController.anchorState;
    var currentItem = anchorState.currentItem;
    if (currentItem.value == widget.item) return;

    // change color of current item
    var oldItemState = anchorState.currentItem.state;

    anchorState.currentItem = widget.item;

    updateColor();
    oldItemState.updateColor();

    var onChange = anchorState.widget.onChange;
    if (onChange != null) onChange(widget.item.value);
  }

  Color getNewColor() => listController.anchorState.currentItem == widget.item
      ? Colors.blue.shade100
      : (focusNode.hasFocus ? Colors.amber.shade300 : defaultColor);

  static Color get defaultColor => Colors.white;

  _DropdownListController<T> get listController =>
      OverlayWidget.of<_DropdownListController<T>>(context)!;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (PointerEnterEvent event) {
          if (!listController.focusScopeNode.hasFocus) return;

          focusNode.requestFocus();
        },
        child: GestureDetector(
            onTap: onTap,
            child: Focus(
                focusNode: focusNode,
                child: Container(
                    color: backgroundColor,
                    padding: const EdgeInsets.only(left: 12),
                    child: widget.item.child))));
  }
}
