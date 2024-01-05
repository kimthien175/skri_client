import 'package:cd_mobile/models/gif/model.dart';
import 'package:cd_mobile/models/shadow_info.dart';
import 'package:flutter/material.dart';

typedef GifBuilderCallback = Widget Function();

// ignore: must_be_immutable
class GifBuilder extends StatelessWidget {
  GifBuilder(this.model, {super.key}) {
    builder = rawWidget(model);
  }

  final GifModel model;
  late GifBuilderCallback builder;

  GifBuilder withFixedSize() {
    builder = () => SizedBox(height: model.height, width: model.width, child: builder());
    return this;
  }

  GifBuilder withShadow({ShadowInfo info = const ShadowInfo()}) {
    builder = () => Stack(clipBehavior: Clip.none, children: [
          Transform.translate(
              offset: Offset(info.offsetLeft, info.offsetTop),
              child: Image.asset(model.path, color: Color.fromRGBO(0, 0, 0, info.opacity))),
          Image.asset(model.path)
        ]);
    return this;
  }

  GifBuilderCallback rawWidget(GifModel model) => () => Image.asset(model.path);

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}
