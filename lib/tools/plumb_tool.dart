import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Prumo / fio de prumo: mostra o quanto uma superfície está fora da vertical.
class PlumbTool extends StatefulWidget {
  const PlumbTool({super.key});
  @override
  State<PlumbTool> createState() => _PlumbToolState();
}

class _PlumbToolState extends State<PlumbTool> {
  StreamSubscription? _sub;
  double _angle = 0; // graus de desvio da vertical

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((e) {
      // Ângulo do aparelho em relação à vertical (0° = em pé, perfeitamente vertical).
      final a = atan2(e.x, e.y) * 180 / pi;
      if (mounted) setState(() => _angle = _angle * 0.82 + a * 0.18);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final plumb = _angle.abs() < 1.0;
    return Scaffold(
      appBar: AppBar(title: Text(t.plumb)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_angle.abs().toStringAsFixed(1)}°',
                style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: plumb ? const Color(0xFF11998E) : null)),
            Text(plumb ? t.vertical : t.tilted,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              height: 320,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // referência vertical
                  Container(width: 2, height: 320, color: Colors.grey.shade400),
                  // fio de prumo que inclina
                  Transform.rotate(
                    angle: _angle * pi / 180,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                            width: 4,
                            height: 260,
                            decoration: BoxDecoration(
                              gradient: AppTheme.gradient(plumb
                                  ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                                  : kToolGradients[1]),
                            )),
                        Container(
                          width: 36,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradient(plumb
                                ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                                : kToolGradients[1]),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                                bottom: Radius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
