part of 'fill.dart';

/// this class exist in case previous step is `PlainDrawStep` as well
class _FullFillStep extends DrawStep with PlainDrawStep {
  final Color _color = DrawManager.inst.currentColor;

  @override
  void Function(ui.Canvas p1) get drawBackward => (Canvas canvas) {
        canvas.drawColor(_color, BlendMode.src);
      };

  @override
  Color get color => _color;
}
