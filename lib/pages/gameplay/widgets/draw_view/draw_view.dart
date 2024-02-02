import 'dart:typed_data';

import 'package:cd_mobile/utils/socket_io.dart';
import 'package:flutter/material.dart';

import '../draw/manager.dart';
import 'like_dislike.dart';
import 'dart:ui' as ui;

class DrawViewWidget extends StatelessWidget {
  DrawViewWidget({super.key}) {
    DrawViewManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            child: Container(
              height: DrawManager.height,
              width: DrawManager.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: CustomPaint(
                  size: const Size(DrawManager.width, DrawManager.height),
                  painter: DrawViewCustomPainter(repaint: DrawViewManager.inst)),
            )),
        const LikeAndDislikeButtons()
      ],
    );
  }
}

class DrawViewCustomPainter extends CustomPainter {
  DrawViewCustomPainter({super.repaint});
  @override
  void paint(Canvas canvas, Size size) {
    var inst = DrawViewManager.inst;
    if (inst.temp != null) {
      inst.temp!.draw(canvas);
    }
    if (inst.current != null) {
      inst.current!.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawViewManager extends ChangeNotifier {
  static void init() {
    _inst = DrawViewManager._internal();
    SocketIO.inst.socket.on('draw:temp', (data) async {
      TempStepView.fromJSON(data).then((value) {
        inst.temp = value;
        inst.notifyListeners();
      });
    });
    SocketIO.inst.socket.on('draw:current', (data) {
      inst.current = CurrentStepView.fromJSON(data);
      inst.notifyListeners();
    });
    SocketIO.inst.socket.on('draw:clear', (_) {
      inst.current = null;
      inst.temp = null;
      inst.notifyListeners();
    });
  }

  static DrawViewManager? _inst;
  static DrawViewManager get inst => _inst!;
  DrawViewManager._internal();

  CurrentStepView? current;
  TempStepView? temp;

  Map<int, TempStepView> cachedTemp = {};
}

abstract class CurrentStepView {
  static CurrentStepView fromJSON(dynamic data) {
    switch (data['type']) {
      case 'brush':
        return BrushCurrentViewStep(data);
      default:
        throw Exception('CurrentStepView fromJSON: unimplemented case $data');
    }
  }

  void draw(Canvas canvas);
}

class BrushCurrentViewStep extends CurrentStepView {
  BrushCurrentViewStep(dynamic data) {
    _brush = Paint()
      ..strokeWidth = data['size']
      ..color = Color.fromARGB(data['a'], data['r'], data['g'], data['b'])
      ..strokeCap = StrokeCap.round;
    for (var rawPoint in data['points']) {
      points.add(Offset(rawPoint['x'], rawPoint['y']));
    }
  }
  late ui.Paint _brush;
  List<Offset> points = [];

  @override
  void draw(Canvas canvas) {
    if (points.length == 1) {
      canvas.drawPoints(ui.PointMode.points, points, _brush);
      return;
    }
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], _brush);
    }
  }
}

abstract class TempStepView {
  static Future<TempStepView?> fromJSON(dynamic data) async {
    var cached = DrawViewManager.inst.cachedTemp[data['hashCode']];
    if (cached == null) {
      TempStepView newItem;
      switch (data['type']) {
        case 'color':
          newItem = ColorTempStepView(Color.fromARGB(data['a'], data['r'], data['g'], data['b']));
          break;

        case 'Uint8List':
          var codec = await ui.instantiateImageCodec(Uint8List.view(data['Uint8List']
              as ByteBuffer)); //, targetWidth: decodedImage.width, targetHeight: height)

          var frameInfo = await codec.getNextFrame();
          newItem = ImageTempStepView(frameInfo.image);
          break;

        default:
          throw Exception('TempStepView fromJSON: unimplemented case, $data');
      }
      DrawViewManager.inst.cachedTemp[data['hashCode']] = newItem;
      return newItem;
    }

    return cached;
  }

  void draw(Canvas canvas);
}

class ImageTempStepView extends TempStepView {
  ImageTempStepView(this.image);
  ui.Image image;
  static Paint paint = Paint();
  @override
  void draw(Canvas canvas) {
    canvas.drawImage(image, Offset.zero, paint);
  }
}

class ColorTempStepView extends TempStepView {
  ColorTempStepView(this.color);
  Color color;
  @override
  void draw(Canvas canvas) {
    canvas.drawColor(color, BlendMode.src);
  }
}
