import 'package:get/get.dart';

class ResponsivePageController extends SuperController {
  ResponsivePageController() {
    isWebLayout = webLayoutStatus.obs;
  }

  /// observable var of controller
  late final RxBool isWebLayout;

  /// get current condition of web layout
  bool get webLayoutStatus => Get.width >= Get.height;

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
