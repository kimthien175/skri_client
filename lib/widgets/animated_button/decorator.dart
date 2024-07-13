import 'animated_button.dart';

abstract class AnimatedButtonDecorator {
  void decorate(AnimatedButtonState state);
  void Function() get clean;
}
