import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShopWebApp());
}

class ShopWebApp extends StatelessWidget {
  const ShopWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlakhService — Shop Dashboard',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _ShopHomeScreen(),
    );
  }
}

class _ShopHomeScreen extends StatelessWidget {
  const _ShopHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Dashboard')),
      body: const Center(child: Text('AlakhService — Shop Dashboard')),
    );
  }
}
