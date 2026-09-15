import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../l10n/strings.dart';

class ProtractorTool extends StatefulWidget {
  const ProtractorTool({super.key});
  @override
  State<ProtractorTool> createState() => _ProtractorToolState();
}

class _ProtractorToolState extends State<ProtractorTool> {
  StreamSubscription? _sub;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((e) {
      // Inclinação do aparelho em relação à vertical.
      final a = math.atan2(e.x, e.y) * 180 / math.pi;
      if (mounted) setState(() => _angle = _angle * 0.8 + a * 0.2);
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
    final deg = _angle.abs().round();
    return Scaffold(
      appBar: AppBar(title: Text(t.protractor)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$deg°',
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Transform.rotate(
              angle: _angle * math.pi / 180,
              child: Container(
                width: 220,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(t.protractor,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
