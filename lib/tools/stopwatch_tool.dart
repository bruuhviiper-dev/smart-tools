import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

class StopwatchTool extends StatefulWidget {
  const StopwatchTool({super.key});
  @override
  State<StopwatchTool> createState() => _StopwatchToolState();
}

class _StopwatchToolState extends State<StopwatchTool> {
  final _sw = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  void _toggle() {
    setState(() {
      if (_sw.isRunning) {
        _sw.stop();
        _timer?.cancel();
      } else {
        _sw.start();
        _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _sw.reset();
      _sw.stop();
      _timer?.cancel();
      _laps.clear();
    });
  }

  void _lap() => setState(() => _laps.insert(0, _sw.elapsed));

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$cs';
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
      appBar: AppBar(title: Text(t.stopwatch)),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text(_fmt(_sw.elapsed),
              style: const TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: _sw.isRunning ? _lap : _reset,
                  child: Text(_sw.isRunning ? t.lap : t.reset)),
              const SizedBox(width: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.brand),
                onPressed: _toggle,
                child: Text(_sw.isRunning ? t.stop : t.start),
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (c, i) => ListTile(
                dense: true,
                leading: Text('#${_laps.length - i}'),
                trailing: Text(_fmt(_laps[i]),
                    style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
