import 'package:skribbl_client/models/gif_manager.dart';
import 'package:get/get.dart';

class ResourcesController extends GetxController {
  ResourcesController._internal() {
    load();
  }

  static final ResourcesController _inst = ResourcesController._internal();
  static ResourcesController get inst => _inst;

  Future<void> load() async {
    await Future.wait([GifManager.inst.loadResources()]);

    for (int i = 0; i < onDone.length; i++) {
      onDone[i]();
    }
    isLoaded.value = true;
    onDone.clear();
  }

  var isLoaded = false.obs;
  List<Function()> onDone = [];
}
