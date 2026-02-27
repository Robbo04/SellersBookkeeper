import 'package:flutter/material.dart';
import 'Classes/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellers Bookkeeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 184, 55, 182)),
        useMaterial3: true,
      ),
      home: MainTabScaffold(),
    );
  }
}
