import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

void main() => runApp(const StudifyApp());

class StudifyApp extends StatefulWidget {
  const StudifyApp({super.key});

  @override
  State<StudifyApp> createState() => _StudifyAppState();
}

class _StudifyAppState extends State<StudifyApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5CE2),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        fontFamily: 'Arial',
        textTheme: _buildTextTheme(Brightness.light),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        iconButtonTheme: _iconButtonTheme,
        pageTransitionsTheme: _smoothPageTransitions,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B8CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF15151F),
        fontFamily: 'Arial',
        textTheme: _buildTextTheme(Brightness.dark),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        iconButtonTheme: _iconButtonTheme,
        pageTransitionsTheme: _smoothPageTransitions,
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOutCubic,
      home: DashboardScreen(
        darkMode: _darkMode,
        onDarkModeChanged: (value) => setState(() => _darkMode = value),
      ),
    );
  }

  static const _smoothPageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _SmoothPageTransitionsBuilder(),
      TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
      TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
      TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
      TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
    },
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    ).textTheme.apply(fontFamily: 'Arial');

    TextStyle? withWeight(TextStyle? style, FontWeight weight) =>
        style?.copyWith(fontWeight: weight);

    return base.copyWith(
      displayLarge: withWeight(base.displayLarge, FontWeight.w800),
      displayMedium: withWeight(base.displayMedium, FontWeight.w800),
      displaySmall: withWeight(base.displaySmall, FontWeight.w800),
      headlineLarge: withWeight(base.headlineLarge, FontWeight.w800),
      headlineMedium: withWeight(base.headlineMedium, FontWeight.w800),
      headlineSmall: withWeight(base.headlineSmall, FontWeight.w800),
      titleLarge: withWeight(base.titleLarge, FontWeight.w800),
      titleMedium: withWeight(base.titleMedium, FontWeight.w700),
      titleSmall: withWeight(base.titleSmall, FontWeight.w700),
      bodyLarge: withWeight(base.bodyLarge, FontWeight.w600),
      bodyMedium: withWeight(base.bodyMedium, FontWeight.w600),
      bodySmall: withWeight(base.bodySmall, FontWeight.w600),
      labelLarge: withWeight(base.labelLarge, FontWeight.w700),
      labelMedium: withWeight(base.labelMedium, FontWeight.w700),
      labelSmall: withWeight(base.labelSmall, FontWeight.w700),
    );
  }

  static final _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      animationDuration: const Duration(milliseconds: 180),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.pressed)
            ? Colors.white.withOpacity(.14)
            : null,
      ),
    ),
  );

  static const _outlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      animationDuration: Duration(milliseconds: 180),
    ),
  );

  static const _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      animationDuration: Duration(milliseconds: 180),
    ),
  );

  static const _iconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      animationDuration: Duration(milliseconds: 180),
    ),
  );
}

class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0.015),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}
