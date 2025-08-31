import 'dart:core';
import 'package:get/get.dart';
import 'package:skribbl_client/utils/read_json.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'gif/gif.dart';

class GifManager extends GetxService {
  //#region Singleton
  GifManager._internal();
  static GifManager? _inst;
  static GifManager get inst => _inst!;
  //#endregion

  final List<SingleGifModel> color = [];

  final List<SingleGifModel> eyes = [];

  final List<SingleGifModel> mouth = [];

  final List<SingleGifModel> special = [];

  final Map<String, SingleGifModel> _misc = {};
  SingleGifModel misc(String name) => _misc[name]!;

  static bool get isEmpty => _inst == null;

  static Future<GifManager> init() async {
    assert(_inst == null);
    _inst = GifManager._internal();
    await inst.loadResources();
    return _inst!;
  }

  Future<void> loadResources() async {
    Map info = await readJSON('assets/gif/info.json');

    for (String key in info.keys) {
      // load color
      if (key == "color") {
        await loadByList(color, info[key]);
      } else if (key == "misc") {
        await loadByName(_misc, info[key]["content"]);
      } else if (key == "eyes") {
        await loadByList(eyes, info[key]);
      } else if (key == "mouth") {
        await loadByList(mouth, info[key]);
      } else if (key == "special") {
        await loadByList(special, info[key]);
      }
    }
  }

  Future<void> loadByList(List<SingleGifModel> list, Map info) async {
    ByteData data = await rootBundle.load(info['source']);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());

    //#region load frames
    List<ui.FrameInfo> frames = [];

    var frameCount = codec.frameCount;
    for (var i = 0; i < frameCount; i++) {
      var frame = await codec.getNextFrame();
      frames.add(frame);
    }
    //#endregion

    int columnCount = (frames[0].image.width / info['spriteSize']['width']).floor();
    int quantity = info['quantity'];
    int rowCount = (quantity / columnCount).ceil();
    int spriteCount = 0;
    int spriteWidth = info['spriteSize']['width'];
    int spriteHeight = info['spriteSize']['height'];

    rowLoop:
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        int left = (spriteCount % columnCount) * spriteWidth;
        int right = left + spriteWidth;
        int top = (spriteCount / columnCount).floor() * spriteHeight;
        int bottom = top + spriteHeight;
        Rect rect =
            Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());

        int index = list.length;
        list.add(ChildGifModel(rect, frames, index: index));
        spriteCount = spriteCount + 1;

        if (spriteCount == quantity) break rowLoop;
      }
    }
  }

  Future<void> loadByName(Map<String, SingleGifModel> map, List info) async {
    for (Map element in info) {
      String name = element['name'];
      if (element.containsKey('rect')) {
        ByteData data = await rootBundle.load(element['source']);
        ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());

        List<ui.FrameInfo> frames = [];

        var frameCount = codec.frameCount;
        for (var i = 0; i < frameCount; i++) {
          var frame = await codec.getNextFrame();
          frames.add(frame);
        }

        var mapRect = element['rect'];

        map[name] = ChildGifModel(
            Rect.fromLTRB(mapRect['left'].toDouble(), mapRect['top'].toDouble(),
                mapRect['right'].toDouble(), mapRect['bottom'].toDouble()),
            frames);
      } else {
        map[name] = await FullGifModel.fromPath(element['source']);
      }
    }
  }
}
