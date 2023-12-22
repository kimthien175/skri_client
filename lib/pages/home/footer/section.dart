import 'package:cd_mobile/models/gif_manager.dart';
import 'package:cd_mobile/utils/styles.dart';
import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section(this.icon, this.title, this.content, {super.key});
  final String icon;
  final String title;
  final Widget content;
  @override
  Widget build(BuildContext context) {
    return 
    Stack(children: [
    Container(
        width: 320,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: PanelStyles.color,
          borderRadius: GlobalStyles.borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child:  Text(title, style: TextStyle(color: PanelStyles.textColor, fontWeight: FontWeight.bold, fontSize: 24))),
            const SizedBox(height: 20),
             content
          ],
        )
        ),Positioned(left:28, top: 28, child: SizedBox(width: 32, height: 32, child: FittedBox(child: GifManager.inst.misc(icon).widgetWithShadow())))]);
  }
}
