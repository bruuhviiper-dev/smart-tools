import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Relógio mundial: hora atual em várias cidades (offsets UTC fixos).
class WorldClockTool extends StatefulWidget {
  const WorldClockTool({super.key});
  @override
  State<WorldClockTool> createState() => _WorldClockToolState();
}

class _City {
  const _City(this.name, this.offset);
  final String name;
  final double offset; // horas de UTC
}

class _WorldClockToolState extends State<WorldClockTool> {
  Timer? _timer;

  static const _cities = [
    _City('São Paulo', -3),
    _City('New York', -5),
    _City('Los Angeles', -8),
    _City('London', 0),
    _City('Lisboa', 0),
    _City('Madrid', 1),
    _City('Luanda', 1),
    _City('Maputo', 2),
    _City('Makkah', 3),
    _City('Dubai', 4),
    _City('Mumbai', 5.5),
    _City('Beijing', 8),
    _City('Tokyo', 9),
    _City('Sydney', 10),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final utc = DateTime.now().toUtc();
    return Scaffold(
      appBar: AppBar(title: Text(t.worldClock)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _cities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (c, i) {
          final city = _cities[i];
          final local =
              utc.add(Duration(minutes: (city.offset * 60).round()));
          final off = city.offset >= 0 ? '+${city.offset}' : '${city.offset}';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient(
                        kToolGradients[i % kToolGradients.length]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.public_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(city.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('UTC $off',
                          style: const TextStyle(
                              fontSize: 12.5, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(_fmt(local),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          );
        },
      ),
    );
  }
}
