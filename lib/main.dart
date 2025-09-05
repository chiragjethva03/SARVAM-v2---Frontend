import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'views/OnbordingScreen.dart';

// Global RouteObserver
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Provider<UserProvider> is now ABOVE MyApp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.hydrateFromPrefs(context); // safe: provider available
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'Sarvam',
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
