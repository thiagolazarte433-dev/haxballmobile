import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

/// Mide periódicamente la latencia hacia haxball.com mediante una petición
/// HTTP ligera y muestra un chip de color según la calidad de la conexión.
class PingIndicator extends StatefulWidget {
  const PingIndicator({super.key});

  @override
  State<PingIndicator> createState() => _PingIndicatorState();
}

class _PingIndicatorState extends State<PingIndicator> {
  int? _pingMs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _measure();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _measure());
  }

  Future<void> _measure() async {
    final stopwatch = Stopwatch()..start();
    try {
      await http
          .head(Uri.parse('https://www.haxball.com/'))
          .timeout(const Duration(seconds: 3));
      stopwatch.stop();
      if (mounted) setState(() => _pingMs = stopwatch.elapsedMilliseconds);
    } catch (_) {
      stopwatch.stop();
      if (mounted) setState(() => _pingMs = null);
    }
  }

  Color _colorFor(int? ping) {
    if (ping == null) return AppTheme.danger;
    if (ping < 80) return AppTheme.success;
    if (ping < 160) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(_pingMs);
    final label = _pingMs == null ? 'Sin señal' : '${_pingMs}ms';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
