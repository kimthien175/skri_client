part of 'dropdown.dart';

class _DropdownList<T> extends TooltipController {
  _DropdownList({required this.parent})
      : super(position: const TooltipPosition.centerBottom(), tooltip: const _DropdownListWidget());

  final _DropdownState<T> parent;

  late FocusScopeNode focusScopeNode;

  @override
  void onInit() {
    super.onInit();
    focusScopeNode = FocusScopeNode(
        debugLabel: tag,
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
        });
  }

  @override
  void onClose() {
    focusScopeNode.dispose();
    super.onClose();
  }

  @override
  Future<bool> show() async {
    if (await super.show()) {
      // current value get focused
      parent.value.controller.focusNode.requestFocus();
      await parent.controller.forward();

      return true;
    }
    return false;
  }

  @override
  Future<bool> hide() async {
    await parent.controller.reverse();
    return super.hide();
  }
}

class _DropdownListWidget<T> extends StatelessWidget {
  //OverlayChildWidget<_DropdownList<T>> {
  const _DropdownListWidget();

  @override
  Widget build(BuildContext context) {
    var c = OverlayWidget.of<_DropdownList<T>>(context);
    return ClipRect(
        child: SlideTransition(
            position: c.parent.controller
                .drive(Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)),
            child: FocusScope(
                parentNode: c.parent.focusNode,
                autofocus: true,
                node: c.focusScopeNode,
                child: Material(
                    child: SizedBox(
                        width: (c.parent.key.currentContext!.findRenderObject() as RenderBox)
                            .size
                            .width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: c.parent.widget.items.map((e) => e.widget).toList()))))));
  }
}
