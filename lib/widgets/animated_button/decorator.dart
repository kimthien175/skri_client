library animated_button_decorator;

export 'decorators/tooltip.dart';
export 'decorators/opacity.dart';
export 'decorators/scale.dart';

import 'animated_button.dart';

abstract class AnimatedButtonDecorator {
  const AnimatedButtonDecorator();
  void decorate(AnimatedButtonState state);
  void clean() {}
}
