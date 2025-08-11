part of 'fill.dart';

/// this class exist in case previous step is `PlainDrawStep` as well
mixin _FullFillStep on FillStep, PlainDrawStep {
  @nonVirtual
  @override
  bool get onEnd {
    if (_color != _bannedColor) {
      track();
      entryDraw = drawFreshly;
      return true;
    }

    return false;
  }

  @nonVirtual
  @override
  void Function(ui.Offset point) get onDown => (_) {};

  @nonVirtual
  @override
  void drawFreshly(Canvas canvas) {
    canvas.drawColor(_color, BlendMode.src);
  }

  @nonVirtual
  @override
  Color get color => _color;

  // for checking color for this step is valid or not
  Color get _bannedColor;
}

class _FirstFullFillStep extends FillStep with PlainDrawStep, _FullFillStep {
  @override
  Color get _bannedColor => Colors.white;
}

/// prev is not PlainDrawStep with the same color
class _NonFirstFullFillStep extends FillStep with PlainDrawStep, _FullFillStep {
  @override
  Color get _bannedColor {
    assert(DrawManager.inst.tail is PlainDrawStep);
    return (DrawManager.inst.tail as PlainDrawStep).color;
  }
}
