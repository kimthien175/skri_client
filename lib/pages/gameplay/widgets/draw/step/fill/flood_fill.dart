import 'dart:typed_data';
import 'dart:ui' as ui;

class FloodFiller {
  //int stackSize = 16777216;
  //int stackPointer = 0;
  List<int> stack = [];
  Uint8List _fill() {
    //CrissCross fills lines in 4 directions : up(q2 = 2), down(q2=3), left(q2=-2), right(q2=-3)
    int x1, x2, lastminx, lastminy, lastmaxx, lastmaxy, t1, t2, q1, q2;

    int x = pointX;
    int y = pointY;
    int w = width;
    int h = height;
    int h2 = h - 1;

    //color oldcolor = tB[y][x];
    // stackPointer = 0;

    //if (Same(fillcolor, oldcolor)) return;
    //go left and right and fill

    x1 = x;
    while (x < w && sameWithOld(x, y)) {
      x++;
    }
    x2 = x;
    while (x1 > -1 && sameWithOld(x1, y)) {
      x1--;
    }
    x1++;
    for (x = x1; x < x2; x++) {
      changeColor(x, y);
    }
    //push the line above(2) and below(3)
    if (y > 0) push4(x1, x2, y - 1, 2);
    if (y < h2) push4(x1, x2, y + 1, 3);

    while (stack.length > 3) {
      q2 = stack.removeLast();
      q1 = stack.removeLast();
      t2 = stack.removeLast();
      t1 = stack.removeLast();

      if (q2 == 2) {
        if (t1 < 0) t1 = 0;
        if (t2 > w) t2 = w;
        // going left to right, for each x of t1 to t2, fill up (2)
        //remember the minimum y visited of the previous x
        lastminy = q1;
        for (x = t1; x < t2; x++) {
          y = q1;
          if (sameWithOld(
              x, y)) //start by checking if there are any oldcolor pixels at all in this column
          {
            changeColor(x, y);
            for (--y; y > -1; y--) {
              //if there are, fill them
              if (!sameWithOld(x, y)) break;
              changeColor(x, y);
            }
          }
          //if upper y is less than the previous, push the left side (-2) of that part
          if (y < lastminy && x > 0) {
            push4(y, lastminy + 1, x - 1, -2);
          } else
          // if upper y is more, push the right side (-3) of that part
          // ignore: curly_braces_in_flow_control_structures
          if (y > lastminy && x < w) push4(lastminy, y + 1, x, -3);
          lastminy = y;
        }
        //may have to push the right side beyond x=t2 (-3)
        if (lastminy < q1 && x < w) push4(lastminy, q1 + 1, x, -3);
      } else if (q2 == 3) {
        if (t1 < 0) t1 = 0;
        if (t2 > w) t2 = w;
        // going left to right, for each x of t1 to t2, fill down (3)
        //remember the maximum y visited of the previous x
        lastmaxy = q1;

        for (x = t1; x < t2; x++) {
          y = q1;
          if (sameWithOld(x, y)) {
            changeColor(x, y);
            for (++y; y < h; y++) {
              if (!sameWithOld(x, y)) break;
              changeColor(x, y);
            }
          }

          if (y < lastmaxy && x < w) {
            push4(y, lastmaxy + 1, x, -3);
            // ignore: curly_braces_in_flow_control_structures
          } else if (y > lastmaxy && x > 0) push4(lastmaxy, y + 1, x - 1, -2);
          lastmaxy = y;
        }
        if (q1 < lastmaxy && x < w) push4(q1, lastmaxy + 1, x, -3);
      } else if (q2 == -2) {
        if (t1 < 0) t1 = 0;
        if (t2 > h) t2 = h;
        // going up to down, for each y of t1 to t2, fill left (-2)
        //remember the minimum x visited of the previous y
        lastminx = q1;
        for (y = t1; y < t2; y++) {
          x = q1;
          if (sameWithOld(x, y)) {
            changeColor(x, y);
            for (--x; x > -1; x--) {
              if (!sameWithOld(x, y)) break;
              changeColor(x, y);
            }
          }
          if (x < lastminx && y > 0) {
            push4(x, lastminx + 1, y - 1, 2);
            // ignore: curly_braces_in_flow_control_structures
          } else if (x > lastminx && y < h) push4(lastminx, x + 1, y, 3);

          lastminx = x;
        }
        if (lastminx < q1 && y < h) push4(lastminx, q1 + 1, y, 3);
      }
      //if (q2 == -3)
      else {
        if (t1 < 0) t1 = 0;
        if (t2 > h) t2 = h;
        // going up to down, for each y of t1 to t2, fill right (-3)
        //remember the maximum x visited of the previous y
        lastmaxx = q1;
        for (y = t1; y < t2; y++) {
          x = q1;
          if (sameWithOld(x, y)) {
            changeColor(x, y);
            for (++x; x < w; x++) {
              if (!sameWithOld(x, y)) break;
              changeColor(x, y);
            }
          }

          if (x < lastmaxx && y < h) {
            push4(x, lastmaxx + 1, y, 3);
            // ignore: curly_braces_in_flow_control_structures
          } else if (x > lastmaxx && y > 0) push4(lastmaxx, x + 1, y - 1, 2);

          lastmaxx = x;
        }
        if (q1 < lastmaxx && y < h) push4(q1, lastmaxx + 1, y, 3);
      }
    }
    return byteList;
  }

