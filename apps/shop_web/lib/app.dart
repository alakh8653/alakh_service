/// Root application widget for the Shop Web dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/core.dart';

// ---------------------------------------------------------------------------
// Bloc placeholder stubs
// TODO(blocs): Replace each stub with the real Bloc class once the feature
// layers are implemented. The stubs below allow the app to compile and route
// correctly before the individual feature Blocs are written.
// ---------------------------------------------------------------------------

class _StubBloc extends Cubit<Object?> {
  _StubBloc() : super(null);
}

class DashboardBloc extends _StubBloc {}
class QueueControlBloc extends _StubBloc {}
class ShopBookingsBloc extends _StubBloc {}
class StaffManagementBloc extends _StubBloc {}
class EarningsBloc extends _StubBloc {}
class ShopAnalyticsBloc extends _StubBloc {}
class SettlementsBloc extends _StubBloc {}
class ComplianceBloc extends _StubBloc {}
class ShopSettingsBloc extends _StubBloc {}

// ---------------------------------------------------------------------------
// ShopApp
// ---------------------------------------------------------------------------

/// The root widget of the Shop Web application.
///
/// Wires up:
/// - [MultiBlocProvider] for all feature-level Blocs / Cubits.
/// - [MaterialApp.router] with the application [GoRouter].
/// - Material 3 theming.
/// - Localisation delegates.
class ShopApp extends StatelessWidget {
  /// Creates the [ShopApp].
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO(di): Obtain each Bloc from GetIt once injectable is wired up.
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(),
        ),
        BlocProvider<QueueControlBloc>(
          create: (_) => QueueControlBloc(),
        ),
        BlocProvider<ShopBookingsBloc>(
          create: (_) => ShopBookingsBloc(),
        ),
        BlocProvider<StaffManagementBloc>(
          create: (_) => StaffManagementBloc(),
        ),
        BlocProvider<EarningsBloc>(
          create: (_) => EarningsBloc(),
        ),
        BlocProvider<ShopAnalyticsBloc>(
          create: (_) => ShopAnalyticsBloc(),
        ),
        BlocProvider<SettlementsBloc>(
          create: (_) => SettlementsBloc(),
        ),
        BlocProvider<ComplianceBloc>(
          create: (_) => ComplianceBloc(),
        ),
        BlocProvider<ShopSettingsBloc>(
          create: (_) => ShopSettingsBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Shop Dashboard',
        debugShowCheckedModeBanner: false,

        // ---------------------------------------------------------------
        // Routing
        // ---------------------------------------------------------------
        routerConfig: ShopRouter.router,

        // ---------------------------------------------------------------
        // Theme – Material 3 with an indigo/violet seed colour.
        // ---------------------------------------------------------------
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
          ),
          fontFamily: 'Inter',
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Inter',
        ),

        // ---------------------------------------------------------------
        // Localisation
        // ---------------------------------------------------------------
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // TODO(l10n): Uncomment after running `flutter gen-l10n`.
          // AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
      ),
    );
  }
}
