part of 'fill.dart';

/// this class exist in case previous step is `PlainDrawStep` as well
class FullFillStep extends DrawStep with PlainDrawStep {
  FullFillStep() {
    _color = DrawManager.inst.currentColor;
  }

  late final Color _color;

  @override
  void Function(ui.Canvas p1) get drawBackward => (Canvas canvas) {
        canvas.drawColor(_color, BlendMode.src);
      };

  @override
  Color get color => _color;

  @override
  Map<String, dynamic> get toPrivateJSON => {'color': _color.toJSON};

  @override
  String get type => TYPE;
  // ignore: constant_identifier_names
  static const String TYPE = 'full_fill';

  FullFillStep.fromJSON(dynamic json) {
    _color = JSONColor.fromJSON(json['color']);
  }
}
