import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(const MyApp());



class Controller extends GetxController{
  var count = 0.obs;
  increment()=> count++;
}

class Home extends StatelessWidget {
  Home({super.key});

  final Controller c = Controller();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(()=>Text("Clicks: ${c.count}")),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: c.increment,
            child: const Text("INcrease"),
          ),
        ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home:Home(),
    );
  }
}