part of 'buttons.dart';

class GameDialogButton extends ParentDataWidget<_ButtonParentData> {
  const GameDialogButton.okay({
    super.key,
    this.flex = 1.0,
    this.onTap = OKayDialogButtonChild.defaultOnTap,
    this.autoFocus = false,
  }) : assert(flex > 0),
       super(child: const OKayDialogButtonChild());

  const GameDialogButton.yes({
    super.key,
    this.flex = 1.0,
    this.onTap = OKayDialogButtonChild.defaultOnTap,
    this.autoFocus = false,
  }) : assert(flex > 0),
       super(child: const _YesButtonChild());

  const GameDialogButton.no({
    super.key,
    this.flex = 1.0,
    this.onTap = _NoButtonChild.defaultOnTap,
    this.autoFocus = false,
  }) : assert(flex > 0),
       super(child: const _NoButtonChild());

  const GameDialogButton({
    super.key,
    required super.child,
    this.flex = 1.0,
    this.onTap = OKayDialogButtonChild.defaultOnTap,
    this.autoFocus = false,
  }) : assert(flex > 0);

  final double flex;

  final OnTapCallback onTap;

  final bool autoFocus;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as _ButtonParentData;
    if (parentData.flex != flex) {
      parentData.flex = flex;
      renderObject.parent?.markNeedsLayout();
    }
    if (parentData.onTap != onTap) {
      parentData.onTap = onTap;
      renderObject.parent?.markNeedsSemanticsUpdate();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => throw UnimplementedError();
}

class _ButtonParentData extends ContainerBoxParentData<RenderBox> {
  double flex = 1;
  OnTapCallback onTap = _GameDialogButtonChild.defaultOnTap;
}
