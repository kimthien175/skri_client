import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image(image: const AssetImage('assets/gif/about.gif'))));
  }
}
