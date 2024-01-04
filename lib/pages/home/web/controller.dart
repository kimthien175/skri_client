import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebController extends GetxController {
  var isMinimumSize = false.obs;
//  Size? mainContentSize;
//  Size? footerSize;
  var mainContentKey = GlobalKey();
  var footerKey = GlobalKey();

  var firstRun = true.obs;

  /// Suppose mainContentKey is settled before footerKey.
  /// So call this function on footer size listener
  void processLayout() {
    var mainHeight = mainContentKey.currentContext?.size?.height;
    var footerHeight = footerKey.currentContext?.size?.height;
    if (mainHeight != null && footerHeight != null) {
      isMinimumSize.value = mainHeight + footerHeight <= Get.height;
    } else {
      isMinimumSize.value = false;
    }
  }
}
