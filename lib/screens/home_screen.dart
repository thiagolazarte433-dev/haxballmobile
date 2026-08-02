import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'webview_screen.dart';
import 'favorites_screen.dart';

const String kHaxballBaseUrl = 'https://www.haxball.com/play';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Builder(
                builder: (ctx) => Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryButtonGradient,
                  boxShadow: [AppTheme.neonGlow(opacity: 0.55)],
                ),
                child: const Icon(Icons.sports_soccer, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'HaxBall Ultra Mobile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tu cliente premium de HaxBall',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WebViewScreen(initialUrl: kHaxballBaseUrl),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [AppTheme.neonGlow()],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          '▶  JUGAR RÁPIDO',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                ),
                icon: const Icon(Icons.star_rounded, color: AppTheme.accentPink),
                label: const Text('Ver salas favoritas', style: TextStyle(color: AppTheme.accentPink)),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
