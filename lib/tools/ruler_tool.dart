import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../services/app_state.dart';

/// Régua na tela. Mostra cm (métrico) ou polegadas (imperial) conforme a região.
class RulerTool extends StatelessWidget {
  const RulerTool({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final imperial = context.watch<AppState>().isImperial;
    // 160 px lógicos = 1 polegada = 25.4 mm.
    final pxPerMm = 160 / 25.4;
    return Scaffold(
      appBar: AppBar(title: Text(t.ruler)),
      body: CustomPaint(
        painter: _RulerPainter(
            pxPerMm, imperial, Theme.of(context).colorScheme.onSurface),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter(this.pxPerMm, this.imperial, this.color);
  final double pxPerMm;
  final bool imperial;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4;

    void label(String s, double y) {
      final tp = TextPainter(
        text: TextSpan(
            text: s,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(38, y - 8));
    }

    if (imperial) {
      // Marcas a cada 1/16 de polegada.
      final step = 160 / 16.0; // px por 1/16"
      var i = 0;
      for (double y = 20; y < size.height - 10; y += step, i++) {
        double len;
        if (i % 16 == 0) {
          len = 62;
          label('${i ~/ 16}', y);
        } else if (i % 8 == 0) {
          len = 44;
        } else if (i % 4 == 0) {
          len = 32;
        } else {
          len = 20;
        }
        canvas.drawLine(Offset(0, y), Offset(len, y), p);
      }
      _unit(canvas, 'in');
    } else {
      var mm = 0;
      for (double y = 20; y < size.height - 10; y += pxPerMm, mm++) {
        double len;
        if (mm % 10 == 0) {
          len = 60;
          label('${mm ~/ 10}', y);
        } else if (mm % 5 == 0) {
          len = 40;
        } else {
          len = 22;
        }
        canvas.drawLine(Offset(0, y), Offset(len, y), p);
      }
      _unit(canvas, 'cm');
    }
  }

  void _unit(Canvas canvas, String u) {
    final lbl = TextPainter(
      text: TextSpan(
          text: u,
          style:
              TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    lbl.paint(canvas, const Offset(38, 2));
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) => old.imperial != imperial;
}
