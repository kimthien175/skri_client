part of 'dropdown.dart';

class _DropdownListController<T> extends TooltipController with GetSingleTickerProviderStateMixin {
  _DropdownListController({required T? value, required this.items, required this.onChange})
    : super(position: const TooltipPosition.centerBottom(), tooltip: _DropdownListWidget<T>()) {
    focusScopeNode = FocusScopeNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          var key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowDown) {
            node.nextFocus();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp) {
            node.previousFocus();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.escape) {
            hide();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    currentItem = ((value == null) ? items.first : items.firstWhere((e) => e.value == value)).obs;
    itemControllers = {};
    for (var item in items) {
      itemControllers[item.value] = _DropdownItemController(item: item, listController: this);
    }
  }

  List<DropdownItem<T>> items;
  late final Map<T, _DropdownItemController<T>> itemControllers;

  void Function(T value)? onChange;

  late final FocusNode anchorFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        var key = event.logicalKey;
        if (key == LogicalKeyboardKey.enter) {
          toggle();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
  );
  GlobalKey key = GlobalKey();

  late final Rx<DropdownItem<T>> currentItem;

  late final FocusScopeNode focusScopeNode;
  late final AnimationController slideController = AnimationController(
    vsync: this,
    duration: AnimatedButton.duration,
  );

  @override
  void onClose() {
    focusScopeNode.dispose();
    anchorFocusNode.dispose();
    for (var key in itemControllers.entries) {
      itemControllers[key]?.onClose();
    }
    super.onClose();
  }

  @override
  Future<bool> show() async {
    if (slideController.value == 1 || slideController.velocity > 0) return false;

    if (!isShowing) await super.show();

    // current value get focused
    itemControllers[currentItem.value.value]?.focusNode.requestFocus();

    await slideController.forward();

    return true;
  }

  @override
  Future<bool> hide() async {
    if (!isShowing || slideController.velocity < 0) return false;

    focusScopeNode.unfocus();
    await slideController.reverse();
    return super.hide();
  }

  Future<bool> toggle() => (isShowing && slideController.velocity >= 0) ? hide() : show();
}

class _DropdownListWidget<T> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<_DropdownListController<T>>(context)!;
    final buttonBox = c.key.currentContext!.findRenderObject() as RenderBox;
    var children = c.items.map((e) => _DropdownItemWidget(item: e)).toList();

    return TapRegion(
      onTapOutside: (event) {
        // except the dropdown button
        final localPressedPoint = buttonBox.globalToLocal(event.position);
        if (buttonBox.paintBounds.contains(localPressedPoint)) return;
        c.hide();
      },
      child: ClipRect(
        clipper: _BottomAndSidesClipper(),
        child: SlideTransition(
          position: c.slideController.drive(
            Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
          ),
          child: FocusScope(
            parentNode: c.anchorFocusNode,
            autofocus: true,
            node: c.focusScopeNode,
            child: Material(
              child: Container(
                decoration: BoxDecoration(
                  color: _DropdownItemController.defaultColor,
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)],
                ),
                width: buttonBox.size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomAndSidesClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return (Rect.fromLTWH(-20, 0, size.width + 40, size.height + 20));
  }

  @override
  bool shouldReclip(_) => false;
}
