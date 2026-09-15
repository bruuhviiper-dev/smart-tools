import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

class LevelTool extends StatefulWidget {
  const LevelTool({super.key});
  @override
  State<LevelTool> createState() => _LevelToolState();
}

class _LevelToolState extends State<LevelTool> {
  StreamSubscription? _sub;
  double _x = 0, _y = 0; // -10..10 (m/s²)

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((e) {
      if (mounted) {
        setState(() {
          _x = _x * 0.8 + e.x * 0.2; // suaviza
          _y = _y * 0.8 + e.y * 0.2;
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
    final level = _x.abs() < 0.4 && _y.abs() < 0.4;
    return Scaffold(
      appBar: AppBar(title: Text(t.level)),
      body: Center(
        child: LayoutBuilder(builder: (c, box) {
          final r = 130.0;
          final dx = (-_x / 10 * r).clamp(-r + 22, r - 22);
          final dy = (_y / 10 * r).clamp(-r + 22, r - 22);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${(_x * 4).abs().round()}° / ${(_y * 4).abs().round()}°',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: level ? const Color(0xFF38EF7D) : Colors.grey,
                      width: 4),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400))),
                    Transform.translate(
                      offset: Offset(dx, dy),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.gradient(level
                              ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                              : kToolGradients[3]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
