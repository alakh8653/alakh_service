import 'package:analytics_module/analytics_module.dart';
import 'package:api_client/api_client.dart';
import 'package:auth_module/auth_module.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_module/notification_module.dart';
import 'package:ui_kit/ui_kit.dart';

import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final apiClient = ApiClient(baseUrl: Env.apiBaseUrl);
  final tokenManager = TokenManager();
  final authService = AuthService(apiClient: apiClient, tokenManager: tokenManager);
  final notificationService = NotificationService();
  final analyticsService = AnalyticsService();

  await notificationService.initialize();
  await analyticsService.initialize();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<NotificationService>.value(value: notificationService),
        RepositoryProvider<AnalyticsService>.value(value: analyticsService),
      ],
      child: const AlakhServiceApp(),
    ),
  );
}

class AlakhServiceApp extends StatelessWidget {
  const AlakhServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlakhService',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(child: Text('AlakhService Mobile')),
      ),
    );
  }
}
