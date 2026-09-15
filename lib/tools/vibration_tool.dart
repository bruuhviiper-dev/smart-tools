import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../l10n/strings.dart';

/// Vibrômetro / mini sismógrafo: mede a aceleração além da gravidade e
/// desenha um gráfico rolante. Bom para ver tremores/estabilidade.
class VibrationTool extends StatefulWidget {
  const VibrationTool({super.key});
  @override
  State<VibrationTool> createState() => _VibrationToolState();
}

class _VibrationToolState extends State<VibrationTool> {
  StreamSubscription? _sub;
  final List<double> _samples = List.filled(120, 0);
  double _now = 0, _max = 0;

  @override
  void initState() {
    super.initState();
    _sub = userAccelerometerEventStream().listen((e) {
      final m = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (!mounted) return;
      setState(() {
        _now = m;
        if (m > _max) _max = m;
        _samples.removeAt(0);
        _samples.add(m);
      });
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
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.vibration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _max = 0),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(_now.toStringAsFixed(2),
              style: TextStyle(
                  fontSize: 72, fontWeight: FontWeight.w900, color: c.primary)),
          const Text('m/s²', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('${t.max}: ${_max.toStringAsFixed(2)} m/s²',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                painter: _WavePainter(_samples, c.primary),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.data, this.color);
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = (data.reduce(math.max)).clamp(2.0, double.infinity);
    final grid = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), grid);

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - (data[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => true;
}
