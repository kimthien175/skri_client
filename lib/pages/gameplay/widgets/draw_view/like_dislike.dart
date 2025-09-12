part of 'draw_view.dart';

class LikeAndDislikeController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Offset> offsetAnim;
  late final Animation<double> opacAnim;

  final Duration duration = const Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(vsync: this, duration: duration);
    offsetAnim = controller.drive(Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero));
    opacAnim = controller.drive(Tween(begin: 0.5, end: 1.0));
  }

  @override
  void onClose() {
    controller.dispose();
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedButton(
                      onTap: () {
                        controller.controller.value = 0;

                        SocketIO.inst.socket.emit('like_dislike', true);
                      },
                      decorators: const [
                        AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                        AnimatedButtonScaleDecorator()
                      ],
                      child: gif('thumb_up').builder.initWithShadow().fit(height: 50)),
                  AnimatedButton(
                      onTap: () {
                        controller.controller.value = 0;

                        SocketIO.inst.socket.emit('like_dislike', false);
                      },
                      decorators: const [
                        AnimatedButtonOpacityDecorator(minOpacity: 0.6),
                        AnimatedButtonScaleDecorator()
                      ],
                      child: gif('thumb_down').builder.initWithShadow().fit(height: 50))
                ]))));
  }
}
