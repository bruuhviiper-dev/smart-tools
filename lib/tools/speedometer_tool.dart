import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../data/units.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import 'perm_gate.dart';

/// Velocímetro por GPS. Mostra velocidade na unidade da região (km/h × mph).
class SpeedometerTool extends StatelessWidget {
  const SpeedometerTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.speedometer)),
      body: PermissionGate(
        permission: Permission.locationWhenInUse,
        rationale: t.needLocation,
        icon: Icons.location_on_rounded,
        child: const _SpeedView(),
      ),
    );
  }
}

class _SpeedView extends StatefulWidget {
  const _SpeedView();
  @override
  State<_SpeedView> createState() => _SpeedViewState();
}

class _SpeedViewState extends State<_SpeedView> {
  StreamSubscription<Position>? _sub;
  double _kmh = 0, _max = 0;
  bool _got = false;

  @override
  void initState() {
    super.initState();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 0),
    ).listen((p) {
      final kmh = (p.speed.isFinite && p.speed > 0 ? p.speed : 0) * 3.6;
      if (!mounted) return;
      setState(() {
        _got = true;
        _kmh = kmh;
        if (kmh > _max) _max = kmh;
      });
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
    final sys = context.watch<AppState>().system;
    final unit = Units.speedUnit(sys);
    final disp = Units.kmhTo(sys, _kmh);
    final dispMax = Units.kmhTo(sys, _max);
    if (!_got) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.waitingGps),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(disp.toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: Theme.of(context).colorScheme.primary)),
          Text(unit,
              style: const TextStyle(fontSize: 24, color: Colors.grey)),
          const SizedBox(height: 30),
          Text('${t.max}: ${dispMax.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
