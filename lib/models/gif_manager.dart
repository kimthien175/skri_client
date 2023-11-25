import 'dart:core';
import 'package:cd_mobile/models/child_gif.dart';
import 'package:cd_mobile/utils/read_json.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

class GifManager {
  //#region Singleton
  GifManager._internal();
  static final GifManager _inst = GifManager._internal();
  static GifManager get inst => _inst;
  //#endregion

  final List<ChildGif> _color = [];
  ChildGif color(int index) => _color[index];

  final List<AssetImage> _eyes = [];
  AssetImage eyes(int index) => _eyes[index];

  final List<AssetImage> _mouth = [];
  AssetImage mouth(int index) => _mouth[index];

  final Map<String, AssetImage> _misc = {};
  AssetImage misc(String name) => _misc[name]!;

  Future<void> loadResources() async {
    Map info = await readJSON('assets/gif/info.json');

    for (String key in info.keys){
      // load color
      if (key == "color") {
        await loadByList(_color, info[key]);
      }
    }

  }

  Future<void> loadByList(List<ChildGif> list, Map info) async {
    ByteData data = await rootBundle.load(info['source']);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());

    List<ui.FrameInfo> frames = [];

    var frameCount = codec.frameCount;
    for (var i =0; i<frameCount; i++){
      var frame = await codec.getNextFrame();
      frames.add(frame);
    }


    int columnCount = (frames[0].image.width / info['spriteSize']['width']).floor();
    int quantity = info['quantity'];
    int rowCount = (quantity / columnCount).ceil();
    int spriteCount = 0;
    int spriteWidth = info['spriteSize']['width'];
    int spriteHeight = info['spriteSize']['height'];

    rowLoop:
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < columnCount; j++) {
        int left = (spriteCount % columnCount)*spriteWidth;
        int right = left+spriteWidth;
        int top = (spriteCount / columnCount).floor()*spriteHeight;
        int bottom = top+spriteHeight;
        Rect rect = Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
        
        list.add(ChildGif(rect,frames));
        spriteCount = spriteCount+1;

        if (spriteCount == quantity) break rowLoop;
      }
    }
  }

  loadByName() {}
}
