import 'package:skribbl_client/models/game/game.dart';
import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GameplayWeb extends StatefulWidget {
  const GameplayWeb({super.key});
  static const double width = 1312;

  @override
  State<GameplayWeb> createState() => _GameplayWebState();
}

class _GameplayWebState extends State<GameplayWeb> {
  ScrollController verticalScrollController = ScrollController();
  late ScrollableDetails verticalDetails;
  ScrollController horizontalScrollController = ScrollController();
  late ScrollableDetails horizontalDetails;

  @override
  void initState() {
    super.initState();
    verticalDetails = ScrollableDetails.vertical(controller: verticalScrollController);
    horizontalDetails = ScrollableDetails.horizontal(controller: horizontalScrollController);
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
                horizontalDetails: horizontalDetails,
                verticalDetails: verticalDetails,
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
                                      child: FittedBox(child: Logo(Game.inst.confirmLeave)))),
                              GameplayStyles.layoutGap,
                              const GameBar(),
                              GameplayStyles.layoutGap,
                              const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PlayersList(),
                                    GameplayStyles.layoutGap,
                                    MainContent(),
                                    GameplayStyles.layoutGap,
                                    GameChat(),
                                    //LangSelector()
                                  ])
                            ])))))));
  }
}
