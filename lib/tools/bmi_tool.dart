import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Calculadora de IMC (índice de massa corporal).
class BmiTool extends StatefulWidget {
  const BmiTool({super.key});
  @override
  State<BmiTool> createState() => _BmiToolState();
}

class _BmiToolState extends State<BmiTool> {
  double _height = 170; // cm
  double _weight = 70; // kg

  double get _bmi {
    final h = _height / 100;
    return h == 0 ? 0 : _weight / (h * h);
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final bmi = _bmi;
    final (label, color) = switch (bmi) {
      < 18.5 => (t.bmiUnder, const Color(0xFF3B82F6)),
      < 25 => (t.bmiNormal, const Color(0xFF22C55E)),
      < 30 => (t.bmiOver, const Color(0xFFF59E0B)),
      _ => (t.bmiObese, const Color(0xFFEF4444)),
    };
    return Scaffold(
      appBar: AppBar(title: Text(t.bmiCalculator)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              gradient: AppTheme.gradient([color, color.withValues(alpha: 0.6)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(bmi.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w900)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const Text('IMC / BMI',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _slider('${t.height}: ${_height.round()} cm', _height, 120, 220,
              (v) => setState(() => _height = v)),
          _slider('${t.weight}: ${_weight.round()} kg', _weight, 30, 200,
              (v) => setState(() => _weight = v)),
        ],
      ),
    );
  }

  Widget _slider(String label, double v, double min, double max,
          ValueChanged<double> onCh) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(min: min, max: max, value: v, onChanged: onCh),
        ],
      );
}
