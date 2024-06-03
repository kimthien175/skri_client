import 'package:flutter/material.dart';
import 'package:get/get.dart';

void addOverlay(OverlayEntry overlayEntry) {
  final overlayState =
      Navigator.of(Get.overlayContext!, rootNavigator: false).overlay!;

  overlayState.insert(overlayEntry);
}
