import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeLayoutController extends GetxController {
  var firstRun = true.obs;
}

abstract class HomeLayout extends StatelessWidget {
  final HomeLayoutController layoutController = HomeLayoutController();

  HomeLayout({super.key});
}
