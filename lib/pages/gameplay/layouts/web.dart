import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';

// TODO: test scrollcontroller
class GameplayWeb extends StatefulWidget {
  const GameplayWeb({super.key});
  static const double width = 1312;

  @override
  State<GameplayWeb> createState() => _GameplayWebState();
}

class _GameplayWebState extends State<GameplayWeb> {
  late ScrollController verticalScrollController;
  late ScrollController horizontalScrollController;

  @override
  void initState() {
    super.initState();
    verticalScrollController = ScrollController();
    horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: verticalScrollController,
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: horizontalScrollController,
            child: SingleChild2DScrollView(
                horizontalDetails:
                    ScrollableDetails.horizontal(controller: horizontalScrollController),
                verticalDetails: ScrollableDetails.vertical(controller: verticalScrollController),
                delegate: SingleChild2DDelegate(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                            width: GameplayWeb.width,
                            child: Column(children: [
                              const SizedBox(height: 50),
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: SizedBox(
                                      width: 320,
                                      child: FittedBox(child: Logo(() {
                                        // TODO: LEAVE GAME
                                      })))),
                              GameplayStyles.layoutGap,
                              const GameBar(),
                              GameplayStyles.layoutGap,
                              const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PlayersList(),
                                    GameplayStyles.layoutGap,
                                    // MainContentAndFooter(),
                                    GameplayStyles.layoutGap,
                                    //const GameChat(),
                                    //LangSelector()
                                  ])
                            ])))))));
  }
}
