import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admin_web/core/core.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AdminRouter>().router;

    return MaterialApp.router(
      title: 'Alakh Admin Panel',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
    );
  }

  ThemeData _buildTheme() {
    const background = Color(0xFF0D1117);
    const surface = Color(0xFF161B22);
    const surfaceVariant = Color(0xFF21262D);
    const primary = Color(0xFF1F6FEB);
    const onPrimary = Color(0xFFFFFFFF);
    const onBackground = Color(0xFFC9D1D9);
    const onSurface = Color(0xFFC9D1D9);
    const border = Color(0xFF30363D);
    const muted = Color(0xFF8B949E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: primary,
        onPrimary: onPrimary,
        onBackground: onBackground,
        onSurface: onSurface,
        outline: border,
        secondary: Color(0xFF388BFD),
        error: Color(0xFFF85149),
        onError: Colors.white,
        tertiary: Color(0xFF3FB950),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFF85149)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: const TextStyle(color: onSurface, fontSize: 12),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      iconTheme: const IconThemeData(color: muted, size: 20),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: onBackground, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: onBackground, fontSize: 28, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(color: onBackground, fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(color: onBackground, fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: onBackground, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: onBackground, fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: onBackground, fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: onBackground, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: onBackground, fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: onBackground, fontSize: 14),
        bodyMedium: TextStyle(color: onBackground, fontSize: 13),
        bodySmall: TextStyle(color: muted, fontSize: 12),
        labelLarge: TextStyle(color: onBackground, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: muted, fontSize: 12),
        labelSmall: TextStyle(color: muted, fontSize: 11),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: border),
        ),
        elevation: 8,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        textStyle: const TextStyle(color: onSurface, fontSize: 12),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary, size: 22),
        unselectedIconTheme: IconThemeData(color: muted, size: 22),
        selectedLabelTextStyle: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelTextStyle: TextStyle(color: muted, fontSize: 12),
        indicatorColor: Color(0xFF1F6FEB26),
        useIndicator: true,
      ),
    );
  }
}
