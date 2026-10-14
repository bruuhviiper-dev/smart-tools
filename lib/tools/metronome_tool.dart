import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Metrônomo: batida regular com clique do sistema + vibração + visual.
class MetronomeTool extends StatefulWidget {
  const MetronomeTool({super.key});
  @override
  State<MetronomeTool> createState() => _MetronomeToolState();
}

class _MetronomeToolState extends State<MetronomeTool> {
  int _bpm = 100;
  bool _on = false;
  bool _flash = false;
  Timer? _timer;

  void _toggle() {
    if (_on) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(
        Duration(milliseconds: (60000 / _bpm).round()), (_) => _tick());
    setState(() => _on = true);
    _tick();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _on = false;
      _flash = false;
    });
  }

  void _tick() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
    setState(() => _flash = true);
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) setState(() => _flash = false);
    });
  }

  void _setBpm(int v) {
    _bpm = v.clamp(30, 240);
    if (_on) _start(); // reinicia no novo tempo
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.metronome)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.gradient(_flash
                    ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                    : kToolGradients[9]),
                boxShadow: _flash
                    ? const [
                        BoxShadow(
                            color: Color(0x6638EF7D),
                            blurRadius: 40,
                            spreadRadius: 6)
                      ]
                    : null,
              ),
              child: Center(
                child: Text('$_bpm',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900)),
              ),
            ),
            const Text('BPM', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                    onPressed: () => _setBpm(_bpm - 1),
                    icon: const Icon(Icons.remove_rounded)),
                SizedBox(
                  width: 200,
                  child: Slider(
                    min: 30,
                    max: 240,
                    value: _bpm.toDouble(),
                    onChanged: (v) => _setBpm(v.round()),
                  ),
                ),
                IconButton.filledTonal(
                    onPressed: () => _setBpm(_bpm + 1),
                    icon: const Icon(Icons.add_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_on ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(_on ? t.stop : t.start),
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
