import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:skribbl_client/utils/socket_io.dart';
import 'package:flutter/material.dart';

import '../draw/manager.dart';
import 'like_dislike.dart';
import 'dart:ui' as ui;

class DrawViewController extends GetxController {
  late final LikeAndDislikeOverlayController buttonsController;
  late final GlobalKey anchorKey;
  @override
  void onInit() {
    super.onInit();
    anchorKey = GlobalKey();
    buttonsController = LikeAndDislikeOverlayController(anchorKey: anchorKey);
  }
}

class DrawViewWidget extends StatelessWidget {
  const DrawViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<DrawViewController>();
    return ClipRRect(
        key: controller.anchorKey,
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: Container(
          height: DrawManager.height,
          width: DrawManager.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: CustomPaint(
              size: const Size(DrawManager.width, DrawManager.height),
              painter: _DrawViewCustomPainter()),
        ));
  }
}

class _DrawViewCustomPainter extends CustomPainter {
  _DrawViewCustomPainter() : super(repaint: DrawViewManager.inst);
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
  static final DrawViewManager _inst = DrawViewManager._internal();
  static DrawViewManager get inst => _inst;
  DrawViewManager._internal() {
    SocketIO.inst.socket.on('draw:temp', (data) async {
      TempStepView.fromJSON(data);
    });
    SocketIO.inst.socket.on('draw:down_current', (data) {
      inst.current = CurrentStepView.fromJSON(data);
      inst.notifyListeners();
    });

    SocketIO.inst.socket.on('draw:update_current', (data) {
      inst.current!.update(data);
      inst.notifyListeners();
    });
    SocketIO.inst.socket.on('draw:clear', (_) {
      inst.current = null;
      inst.temp = null;
      inst.notifyListeners();
    });
  }

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
  void update(dynamic point) {}
}

class BrushCurrentViewStep extends CurrentStepView {
  BrushCurrentViewStep(dynamic data) {
    _brush = Paint()
      ..strokeWidth = data['size']
      ..color = Color.fromARGB(data['a'], data['r'], data['g'], data['b'])
      ..strokeCap = StrokeCap.round;

    points.add(Offset(data['point']['x'], data['point']['y']));
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

  @override
  void update(point) {
    points.add(Offset(point['x'], point['y']));
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