  void push4(int x, int y, int z, int q) {
    stack.add(x);
    stack.add(y);
    stack.add(z);
    stack.add(q);
  }

  void changeColor(int x, int y) {
    // decodedImage.setPixelRgba(x, y, fillColorR, fillColorG, fillColorB, fillColorA);
    var index = pixelIndex(x, y);
    byteList[index] = fillColorR;
    byteList[index + 1] = fillColorG;
    byteList[index + 2] = fillColorB;
    byteList[index + 3] = fillColorA;
  }

  // void changePixelColor(img.Pixel pixel) {
  //   decodedImage.setPixelRgba(
  //       pixel.x, pixel.y, fillColor.red, fillColor.green, fillColor.blue, fillColor.alpha);
  // }

  bool sameWithOld(int x, int y) {
    // var pixel = decodedImage.getPixel(x, y);
    // return pixel.r == targetRed &&
    //     pixel.g == targetGreen &&
    //     pixel.b == targetBlue &&
    //     pixel.a == targetAlpha;
    var index = pixelIndex(x, y);
    return byteList[index] == targetRed &&
        byteList[index + 1] == targetGreen &&
        byteList[index + 2] == targetBlue &&
        byteList[index + 3] == targetAlpha;
  }

  int pixelIndex(int x, int y) => (y * width + x) * 4;
  // TESTED
  // bool isTheSameColorWithFiller(img.Pixel pixel) {
  //   return pixel.r == fillColorR &&
  //       pixel.g == fillColorG &&
  //       pixel.b == fillColorB &&
  //       pixel.a == fillColorA;
  // }
  bool get isTheSameColorWithFiller {
    var index = pixelIndex(pointX, pointY);
    return byteList[index] == fillColorR &&
        byteList[index + 1] == fillColorG &&
        byteList[index + 2] == fillColorB &&
        byteList[index + 3] == fillColorA;
  }

  final int width;
  final int height;

  Uint8List byteList;
  //img.Image decodedImage;

  // final int pointX;
  // final int pointY;

  // final ui.Color fillColor;

  static Future<Uint8List> fill(
      {required ui.Image image, required ui.Offset point, required ui.Color fillColor}) async {
    var byteData = await image.toByteData();
    if (byteData == null) throw Exception('FloodFill: null byte data');

    // check if fill color and target color are the same or not

    // var decodedImage = img.decodeImage(byteData.buffer.asUint8List());
    // if (decodedImage == null) throw Exception('Decode image failed');

    var filler = FloodFiller._internal(
        //decodedImage: decodedImage,
        byteList: byteData.buffer.asUint8List(),
        pointX: point.dx.toInt(),
        pointY: point.dy.toInt(),
        fillColorR: fillColor.red,
        fillColorB: fillColor.blue,
        fillColorG: fillColor.green,
        fillColorA: fillColor.alpha,
        width: image.width,
        height: image.height);

    if (filler.isTheSameColorWithFiller) throw Exception('FloodFill: duplicated color');

    return filler._fill();
  }

  FloodFiller._internal(
      {
      //required this.decodedImage,
      required this.byteList,
      required this.pointX,
      required this.pointY,
      required this.fillColorR,
      required this.fillColorG,
      required this.fillColorB,
      required this.fillColorA,
      required this.width,
      required this.height}) {
// get target color
    //chosenPixel = decodedImage.getPixelSafe(pointX, pointY);
    // if (chosenPixel is img.PixelUndefined) {
    //   throw Exception('FloodFill: chosen point is out of range');
    // }
    var index = pixelIndex(pointX, pointY);
    targetRed = byteList[index];
    targetGreen = byteList[index + 1];
    targetBlue = byteList[index + 2];
    targetAlpha = byteList[index + 3];
  }

  int fillColorR;
  int fillColorG;
  int fillColorB;
  int fillColorA;

  int pointX;
  int pointY;

  // Queue<img.Pixel> queue = Queue();
  late num targetRed;
  late num targetBlue;
  late num targetGreen;
  late num targetAlpha;
  //late img.Pixel chosenPixel;
}
