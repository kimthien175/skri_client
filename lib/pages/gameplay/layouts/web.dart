import 'package:skribbl_client/pages/pages.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GameplayWeb extends StatelessWidget {
  const GameplayWeb({super.key});
  static const double width = 1312;
  @override
  Widget build(BuildContext context) {
    var verticalScrollDetails = ScrollableDetails.vertical(controller: ScrollController());
    var horizontalScrollDetails = ScrollableDetails.horizontal(controller: ScrollController());
    return Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: verticalScrollDetails.controller,
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: horizontalScrollDetails.controller,
            child: SingleChild2DScrollView(
                horizontalDetails: horizontalScrollDetails,
                verticalDetails: verticalScrollDetails,
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
