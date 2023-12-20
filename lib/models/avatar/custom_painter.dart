import 'package:cd_mobile/models/avatar/avatar.dart';
import 'package:flutter/material.dart';

class AvatarCustomPainter extends CustomPainter {
  AvatarCustomPainter(this.avatar, this.frameIndex, this._paint);

  final Avatar avatar;
  final int frameIndex;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    avatar.colorModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.eyesModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.mouthModel.getCustomPainter(frameIndex, _paint).paint(canvas, size);

    if (avatar.winner){
      Avatar.crownCustomPainter()(frameIndex, _paint).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}