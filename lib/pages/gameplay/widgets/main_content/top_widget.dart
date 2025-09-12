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
                  child: Center(child: Obx(() => controller.child.value)))))
    ]);
  }
}

class TopWidgetController extends GetxController with GetTickerProviderStateMixin {
  final Rx<Widget> child = (const SizedBox() as Widget).obs;

  final mainContentController = Get.put(_MainContentController());

  late final AnimationController _contentController;
  late final AnimationController _backgroundController;
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> backgroundOpactityAnimation;

  static Duration get contentDuration => const Duration(milliseconds: 800);
  static Duration get backgroundDuration => const Duration(milliseconds: 800);

  @override
  void onInit() {
    super.onInit();
    _contentController = AnimationController(
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
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack));

    backgroundOpactityAnimation = Tween(begin: 0.0, end: 1.0).animate(_backgroundController);
  }

  void stop() {
    _contentController.stop();
    _backgroundController.stop();
    _cancelableDelay?.stop();
  }

  _CancelableDelay? _cancelableDelay;
  Future<void> wait(Duration duration) {
    _cancelableDelay = _CancelableDelay(duration);
    return _cancelableDelay!.future;
  }

  @override
  onClose() {
    stop();

    _contentController.dispose();
    _backgroundController.dispose();

    super.onClose();
  }

  Future forwardBackground({required double from}) async {
    mainContentController.show();
    return _backgroundController.forward(from: from).orCancel;
  }

  Future reverseBackground({required double from}) =>
      _backgroundController.reverse(from: from).orCancel.whenComplete(mainContentController.hide);

  Future forwardContent({required double from}) => _contentController.forward(from: from).orCancel;

  Future reverseContent({required double from}) => _contentController.reverse(from: from).orCancel;

  set background(double value) {
    if (value == 0) {
      mainContentController.hide();
      _backgroundController.value = value;
    } else {
      _backgroundController.value = value;
      mainContentController.show();
    }
  }

  set content(double value) => _contentController.value = value;

  double get background => _backgroundController.value;
}

class _CancelableDelay {
  _CancelableDelay(Duration waitFor) {
    _completer = Completer();
    _timer = Timer(waitFor, _completer.complete);
  }

  late final Timer _timer;
  late final Completer<void> _completer;

  Future<void> get future => _completer.future;

  void stop() {
    if (_completer.isCompleted) return;
    _timer.cancel();
    _completer.completeError(TickerCanceled());
  }
}
