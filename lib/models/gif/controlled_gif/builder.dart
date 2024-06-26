
import 'package:cd_mobile/models/gif/controlled_gif/controller.dart';
import 'package:cd_mobile/models/gif/gif.dart';

// ignore: must_be_immutable
abstract class ControlledGifBuilder<MODEL_TYPE extends GifModel<MODEL_TYPE>> extends GifBuilder<MODEL_TYPE>{
  ControlledGifBuilder(super.model, {super.key});
  static GifController controller = GifController();
}