import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Botón circular grande para disparar/entrar al balón (tecla "X" por
/// defecto en HaxBall). Usa `onTapDown`/`onTapUp` en vez de `onTap` para
/// poder enviar el keydown y el keyup por separado, tal como espera el
/// motor del juego.
class KickButton extends StatefulWidget {
  final double size;
  final double opacity;
  final VoidCallback onKickDown;
  final VoidCallback onKickUp;

  const KickButton({
    super.key,
    required this.onKickDown,
    required this.onKickUp,
    this.size = 96,
    this.opacity = 0.75,
  });

  @override
  State<KickButton> createState() => _KickButtonState();
}

class _KickButtonState extends State<KickButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          widget.onKickDown();
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onKickUp();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          widget.onKickUp();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.danger, Color(0xFFB3123A)],
              ),
              boxShadow: [
                AppTheme.neonGlow(color: AppTheme.danger, opacity: _pressed ? 0.75 : 0.4),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            ),
            child: const Center(
              child: Text(
                'KICK',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
