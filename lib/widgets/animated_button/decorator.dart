import 'package:skribbl_client/widgets/animated_button/builder.dart';

abstract class AnimatedButtonDecorator {
  void decorate(AnimatedButtonBuilder builder);
  void Function() get clean;
}
