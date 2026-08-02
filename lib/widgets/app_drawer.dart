import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/avatar_picker_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryButtonGradient,
                      boxShadow: [AppTheme.neonGlow()],
                    ),
                    child: const Icon(Icons.sports_soccer, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'HaxBall Ultra',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              onTap: () => _navigate(context, const HomeScreen()),
            ),
            _DrawerItem(
              icon: Icons.star_rounded,
              label: 'Salas Favoritas',
              onTap: () => _navigate(context, const FavoritesScreen()),
            ),
            _DrawerItem(
              icon: Icons.face_retouching_natural_rounded,
              label: 'Cambiar Avatar',
              onTap: () => _navigate(context, const AvatarPickerScreen()),
            ),
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: 'Ajustes',
              onTap: () => _navigate(context, const SettingsScreen()),
            ),
            const Spacer(),
            const Divider(color: AppTheme.surfaceVariant),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Salir',
              color: AppTheme.danger,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.accentPink),
      title: Text(
        label,
        style: TextStyle(color: color ?? AppTheme.textPrimary, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
