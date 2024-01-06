import '../gif.dart';
import 'dart:ui' as ui;

abstract class SingleGifModel extends GifModel{
  SingleGifModel(this.frames, super._width, super._height);
  List<ui.FrameInfo> frames;
}
