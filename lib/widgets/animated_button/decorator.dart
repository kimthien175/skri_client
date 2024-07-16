library animated_button_decorator;

export 'decorators/tooltip/tooltip.dart';
export 'decorators/opacity.dart';
export 'decorators/scale.dart';

import 'animated_button.dart';

abstract class AnimatedButtonDecorator {
  void decorate(AnimatedButtonState state);
  void clean() {}
}
