import 'package:code/features/auth/login_page.dart';
import 'package:code/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/alerts/pages/alerts_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const SOCApp(),
    ),
  );
}

class SOCApp extends StatelessWidget {
  const SOCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Agentic SOC AI',
          theme: AppTheme.lightTheme,
          // darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: LoginPage(),
        );
      },
    );
  }
}
