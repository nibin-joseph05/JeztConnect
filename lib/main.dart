import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'components/splash_screen.dart';

void main() {
  runApp(const JeztConnectApp());
}

class JeztConnectApp extends StatelessWidget {
  const JeztConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeztConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final accessToken = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => DashboardPage(
              accessToken: accessToken ?? '',
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => settings.name == '/login'
              ? const LoginPage()
              : const SplashScreen(),
        );
      },
    );
  }
}