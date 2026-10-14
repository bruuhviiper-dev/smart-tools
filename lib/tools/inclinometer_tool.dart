import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Clinômetro / inclinômetro: mede o ângulo de inclinação de uma superfície.
class InclinometerTool extends StatefulWidget {
  const InclinometerTool({super.key});
  @override
  State<InclinometerTool> createState() => _InclinometerToolState();
}

class _InclinometerToolState extends State<InclinometerTool> {
  StreamSubscription? _sub;
  double _pitch = 0, _roll = 0;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((e) {
      final pitch = atan2(e.y, sqrt(e.x * e.x + e.z * e.z)) * 180 / pi;
      final roll = atan2(e.x, sqrt(e.y * e.y + e.z * e.z)) * 180 / pi;
      if (mounted) {
        setState(() {
          _pitch = _pitch * 0.82 + pitch * 0.18;
          _roll = _roll * 0.82 + roll * 0.18;
        });
      }
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
    return Scaffold(
      appBar: AppBar(title: Text(t.inclinometer)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -_roll * pi / 180,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade500, width: 3),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 260, height: 3, color: Colors.grey.shade400),
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradient(kToolGradients[3]),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      child: Text('${_roll.abs().toStringAsFixed(1)}°',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box('${t.angle} X', '${_roll.abs().toStringAsFixed(1)}°'),
                const SizedBox(width: 16),
                _box('${t.angle} Y', '${_pitch.abs().toStringAsFixed(1)}°'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(String k, String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(k, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(v,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
