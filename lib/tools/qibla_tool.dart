import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../l10n/strings.dart';
import 'perm_gate.dart';

/// Qibla: aponta a direção de Meca (Kaaba) a partir da sua localização.
class QiblaTool extends StatelessWidget {
  const QiblaTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.qibla)),
      body: PermissionGate(
        permission: Permission.locationWhenInUse,
        rationale: t.needLocation,
        icon: Icons.location_on_rounded,
        child: const _QiblaView(),
      ),
    );
  }
}

class _QiblaView extends StatefulWidget {
  const _QiblaView();
  @override
  State<_QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<_QiblaView> {
  static const _kaabaLat = 21.4225, _kaabaLng = 39.8262;

  StreamSubscription? _magSub;
  double _heading = 0;
  double? _qiblaBearing;

  @override
  void initState() {
    super.initState();
    _magSub = magnetometerEventStream().listen((e) {
      var deg = math.atan2(e.y, e.x) * 180 / math.pi;
      deg = (90 - deg) % 360;
      if (deg < 0) deg += 360;
      if (mounted) setState(() => _heading = deg);
    });
    _locate();
  }

  Future<void> _locate() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.low));
      final b = _bearing(pos.latitude, pos.longitude, _kaabaLat, _kaabaLng);
      if (mounted) setState(() => _qiblaBearing = b);
    } catch (_) {}
  }

  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final p1 = lat1 * math.pi / 180;
    final p2 = lat2 * math.pi / 180;
    final dl = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dl) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) -
        math.sin(p1) * math.cos(p2) * math.cos(dl);
    var deg = math.atan2(y, x) * 180 / math.pi;
    return (deg + 360) % 360;
  }

  @override
  void dispose() {
    _magSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    if (_qiblaBearing == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.findingLocation),
          ],
        ),
      );
    }
    // Ângulo da agulha da Qibla relativo a onde o telefone aponta.
    final rel = ((_qiblaBearing! - _heading) % 360) * math.pi / 180;
    final aligned = _angleDiff(_qiblaBearing!, _heading) < 8;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${_qiblaBearing!.round()}°',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: aligned ? Colors.green : Colors.grey, width: 4),
                ),
              ),
              Transform.rotate(
                angle: rel,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation_rounded,
                        size: 90,
                        color: aligned ? Colors.green : const Color(0xFF5B4BF5)),
                    const Text('🕋', style: TextStyle(fontSize: 30)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(t.qiblaHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  double _angleDiff(double a, double b) {
    var d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }
}
