import '../gif.dart';
import 'dart:ui' as ui;

abstract class SingleGifModel<MODEL_TYPE extends GifModel<MODEL_TYPE>> extends GifModel<MODEL_TYPE>{
  SingleGifModel(this.frames, super._width, super._height);
  List<ui.FrameInfo> frames;
}
