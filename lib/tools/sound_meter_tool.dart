import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/strings.dart';
import '../screens/premium_screen.dart';
import '../services/app_state.dart';
import 'perm_gate.dart';

/// Medidor de som: mostra o nível em dB captado pelo microfone.
class SoundMeterTool extends StatelessWidget {
  const SoundMeterTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.soundMeter)),
      body: PermissionGate(
        permission: Permission.microphone,
        rationale: t.needMic,
        icon: Icons.mic_rounded,
        child: const _SoundView(),
      ),
    );
  }
}

class _SoundView extends StatefulWidget {
  const _SoundView();
  @override
  State<_SoundView> createState() => _SoundViewState();
}

class _SoundViewState extends State<_SoundView> {
  NoiseMeter? _meter;
  StreamSubscription<NoiseReading>? _sub;
  double _db = 0, _min = 999, _max = 0, _sum = 0;
  int _n = 0;
  final List<double> _bars = List.filled(40, 0);
  bool _recording = false;
  final List<MapEntry<DateTime, double>> _log = [];

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    try {
      _meter = NoiseMeter();
      _sub = _meter!.noise.listen((r) {
        final db = r.meanDecibel.isFinite ? r.meanDecibel : 0.0;
        if (!mounted) return;
        setState(() {
          _db = db.clamp(0, 140);
          _min = math.min(_min, _db);
          _max = math.max(_max, _db);
          _sum += _db;
          _n++;
          _bars.removeAt(0);
          _bars.add(_db);
          if (_recording) _log.add(MapEntry(DateTime.now(), _db));
        });
      }, onError: (_) {});
    } catch (_) {}
  }

  // Exportar CSV é um recurso Pro (valor real dentro do app).
  Future<void> _export() async {
    final s = context.read<AppState>();
    if (!s.isPro) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }
    if (_log.isEmpty) return;
    final buf = StringBuffer('time,decibels\n');
    for (final e in _log) {
      buf.writeln('${e.key.toIso8601String()},${e.value.toStringAsFixed(1)}');
    }
    try {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/sound_${DateTime.now().millisecondsSinceEpoch}.csv');
      await f.writeAsString(buf.toString());
      await SharePlus.instance
          .share(ShareParams(files: [XFile(f.path)], text: 'Sound Meter'));
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Color _color(double db) {
    if (db < 60) return Colors.green;
    if (db < 85) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final avg = _n == 0 ? 0.0 : _sum / _n;
    final c = _color(_db);
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(_db.toStringAsFixed(1),
            style: TextStyle(
                fontSize: 88, fontWeight: FontWeight.w900, color: c)),
        Text('dB · ${t.decibels}',
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_db / 140).clamp(0, 1),
              minHeight: 12,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat(t.min, _min == 999 ? 0 : _min),
            _stat(t.avg, avg.toDouble()),
            _stat(t.max, _max),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => setState(() => _recording = !_recording),
              icon: Icon(_recording
                  ? Icons.stop_circle_rounded
                  : Icons.fiber_manual_record_rounded,
                  color: _recording ? Colors.red : null),
              label: Text(_recording
                  ? '${t.recording} (${_log.length})'
                  : t.record),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _log.isEmpty ? null : _export,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(t.exportCsv),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in _bars)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: (b / 140 * 160).clamp(2, 160),
                      decoration: BoxDecoration(
                        color: _color(b),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, double v) => Column(
        children: [
          Text(v.toStringAsFixed(0),
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      );
}
