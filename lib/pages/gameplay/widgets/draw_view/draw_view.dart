import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:flutter/material.dart';
import 'package:skribbl_client/widgets/widgets.dart';

import '../draw/manager.dart';

import '../utils.dart';

part 'like_dislike.dart';

class DrawViewWidget extends StatelessWidget {
  const DrawViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = const Size(DrawManager.width, DrawManager.height);
    return Stack(children: [
      ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          child: Container(
              height: DrawManager.height,
              width: DrawManager.width,
              decoration: const BoxDecoration(color: Colors.white),
              child: Stack(children: [
                CustomPaint(size: size, painter: _PastStepsCustomPainter()),
                CustomPaint(size: size, painter: _CurrentStepCustomPainter())
              ]))),
      Positioned(right: 0, top: 0, child: const _LikeAndDislikeButtons())
    ]);
  }
}

class _PastStepsCustomPainter extends CustomPainter {
  _PastStepsCustomPainter() : super(repaint: DrawReceiver.inst.pastStepsNotifier);
  @override
  void paint(Canvas canvas, Size size) {
    var inst = DrawReceiver.inst;
    inst.pastSteps[inst.tailID]?.drawBackward(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CurrentStepCustomPainter extends CustomPainter {
  _CurrentStepCustomPainter() : super(repaint: DrawReceiver.inst.currentStepNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    DrawReceiver.inst.currentStep?.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class DrawViewManager extends ChangeNotifier {
//   static final DrawViewManager _inst = DrawViewManager._internal();
//   static DrawViewManager get inst => _inst;

//   DrawViewManager._internal();

//   Map<int, DrawStep> pastSteps = {};
//   // DrawViewManager._internal() {
//   //   SocketIO.inst.socket.on('draw:temp', (data) async {
//   //     TempStepView.fromJSON(data);
//   //   });
//   //   SocketIO.inst.socket.on('draw:down_current', (data) {
//   //     current = CurrentStepView.fromJSON(data);
//   //     notifyListeners();
//   //   });

//   //   SocketIO.inst.socket.on('draw:update_current', (data) {
//   //     current!.update(data);
//   //     notifyListeners();
//   //   });
//   //   SocketIO.inst.socket.on('draw:clear', clear);
//   // }

//   // CurrentStepView? current;
//   // TempStepView? temp;

//   // void clear(_) {
//   //   current = null;
//   //   temp = null;
//   //   notifyListeners();
//   // }

//   // Map<int, TempStepView> cachedTemp = {};
// }

// abstract class CurrentStepView {
//   static CurrentStepView fromJSON(dynamic data) {
//     switch (data['type']) {
//       case 'brush':
//         return BrushCurrentViewStep(data);
//       default:
//         throw Exception('CurrentStepView fromJSON: unimplemented case $data');
//     }
//   }

//   void draw(Canvas canvas);
//   void update(dynamic point) {}
// }

// class BrushCurrentViewStep extends CurrentStepView {
//   BrushCurrentViewStep(dynamic data) {
//     _brush = Paint()
//       ..strokeWidth = data['size']
//       ..color = Color.from(alpha: data['a'], red: data['r'], green: data['g'], blue: data['b'])
//       ..strokeCap = StrokeCap.round;

//     points.add(Offset(data['point']['x'], data['point']['y']));
//   }
//   late ui.Paint _brush;
//   List<Offset> points = [];

//   @override
//   void draw(Canvas canvas) {
//     if (points.length == 1) {
//       canvas.drawPoints(ui.PointMode.points, points, _brush);
//       return;
//     }
//     for (int i = 0; i < points.length - 1; i++) {
//       canvas.drawLine(points[i], points[i + 1], _brush);
//     }
//   }

//   @override
//   void update(point) {
//     points.add(Offset(point['x'], point['y']));
//   }
// }

// abstract class TempStepView {
//   static Future<TempStepView?> fromJSON(dynamic data) async {
//     var cached = DrawViewManager.inst.cachedTemp[data['hashCode']];
//     if (cached == null) {
//       TempStepView newItem;
//       switch (data['type']) {
//         case 'color':
//           newItem = ColorTempStepView(Color.fromARGB(data['a'], data['r'], data['g'], data['b']));
//           break;

//         case 'Uint8List':
//           var codec = await ui.instantiateImageCodec(Uint8List.view(data['Uint8List']
//               as ByteBuffer)); //, targetWidth: decodedImage.width, targetHeight: height)

//           var frameInfo = await codec.getNextFrame();
//           newItem = ImageTempStepView(frameInfo.image);
//           break;

//         default:
//           throw Exception('TempStepView fromJSON: unimplemented case, $data');
//       }
//       DrawViewManager.inst.cachedTemp[data['hashCode']] = newItem;
//       return newItem;
//     }

//     return cached;
//   }

//   void draw(Canvas canvas);
// }

// class ImageTempStepView extends TempStepView {
//   ImageTempStepView(this.image);
//   ui.Image image;
//   static Paint paint = Paint();
//   @override
//   void draw(Canvas canvas) {
//     canvas.drawImage(image, Offset.zero, paint);
//   }
// }

// class ColorTempStepView extends TempStepView {
//   ColorTempStepView(this.color);
//   Color color;
//   @override
//   void draw(Canvas canvas) {
//     canvas.drawColor(color, BlendMode.src);
//   }
// }
