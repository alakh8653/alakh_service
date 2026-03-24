// Copyright (c) 2024 AlakhService. All rights reserved.
// Root application widget.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/l10n.dart';
import 'main.dart';

// ---------------------------------------------------------------------------
// Router placeholder — replace with GoRouter instance from the router module.
// ---------------------------------------------------------------------------
// import 'package:go_router/go_router.dart';
// import 'core/router/app_router.dart';

// ---------------------------------------------------------------------------
// BLoC placeholder imports — uncomment when feature BLoCs are wired up.
// ---------------------------------------------------------------------------
// import 'features/auth/presentation/bloc/auth_bloc.dart';
// import 'features/settings/presentation/bloc/settings_bloc.dart';
// import 'features/notifications/presentation/bloc/notification_bloc.dart';

/// Root widget of the AlakhService mobile application.
///
/// Wraps [MaterialApp.router] with all top-level providers:
/// * Repository providers for feature data layers.
/// * BLoC providers for app-wide state (auth, settings, connectivity, notifications).
/// * Localisation delegates and supported locales.
/// * Light / dark theme configuration driven by the [SettingsBloc].
class App extends StatelessWidget {
  const App({super.key, required this.env});

  /// Environment configuration forwarded from [main].
  final Env env;

  @override
  Widget build(BuildContext context) {
    // TODO(di): Replace stub providers with real DI-resolved instances.
    return MultiRepositoryProvider(
      providers: const [
        // RepositoryProvider<AuthRepository>(
        //   create: (_) => getIt<AuthRepository>(),
        // ),
        // RepositoryProvider<BookingRepository>(
        //   create: (_) => getIt<BookingRepository>(),
        // ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider<AuthBloc>(
          //   create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
          // ),
          // BlocProvider<SettingsBloc>(
          //   create: (_) => getIt<SettingsBloc>()..add(const SettingsLoadRequested()),
          // ),
          // BlocProvider<NotificationBloc>(
          //   create: (_) => getIt<NotificationBloc>(),
          // ),
        ],
        child: _AppView(env: env),
      ),
    );
  }
}

/// Inner widget that builds the [MaterialApp.router] once all providers
/// are available.
class _AppView extends StatelessWidget {
  const _AppView({required this.env});

  final Env env;

  @override
  Widget build(BuildContext context) {
    // TODO(theme): Derive themeMode from SettingsBloc state.
    const themeMode = ThemeMode.system;

    return MaterialApp(
      // ------------------------------------------------------------------
      // App identity
      // ------------------------------------------------------------------
      title: env.appName,
      debugShowCheckedModeBanner: env.flavor != 'production',

      // ------------------------------------------------------------------
      // Theme
      // ------------------------------------------------------------------
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,

      // ------------------------------------------------------------------
      // Localisation
      // ------------------------------------------------------------------
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // ------------------------------------------------------------------
      // Scroll behaviour — allows mouse-drag scrolling on desktop / web
      // ------------------------------------------------------------------
      scrollBehavior: const _AppScrollBehavior(),

      // ------------------------------------------------------------------
      // Router — replace stub with GoRouter when router is wired up.
      // ------------------------------------------------------------------
      // routerConfig: AppRouter.router,
      home: const _PlaceholderHome(),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme helpers
// ---------------------------------------------------------------------------

ThemeData _buildLightTheme() {
  const seedColor = Color(0xFF2563EB); // brand blue
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}

ThemeData _buildDarkTheme() {
  const seedColor = Color(0xFF3B82F6); // slightly lighter blue for dark mode
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}

// ---------------------------------------------------------------------------
// Scroll behaviour
// ---------------------------------------------------------------------------

/// Custom scroll behaviour that enables pointer-device (mouse/trackpad) drag
/// scrolling in addition to touch scrolling on all platforms.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

// ---------------------------------------------------------------------------
// Placeholder home screen — remove once GoRouter is configured.
// ---------------------------------------------------------------------------

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('AlakhService — Router not yet configured'),
      ),
    );
  }
}
