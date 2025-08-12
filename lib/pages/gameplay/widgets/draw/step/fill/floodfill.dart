part of 'fill.dart';

class _FloodFillStep extends DrawStep {
  _FloodFillStep({required this.point});

  final Offset point;

  late final Color color = DrawManager.inst.currentColor;

  final Completer<ui.Image> _completer = Completer<ui.Image>();

  @override
  Future<ui.Image> get cache => _completer.future;

  Future<ui.Image> _compileTemp() async {
    var byteList = await FloodFiller.fill(image: await prev!.cache, point: point, fillColor: color);

    Completer<ui.Image> completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(byteList, DrawManager.width.toInt(), DrawManager.height.toInt(),
        ui.PixelFormat.rgba8888, completer.complete);

    return completer.future;
  }

  /// set _image, complete _completer, switch entryDraw to drawCache
  @override
  Future<void> buildCache() async {
    try {
      var image = await _compileTemp();

      _completer.complete(image);

      _drawBackward = (Canvas canvas) {
        canvas.drawImage(image, const Offset(0, 0), Paint());
      };

      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      DrawManager.inst.pastStepRepaint.notifyListeners();
    } catch (e) {
      _completer.complete(prev!.cache);

      unlink();
    }
  }

  late void Function(Canvas) _drawBackward = (Canvas canvas) {
    prev?.drawBackward(canvas);
  };

  @override
  void Function(ui.Canvas p1) get drawBackward => _drawBackward;
}
