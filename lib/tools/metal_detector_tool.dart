import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

import '../l10n/strings.dart';

/// Detector de metal: usa o magnetômetro. O campo normal da Terra fica em
/// ~25–65 µT; metal por perto eleva a leitura. Vibra quando passa do limiar.
class MetalDetectorTool extends StatefulWidget {
  const MetalDetectorTool({super.key});
  @override
  State<MetalDetectorTool> createState() => _MetalDetectorToolState();
}

class _MetalDetectorToolState extends State<MetalDetectorTool> {
  StreamSubscription? _sub;
  double _uT = 0;
  double _baseline = 45;
  DateTime _lastBuzz = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _sub = magnetometerEventStream().listen((e) {
      final m = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (!mounted) return;
      setState(() => _uT = _uT * 0.7 + m * 0.3);
      if (_uT > _baseline * 1.6 &&
          DateTime.now().difference(_lastBuzz).inMilliseconds > 600) {
        _lastBuzz = DateTime.now();
        Vibration.hasVibrator().then((h) {
          if (h == true) Vibration.vibrate(duration: 120);
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
    final ratio = (_uT / (_baseline * 2)).clamp(0.0, 1.0);
    final near = _uT > _baseline * 1.6;
    final color = Color.lerp(Colors.green, Colors.red, ratio)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.metalDetector),
        actions: [
          TextButton(
            onPressed: () => setState(() => _baseline = _uT.clamp(20, 80)),
            child: Text(t.calibrate.split('.').first,
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 16,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_uT.toStringAsFixed(0),
                          style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: color)),
                      const Text('µT',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AnimatedOpacity(
              opacity: near ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Text(t.metalNear,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.red)),
            ),
            const SizedBox(height: 8),
            Text('${t.magneticField}: ${_uT.toStringAsFixed(1)} µT',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
