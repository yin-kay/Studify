import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subject_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/subject_repository.dart';
import 'repositories/task_repository.dart';
import 'screens/dashboard_screen.dart';
import 'services/hive_service.dart';
import 'services/subject_service.dart';
import 'services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hive = HiveService();
  await hive.initialize();
  final taskRepository = TaskRepository(TaskService(hive));
  final taskProvider = TaskProvider(taskRepository);
  final subjectProvider = SubjectProvider(
    SubjectRepository(SubjectService(hive), TaskService(hive)),
    onSubjectsChanged: taskProvider.loadTasks,
  );
  final themeProvider = ThemeProvider(hive);
  await Future.wait([
    taskProvider.loadTasks(),
    subjectProvider.loadSubjects(),
    themeProvider.load()
  ]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: taskProvider),
    ChangeNotifierProvider.value(value: subjectProvider),
    ChangeNotifierProvider.value(value: themeProvider),
  ], child: const StudifyApp()));
}

class StudifyApp extends StatelessWidget {
  const StudifyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studify',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: theme.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      home: DashboardScreen(
          darkMode: theme.isDark, onDarkModeChanged: theme.setDarkMode),
    );
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: brightness == Brightness.light
                ? const Color(0xFF5B5CE2)
                : const Color(0xFF8B8CFF),
            brightness: brightness),
        scaffoldBackgroundColor: brightness == Brightness.light
            ? const Color(0xFFF7F7FC)
            : const Color(0xFF15151F),
        fontFamily: 'Arial',
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: _SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
          TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
        }),
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
      Widget child) {
    final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic);
    return FadeTransition(
        opacity: curved,
        child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(.025, .015), end: Offset.zero)
                    .animate(curved),
            child: child));
  }
}
