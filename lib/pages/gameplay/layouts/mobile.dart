import 'package:get/get.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:flutter/material.dart';

class GameplayMobile extends StatelessWidget {
  const GameplayMobile({super.key});

  static const double scaleRatio = 0.08;

  static const double _gap = 10;

  static const playerListAndChatMinHeight = 600;

  static double getScale(BuildContext context) =>
      GameBarMobile.getHeight(context) / GameBar.webHeight;

  @override
  Widget build(BuildContext context) {
    var restOfHeight = context.height -
        _gap * 2 -
        GameBarMobile.getHeight(context) -
        _gap -
        MainContentMobile.getHeight(context.width - _gap * 2) -
        _gap * 2 -
        GuessInputMobile.getHeight(context.width);

    if (restOfHeight < playerListAndChatMinHeight) {
      return Stack(alignment: Alignment.bottomCenter, children: [
        Padding(
            padding: EdgeInsetsGeometry.only(
                bottom: GuessInputMobile.getHeight(context.width) + _gap * 2),
            child: VerticalScrollViewWidget(
                child: const Padding(
                    padding: EdgeInsets.all(_gap),
                    child: Column(children: [
                      GameBarMobile(),
                      SizedBox(height: _gap),
                      MainContentMobile(),
                      SizedBox(height: _gap),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(child: FittedBox(child: PlayersList())),
                            SizedBox(width: _gap),
                            Expanded(child: FittedBox(child: GameChatMobile()))
                          ])
                    ])))),
        Positioned.fill(
            bottom: 0,
            child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(_gap),
                child: GuessInputMobile()))
      ]);
    }

    var playerListAndChatGivenWidth = (context.width - _gap * 3) / 2;
    return Padding(
        padding: const EdgeInsets.all(_gap),
        child: Column(children: [
          const GameBarMobile(),
          const SizedBox(height: _gap),
          const MainContentMobile(),
          const SizedBox(height: _gap),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: FittedBox(
                        child: SizedBox(
                            width: PlayerCard.width,
                            height: restOfHeight * PlayerCard.width / playerListAndChatGivenWidth,
                            child: VerticalScrollViewWidget(child: const PlayersList())))),
                const SizedBox(width: _gap),
                Expanded(
                    child: FittedBox(
                        child: GameChatMobile(
                            height: restOfHeight * GameChat.width / playerListAndChatGivenWidth)))
              ]),
          const SizedBox(height: _gap),
          const GuessInputMobile(),
        ]));
  }
}

class VerticalScrollViewWidget extends StatefulWidget {
  const VerticalScrollViewWidget({super.key, required this.child});

  final Widget child;

  @override
  State<VerticalScrollViewWidget> createState() => _VerticalScrollViewWidgetState();
}

class _VerticalScrollViewWidgetState extends State<VerticalScrollViewWidget> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: controller,
        child: SingleChildScrollView(controller: controller, child: widget.child));
  }
}
