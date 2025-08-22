part of 'draw.dart';

// TODO: test for changing word, because it is const constructor
class _WordIndicatorStatus extends StatelessWidget {
  const _WordIndicatorStatus();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('DRAW_THIS'.tr),
      Text((Game.inst.state.value as _EmittingPerformerDrawState).word,
          style: const TextStyle(fontVariations: [FontVariation.weight(900)], fontSize: 25.2))
    ]);
  }
}

class _VisibleHintStatus extends StatelessWidget {
  const _VisibleHintStatus();

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('GUESS_THIS'.tr), Obx(() => Text(Get.find<HintController>().hint.value))]);
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
