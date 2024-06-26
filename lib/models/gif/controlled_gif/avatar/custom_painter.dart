import 'package:cd_mobile/models/gif/controlled_gif/avatar/model.dart';
import 'package:flutter/material.dart';

class AvatarCustomPainter extends CustomPainter {
  AvatarCustomPainter(this.avatar, this.frameIndex, this._paint);

  final AvatarModel avatar;
  final int frameIndex;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    avatar.color.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.eyes.getCustomPainter(frameIndex, _paint).paint(canvas, size);
    avatar.mouth.getCustomPainter(frameIndex, _paint).paint(canvas, size);

    if (avatar.winner){
      AvatarModel.crownCustomPainter(frameIndex, _paint).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}