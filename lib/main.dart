import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Load token & role dari storage
  await AuthProvider.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Kalau sudah login langsung ke MainScreen
      home: AuthProvider.isLoggedIn
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}