import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/avatar_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.load();

  final avatarProvider = AvatarProvider();
  await avatarProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: avatarProvider),
      ],
      child: const HaxBallUltraApp(),
    ),
  );
}

class HaxBallUltraApp extends StatelessWidget {
  const HaxBallUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HaxBall Ultra Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkViolet,
      home: const SplashScreen(),
    );
  }
}
