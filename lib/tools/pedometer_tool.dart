import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import 'perm_gate.dart';

/// Podômetro: conta os passos desde que a tela foi aberta (sensor do SO).
class PedometerTool extends StatelessWidget {
  const PedometerTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.pedometer)),
      body: PermissionGate(
        permission: Permission.activityRecognition,
        rationale: t.needActivity,
        icon: Icons.directions_walk_rounded,
        child: const _StepView(),
      ),
    );
  }
}

class _StepView extends StatefulWidget {
  const _StepView();
  @override
  State<_StepView> createState() => _StepViewState();
}

class _StepViewState extends State<_StepView> {
  StreamSubscription<StepCount>? _sub;
  int? _base;
  int _steps = 0;
  final int _goal = 6000;

  @override
  void initState() {
    super.initState();
    _sub = Pedometer.stepCountStream.listen((e) {
      _base ??= e.steps;
      if (mounted) setState(() => _steps = (e.steps - _base!).clamp(0, 1 << 30));
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final pct = (_steps / _goal).clamp(0.0, 1.0);
    final km = _steps * 0.000762; // ~0.762 m por passo
    final kcal = _steps * 0.04;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 14,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF38EF7D)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_steps',
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.w900)),
                    Text(t.steps,
                        style: const TextStyle(color: Colors.grey)),
                    Text('${t.goal}: $_goal',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stat('${km.toStringAsFixed(2)} km', Icons.straighten_rounded),
              const SizedBox(width: 16),
              _stat('${kcal.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, IconData i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.gradient(kToolGradients[0]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(i, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(v,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
