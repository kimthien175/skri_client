part of 'dropdown.dart';

class _DropdownListController<T> extends TooltipController with GetSingleTickerProviderStateMixin {
  _DropdownListController({required this.anchorState})
      : super(
            position: const TooltipPosition.centerBottom(), tooltip: const _DropdownListWidget()) {
    focusScopeNode = FocusScopeNode(onKeyEvent: (node, event) {
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
    });
  }

  final _DropdownState<T> anchorState;

  late final FocusScopeNode focusScopeNode;
  late final AnimationController slideController =
      AnimationController(vsync: this, duration: AnimatedButton.duration);

  @override
  void onClose() {
    focusScopeNode.dispose();
    super.onClose();
  }

  @override
  Future<bool> show() async {
    if (!(await super.show())) return false;

    await slideController.forward();
    // current value get focused
    anchorState.currentItem.state.focusNode.requestFocus();

    return true;
  }

  @override
  Future<bool> hide() async {
    if (!isShowing || slideController.velocity < 0) return false;

    focusScopeNode.unfocus();
    await slideController.reverse();
    return super.hide();
  }

  Future<bool> toggle() => (!isShowing || slideController.velocity < 0) ? show() : hide();
}

class _DropdownListWidget<T> extends StatelessWidget {
  const _DropdownListWidget();

  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<_DropdownListController<T>>(context)!;
    var width = (c.anchorState.key.currentContext!.findRenderObject() as RenderBox).size.width;
    var children = c.anchorState.widget.items.map((e) => _DropdownItemWidget(item: e)).toList();

    return ClipRect(
        clipper: _BottomAndSidesClipper(),
        child: SlideTransition(
            position: c.slideController
                .drive(Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)),
            child: FocusScope(
                parentNode: c.anchorState.focusNode,
                autofocus: true,
                node: c.focusScopeNode,
                child: Material(
                    child: Container(
                        decoration: BoxDecoration(
                            color: __DropdownItemWidgetState.defaultColor,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)]),
                        width: width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: children))))));
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
