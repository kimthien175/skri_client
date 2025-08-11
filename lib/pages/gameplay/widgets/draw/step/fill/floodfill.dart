part of 'fill.dart';

class _FloodFillStep extends FillStep {
  _FloodFillStep._init();

  @override
  bool get onEnd => true;

  late Offset _point;
  @override
  void Function(ui.Offset point) get onDown => (point) => _point = point;

  ui.Image? image;

  @override
  void drawCache(Canvas canvas) {
    assert(DrawManager.inst.drawFrom!.id >= id);
    canvas.drawImage(image!, const Offset(0, 0), Paint());
  }

  Future<ui.Image> _compileTemp() async {
    ui.Image img = await prev!.cache.toImage(DrawManager.width.toInt(), DrawManager.height.toInt());

    var byteList = await FloodFiller.fill(image: img, point: _point, fillColor: _color);

    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(byteList, DrawManager.width.toInt(), DrawManager.height.toInt(),
        ui.PixelFormat.rgba8888, completer.complete);

    return completer.future;
  }

  /// for fill zone obviouslly, compile temp for this and continue the queue
  Future<void> compileTemp() async {
    assert(prev != null, """compileTemp only get called in _drawLazy, 
        which means canvas already have something on it, 
        so prev must be != null""");

    // incase prevstep is brush step or other step
    // if (prev.cache == null) {
    //   prevStep.switchToTemp();
    // }

    // _compileTemp().then((value) async {
    //   fillZoneQueue.removeFirst();

    //   image = value;

    //   // switch to draw temp
    //   _drawMain = _drawImage;

    //   DrawManager.inst.rerenderLastStep();

    //   // compile next node
    //   if (fillZoneQueue.isEmpty) return;

    //   fillZoneQueue.first.compileTemp();
    // }).catchError((e) async {
    //   fillZoneQueue.removeFirst();

    //   // remove this node
    //   DrawManager.inst.pastSteps.removeAt(id);

    //   for (int i = id; i < DrawManager.inst.pastSteps.length; i++) {
    //     DrawManager.inst.pastSteps[i].id--;
    //   }

    //   // compile next node
    //   if (fillZoneQueue.isEmpty) return;

    //   fillZoneQueue.first.compileTemp();
    // });

    /// in case the whole canvas have the same color with current color, return false
    /// otherwise return true

    /// In case canvas have something on it,
    /// not a blank space with any color (prev == null or ClearStep or FillStep)
    // void _drawLazy(Canvas canvas) {
    //   // draw previous node temp
    //   prev?.draw(canvas);

    //   if (isAddedToQueue) return;

    //   //#region FILL ZONE
    //   fillZoneQueue.add(this);
    //   if (fillZoneQueue.length == 1) {
    //     compileTemp();
    //   }
    //   //#endregion

    //   isAddedToQueue = true;
    // }
  }

  /// do nothing, wait for cache is done
  @override
  void drawFreshly(ui.Canvas canvas) {}
}
