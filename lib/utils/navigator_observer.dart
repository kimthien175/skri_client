import 'package:get/get.dart';

// class _MyNavigatorObserver extends NavigatorObserver {
//   _MyNavigatorObserver._internal();
//   // static final _NavigatorObserver _inst = _NavigatorObserver._internal();
//   // static _NavigatorObserver get inst => _inst;

//   final List<Route> _routeStack = [];

//   int get lenght => _routeStack.length;

//   int indexOf(String routeName) {
//     for (var i = 0; i < _routeStack.length; i++) {
//       if (_routeStack[i].settings.name == routeName) return i;
//     }
//     return -1;
//   }

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     _routeStack.removeLast();
//   }

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     _routeStack.add(route);
//   }

//   @override
//   void didRemove(Route route, Route? previousRoute) {
//     throw Exception('MyNavigatorObserver: unimplemented');
//   }

//   @override
//   void didReplace({Route? newRoute, Route? oldRoute}) {
//     throw Exception('MyNavigatorObserver: unimplemented');
//   }
// }

extension SafeNavigation on GetInterface {
  /// Similar to **Get.toNamed()**, <br>
  /// But if `page` exists in navigation stack, then pop until reach existing `page`
  // Future<void> safelyToNamed<T>(
  //   String page, {
  //   dynamic arguments,
  //   int? id,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  // }) async {
  //   var pageIndex = NavObserver.indexOf(page);
  //   if (pageIndex != -1) {
  //     Get.close(NavObserver.lenght - pageIndex - 1);
  //   } else {
  //     await Get.toNamed<T>(page,
  //         arguments: arguments,
  //         id: id,
  //         preventDuplicates: preventDuplicates,
  //         parameters: parameters);
  //   }
  // }
}

// ignore: library_private_types_in_public_api, non_constant_identifier_names
//final NavObserver = _MyNavigatorObserver._internal();
