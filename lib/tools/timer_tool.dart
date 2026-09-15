import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../l10n/strings.dart';

/// Contagem regressiva com presets e vibração ao terminar.
class TimerTool extends StatefulWidget {
  const TimerTool({super.key});
  @override
  State<TimerTool> createState() => _TimerToolState();
}

class _TimerToolState extends State<TimerTool> {
  Timer? _tick;
  int _totalMs = 5 * 60 * 1000;
  int _leftMs = 5 * 60 * 1000;
  bool _running = false, _done = false;

  void _setPreset(int seconds) {
    _tick?.cancel();
    setState(() {
      _totalMs = seconds * 1000;
      _leftMs = _totalMs;
      _running = false;
      _done = false;
    });
  }

  void _toggle() {
    if (_running) {
      _tick?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_leftMs <= 0) return;
    setState(() {
      _running = true;
      _done = false;
    });
    final start = DateTime.now();
    final from = _leftMs;
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final left = from - elapsed;
      if (left <= 0) {
        _tick?.cancel();
        setState(() {
          _leftMs = 0;
          _running = false;
          _done = true;
        });
        Vibration.hasVibrator().then((h) {
          if (h == true) Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 400]);
        });
      } else {
        setState(() => _leftMs = left);
      }
    });
  }

  void _reset() {
    _tick?.cancel();
    setState(() {
      _leftMs = _totalMs;
      _running = false;
      _done = false;
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String get _display {
    final s = (_leftMs / 1000).ceil();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final progress = _totalMs == 0 ? 0.0 : _leftMs / _totalMs;
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.timer)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: c.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                          _done ? Colors.red : c.primary),
                    ),
                  ),
                  Text(_done ? t.timesUp : _display,
                      style: TextStyle(
                          fontSize: _done ? 26 : 52,
                          fontWeight: FontWeight.w900,
                          color: _done ? Colors.red : null)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                for (final p in [60, 300, 600, 1800])
                  ActionChip(
                    label: Text(p < 60 ? '${p}s' : '${p ~/ 60}m'),
                    onPressed: () => _setPreset(p),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _toggle,
                  icon: Icon(_running
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(_running ? t.pause : t.start),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(t.reset),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
