import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Direcciones discretas que HaxBall entiende (flechas de teclado).
/// El joystick traduce el ángulo del arrastre táctil en una combinación
/// de estas direcciones (por ejemplo arriba+derecha para diagonal).
enum HbDirection { up, down, left, right }

/// Joystick virtual analógico que se dibuja en la parte inferior izquierda
/// de la pantalla. Al arrastrar, calcula qué flechas deben estar
/// "presionadas" y notifica los cambios mediante [onDirectionsChanged],
/// evitando reenviar eventos si el set de direcciones no cambió (para no
/// saturar la WebView con keydown/keyup repetidos).
class VirtualJoystick extends StatefulWidget {
  final double size;
  final double opacity;
  final ValueChanged<Set<HbDirection>> onDirectionsChanged;

  const VirtualJoystick({
    super.key,
    required this.onDirectionsChanged,
    this.size = 140,
    this.opacity = 0.75,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobOffset = Offset.zero;
  Set<HbDirection> _activeDirections = {};

  void _handleDrag(Offset localPosition, double radius) {
    final center = Offset(radius, radius);
    var delta = localPosition - center;
    final distance = delta.distance;
    if (distance > radius) {
      delta = Offset.fromDirection(delta.direction, radius);
    }

    setState(() => _knobOffset = delta);

    // Zona muerta central para evitar direcciones fantasma.
    const deadZone = 0.28;
    final normalized = delta.distance / radius;
    final Set<HbDirection> next = {};

    if (normalized > deadZone) {
      final angle = delta.direction; // radianes, 0 = derecha, sentido horario en Flutter
      final degrees = (angle * 180 / pi + 360) % 360;

      // Octantes: cada 45° para permitir diagonales naturales.
      if (degrees >= 292.5 || degrees < 22.5) next.add(HbDirection.right);
      if (degrees >= 22.5 && degrees < 67.5) next.add(HbDirection.right)..add(HbDirection.down);
      if (degrees >= 67.5 && degrees < 112.5) next.add(HbDirection.down);
      if (degrees >= 112.5 && degrees < 157.5) next.add(HbDirection.down)..add(HbDirection.left);
      if (degrees >= 157.5 && degrees < 202.5) next.add(HbDirection.left);
      if (degrees >= 202.5 && degrees < 247.5) next.add(HbDirection.left)..add(HbDirection.up);
      if (degrees >= 247.5 && degrees < 292.5) next.add(HbDirection.up);
      if (degrees >= 292.5 - 45 && degrees < 22.5 + 45 && degrees >= 337.5) {
        next.add(HbDirection.right)..add(HbDirection.up);
      }
    }

    if (!_setEquals(next, _activeDirections)) {
      _activeDirections = next;
      widget.onDirectionsChanged(next);
    }
  }

  void _resetJoystick() {
    setState(() => _knobOffset = Offset.zero);
    if (_activeDirections.isNotEmpty) {
      _activeDirections = {};
      widget.onDirectionsChanged({});
    }
  }

  bool _setEquals(Set<HbDirection> a, Set<HbDirection> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size / 2;
    final knobSize = widget.size * 0.42;

    return Opacity(
      opacity: widget.opacity,
      child: GestureDetector(
        onPanUpdate: (details) => _handleDrag(details.localPosition, radius),
        onPanEnd: (_) => _resetJoystick(),
        onPanCancel: _resetJoystick,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface.withOpacity(0.55),
            border: Border.all(color: AppTheme.primary.withOpacity(0.6), width: 2),
            boxShadow: [AppTheme.neonGlow(opacity: 0.35)],
          ),
          child: Center(
            child: Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryButtonGradient,
                  boxShadow: [AppTheme.neonGlow(color: AppTheme.neonCyan, opacity: 0.5)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
