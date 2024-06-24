import 'package:cd_mobile/pages/gameplay/widgets/game_bar.dart';
import 'package:cd_mobile/pages/gameplay/widgets/players_list/players_list.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:cd_mobile/widgets/logo.dart';
import 'package:cd_mobile/widgets/single_child_2d_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Web extends StatelessWidget {
  const Web({super.key});
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
                    child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: context.height, minWidth: context.width),
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            SizedBox(
                                width: 1312,
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: SizedBox(
                                        width: 320,
                                        child: FittedBox(child: Logo(() {
                                          // Game.inst.leave();
                                        }))))),
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
                              ],
                            )
                          ],
                        ))))));
  }
}
