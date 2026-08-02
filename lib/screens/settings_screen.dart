import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle('Rendimiento'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Límite de FPS', style: TextStyle(fontWeight: FontWeight.w600)),
                    Wrap(
                      spacing: 8,
                      children: [0, 30, 60, 120].map((fps) {
                        final selected = settings.fpsLimit == fps;
                        return ChoiceChip(
                          label: Text(fps == 0 ? 'Sin límite' : '$fps'),
                          selected: selected,
                          onSelected: (_) => settings.setFpsLimit(fps),
                          selectedColor: AppTheme.primary,
                        );
                      }).toList(),
                    ),
                    const Divider(height: 28),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Extrapolación rápida'),
                      subtitle: const Text(
                        'Suaviza el movimiento de los jugadores en conexiones inestables',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      value: settings.fastExtrapolation,
                      onChanged: settings.setFastExtrapolation,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Controles táctiles'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Opacidad: ${(settings.controlsOpacity * 100).round()}%'),
                    Slider(
                      value: settings.controlsOpacity,
                      min: 0.2,
                      max: 1.0,
                      onChanged: settings.setControlsOpacity,
                    ),
                    Text('Tamaño: ${(settings.controlsSize * 100).round()}%'),
                    Slider(
                      value: settings.controlsSize,
                      min: 0.7,
                      max: 1.5,
                      onChanged: settings.setControlsSize,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Joystick a la izquierda'),
                      subtitle: const Text(
                        'Desactívalo para zurdos (joystick a la derecha)',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      value: settings.joystickOnLeft,
                      onChanged: settings.setJoystickOnLeft,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Modo "No tocar pantalla"'),
                      subtitle: const Text(
                        'Bloquea temporalmente los toques para evitar acciones accidentales',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      value: settings.doNotTouchMode,
                      onChanged: settings.setDoNotTouchMode,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Soporte de gamepad Bluetooth'),
                      subtitle: const Text(
                        'Usa un mando conectado en lugar de los controles táctiles',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      value: settings.gamepadEnabled,
                      onChanged: settings.setGamepadEnabled,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle('Notificaciones'),
            Card(
              child: SwitchListTile(
                title: const Text('Notificaciones push'),
                subtitle: const Text(
                  'Avisos de invitaciones a salas o eventos (opcional)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                value: settings.notificationsEnabled,
                onChanged: settings.setNotificationsEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.neonCyan,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
