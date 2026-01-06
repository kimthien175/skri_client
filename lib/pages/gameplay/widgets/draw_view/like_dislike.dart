part of 'draw_view.dart';

class LikeAndDislikeController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> offsetAnim;
  late final Animation<double> opacAnim;
  final RxBool _isEnabled = false.obs;
  bool get isEnabled => _isEnabled.value;

  void enable({double? from}) {
    _controller.forward(from: from);
    _isEnabled.value = true;
  }

  void disable() {
    _controller.value = 0;
    _isEnabled.value = false;
  }

  final Duration duration = const Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();

    _controller = AnimationController(vsync: this, duration: duration);
    offsetAnim = _controller.drive(Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero));
    opacAnim = _controller.drive(Tween(begin: 0.5, end: 1.0));
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}

class _LikeAndDislikeButtons extends StatelessWidget {
  const _LikeAndDislikeButtons();

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<LikeAndDislikeController>();
    var gif = GifManager.inst.misc;
    return ClipRRect(
      child: SlideTransition(
        position: controller.offsetAnim,
        child: FadeTransition(
          opacity: controller.opacAnim,
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedButton(
                  skipTravelFocus: !controller.isEnabled,
                  onTap: () {
                    controller.disable();

                    SocketIO.inst.socket.emit('like_dislike', true);
                  },
                  decorators: const [
                    AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                    AnimatedButtonScaleDecorator(),
                  ],
                  child: gif('thumb_up').builder.initWithShadow().fit(height: 50),
                ),
                AnimatedButton(
                  skipTravelFocus: !controller.isEnabled,
                  onTap: () {
                    controller.disable();

                    SocketIO.inst.socket.emit('like_dislike', false);
                  },
                  decorators: const [
                    AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                    AnimatedButtonScaleDecorator(),
                  ],
                  child: gif('thumb_down').builder.initWithShadow().fit(height: 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
