import 'package:flutter/material.dart';
import 'Classes/navigation_bar.dart';
import 'Services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage
  await StorageService.init();
  
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
