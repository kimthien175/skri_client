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
  int get colorLength =>_color.length;

  final List<ChildGif> _eyes = [];
  ChildGif eyes(int index) => _eyes[index];
  int get eyesLength => _eyes.length;

  final List<ChildGif> _mouth = [];
  ChildGif mouth(int index) => _mouth[index];
  int get mouthLength => _mouth.length;

  final List<ChildGif> _special = [];
  ChildGif special(int index) =>_special[index];
  int get specialLength =>_special.length;

  final Map<String, Widget> _misc = {};
  Widget misc(String name) => _misc[name]!;

  Future<void> loadResources() async {
    Map info = await readJSON('assets/gif/info.json');

    for (String key in info.keys) {
      // load color
      if (key == "color") {
        await loadByList(_color, info[key]);
      } else if (key == "misc") {
        await loadByName(_misc, info[key]["content"]);
      } else if (key == "eyes"){
        await loadByList(_eyes, info[key]);
      } else if (key =="mouth"){
        await loadByList(_mouth, info[key]);
      } else if (key == "special"){
        await loadByList(_special, info[key]);
      }
    }
  }

  Future<void> loadByList(List<ChildGif> list, Map info) async {
    ByteData data = await rootBundle.load(info['source']);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());

    List<ui.FrameInfo> frames = [];

    var frameCount = codec.frameCount;
    for (var i = 0; i < frameCount; i++) {
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
        int left = (spriteCount % columnCount) * spriteWidth;
        int right = left + spriteWidth;
        int top = (spriteCount / columnCount).floor() * spriteHeight;
        int bottom = top + spriteHeight;
        Rect rect = Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());

        list.add(ChildGif(rect, frames));
        spriteCount = spriteCount + 1;

        if (spriteCount == quantity) break rowLoop;
      }
    }
  }

  loadByName(Map<String, Widget> map, List info) async {
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


        map[name] = ChildGif(Rect.fromLTRB(
          mapRect['left'].toDouble(), 
          mapRect['top'].toDouble(), 
          mapRect['right'].toDouble(), 
          mapRect['bottom'].toDouble()),
          frames
          );
      } else {
        // load width, height
        ByteData data = await rootBundle.load(element['source']);
        ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        var img = (await codec.getNextFrame()).image;

        map[name] = Image.asset(element['source'], height: img.height.toDouble(), width: img.width.toDouble());
      }
    }
  }
}
