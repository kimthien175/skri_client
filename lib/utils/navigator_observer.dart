import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  MyNavigatorObserver._internal();
  static final MyNavigatorObserver _inst = MyNavigatorObserver._internal();
  static MyNavigatorObserver get inst => _inst;

  final List<Route> _routeStack = [];

  int get lenght => _routeStack.length;

  int indexOf(String routeName) {
    for (var i = 0; i < _routeStack.length; i++) {
      if (_routeStack[i].settings.name == routeName) return i;
    }
    return -1;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _routeStack.removeLast();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _routeStack.add(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    throw Exception('MyNavigatorObserver: implemented');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    throw Exception('MyNavigatorObserver: implemented');
  }
}
