import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/theme.dart';
import 'screens/welcome_screen.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  final progressService = ProgressService();
  await progressService.init();

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<ProgressService>.value(
            value: progressService),
      ],
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ShadTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
