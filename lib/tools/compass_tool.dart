import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

class CompassTool extends StatefulWidget {
  const CompassTool({super.key});
  @override
  State<CompassTool> createState() => _CompassToolState();
}

class _CompassToolState extends State<CompassTool> {
  StreamSubscription? _sub;
  double _heading = 0; // graus, 0 = Norte

  @override
  void initState() {
    super.initState();
    _sub = magnetometerEventStream().listen((e) {
      // Direção pelo campo magnético no plano do aparelho.
      var deg = math.atan2(e.y, e.x) * 180 / math.pi;
      deg = (90 - deg) % 360;
      if (deg < 0) deg += 360;
      if (mounted) setState(() => _heading = deg);
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
      appBar: AppBar(title: Text(t.compass)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${_heading.round()}°',
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Center(
            child: Transform.rotate(
              angle: -_heading * math.pi / 180,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.gradient(kToolGradients[1]),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(t.pointNorth,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const Icon(Icons.navigation_rounded,
                        color: Colors.white, size: 80),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(t.calibrate,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
