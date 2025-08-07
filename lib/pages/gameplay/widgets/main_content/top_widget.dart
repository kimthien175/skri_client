part of 'main_content.dart';

class TopWidget extends StatelessWidget {
  const TopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TopWidgetController>();
    return Stack(children: [
      FadeTransition(
          opacity: controller.backgroundOpactityAnimation,
          child: Container(
            height: 600,
            width: 800,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(3, 8, 29, 0.8),
              borderRadius: GlobalStyles.borderRadius,
            ),
          )),
      ClipRect(
          child: SlideTransition(
              position: controller.offsetAnimation,
              child: SizedBox(
                  height: 600,
                  width: 800,
                  child: Center(child: Obx(() => Game.inst.state.value.topWidget)))))
    ]);
  }
}

class TopWidgetController extends GetxController with GetTickerProviderStateMixin {
  final mainContentController = Get.put(_MainContentController());

  late final AnimationController contentController;
  late final AnimationController _backgroundController;
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> backgroundOpactityAnimation;

  static Duration get contentDuration => const Duration(milliseconds: 800);
  static Duration get backgroundDuration => const Duration(milliseconds: 800);

  @override
  void onInit() {
    super.onInit();
    contentController = AnimationController(
      duration: TopWidgetController.contentDuration,
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: TopWidgetController.backgroundDuration,
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: contentController, curve: Curves.easeOutBack));

    backgroundOpactityAnimation = Tween(begin: 0.0, end: 1.0).animate(_backgroundController);
  }

  @override
  onClose() {
    contentController.dispose();
    _backgroundController.dispose();
    super.onClose();
  }

  TickerFuture forwardBackground({required double from}) {
    mainContentController.show();
    return _backgroundController.forward(from: from);
  }

  reverseBackground({required double from}) async {
    await _backgroundController.reverse(from: from);
    mainContentController.hide();
  }

  set background(double value) {
    if (value == 0) {
      mainContentController.hide();
      _backgroundController.value = value;
    } else {
      _backgroundController.value = value;
      mainContentController.show();
    }
  }

  double get background => _backgroundController.value;
}
