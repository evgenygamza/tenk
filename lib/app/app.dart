import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TenK',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5F7354)),
        scaffoldBackgroundColor: const Color(0xFFF4EFE3),
      ),
      home: const Scaffold(body: SizedBox.expand()),
    );
  }
}
