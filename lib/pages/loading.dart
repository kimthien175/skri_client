import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration:
                const BoxDecoration(image: DecorationImage(scale: 1.2, repeat: ImageRepeat.repeat, image: AssetImage('assets/background.png'))),
            child: const Center(child: CircularProgressIndicator())));
  }
}
