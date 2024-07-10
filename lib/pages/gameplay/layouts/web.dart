import 'package:skribbl_client/pages/gameplay/widgets/game_bar.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/players_list.dart';
import 'package:skribbl_client/utils/styles.dart';
import 'package:skribbl_client/widgets/logo.dart';
import 'package:skribbl_client/widgets/single_child_2d_scroll_view.dart';
import 'package:flutter/material.dart';

class Web extends StatelessWidget {
  const Web({super.key});
  static const double width = 1312;
  @override
  Widget build(BuildContext context) {
    var verticalScrollDetails =
        ScrollableDetails.vertical(controller: ScrollController());
    var horizontalScrollDetails =
        ScrollableDetails.horizontal(controller: ScrollController());
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
                            width: Web.width,
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
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const PlayersList(),
                                    GameplayStyles.layoutGap,
                                    // MainContentAndFooter(),
                                    GameplayStyles.layoutGap,
                                    //const GameChat()
                                  ])
                            ])))))));
  }
}
