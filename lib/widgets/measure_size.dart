import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MeasureSize extends StatelessWidget {
  const MeasureSize({super.key, required this.child, required this.onChange});

  final Widget child;
  final void Function() onChange;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => onChange());
    return child;
  }
}
