part of 'draw.dart';

class _WordIndicatorStatus extends StatelessWidget {
  const _WordIndicatorStatus();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('DRAW_THIS'.tr),
      Obx(() => Text((Game.inst.state.value as _EmittingPerformerDrawState).word,
          style: const TextStyle(fontVariations: [FontVariation.weight(900)], fontSize: 25.2)))
    ]);
  }
}

class _VisibleHintStatus extends StatelessWidget {
  const _VisibleHintStatus();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('GUESS_THIS'.tr),
      Obx(() {
        var hint = Get.find<HintController>().hint.value;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hint),
          Text(hint.length.toString(),
              style: TextStyle(fontSize: 10, fontVariations: [FontVariation.weight(800)]))
        ]);
      })
    ]);
  }
}

class _HiddenHintStatus extends StatelessWidget {
  const _HiddenHintStatus();

  static const String value = 'Hidden';
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Text('WORD_HIDDEN'.tr), Text('???')]);
  }
}
