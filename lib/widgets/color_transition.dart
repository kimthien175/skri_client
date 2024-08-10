import 'package:flutter/material.dart';

class ColorTransition extends AnimatedWidget {
  const ColorTransition({super.key, required this.builder, required super.listenable});
  final Widget Function(Color color) builder;

  @override
  Widget build(BuildContext context) => builder((listenable as Animation).value);
}
