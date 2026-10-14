import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import 'perm_gate.dart';

/// Altímetro + coordenadas GPS (altitude, latitude, longitude, precisão).
class AltimeterTool extends StatelessWidget {
  const AltimeterTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.altimeter)),
      body: PermissionGate(
        permission: Permission.locationWhenInUse,
        rationale: t.needLocation,
        icon: Icons.terrain_rounded,
        child: const _AltView(),
      ),
    );
  }
}

class _AltView extends StatefulWidget {
  const _AltView();
  @override
  State<_AltView> createState() => _AltViewState();
}

class _AltViewState extends State<_AltView> {
  StreamSubscription<Position>? _sub;
  Position? _p;

  @override
  void initState() {
    super.initState();
    _sub = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((p) {
      if (mounted) setState(() => _p = p);
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
    final p = _p;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final m = p.altitude;
    final ft = m * 3.28084;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            gradient: AppTheme.gradient(kToolGradients[5]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(Icons.terrain_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text('${m.toStringAsFixed(0)} m',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900)),
              Text('${ft.toStringAsFixed(0)} ft',
                  style: const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 4),
              Text(t.altitude,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _row(t.latitude, p.latitude.toStringAsFixed(5)),
        _row(t.longitude, p.longitude.toStringAsFixed(5)),
        _row(t.accuracy, '±${p.accuracy.toStringAsFixed(0)} m'),
        _row(t.speed, '${(p.speed * 3.6).toStringAsFixed(1)} km/h'),
      ],
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text(v,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
