import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Calculadora de gorjeta: conta + % de gorjeta + divisão por pessoas.
class TipCalculatorTool extends StatefulWidget {
  const TipCalculatorTool({super.key});
  @override
  State<TipCalculatorTool> createState() => _TipCalculatorToolState();
}

class _TipCalculatorToolState extends State<TipCalculatorTool> {
  double _bill = 0;
  double _tipPct = 10;
  int _people = 1;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final tip = _bill * _tipPct / 100;
    final total = _bill + tip;
    final perPerson = total / _people;
    return Scaffold(
      appBar: AppBar(title: Text(t.tipCalculator)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) =>
                setState(() => _bill = double.tryParse(v.replaceAll(',', '.')) ?? 0),
            decoration: InputDecoration(
              labelText: t.bill,
              prefixIcon: const Icon(Icons.receipt_long_rounded),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${t.tip}: ${_tipPct.round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            min: 0,
            max: 30,
            divisions: 30,
            value: _tipPct,
            label: '${_tipPct.round()}%',
            onChanged: (v) => setState(() => _tipPct = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${t.people}: $_people',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton.filledTonal(
                onPressed:
                    _people > 1 ? () => setState(() => _people--) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => setState(() => _people++),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.gradient(kToolGradients[7]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                _line(t.tip, tip),
                const Divider(color: Colors.white24, height: 22),
                _line(t.total, total, big: true),
                const SizedBox(height: 10),
                _line(t.perPerson, perPerson),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, double v, {bool big = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: TextStyle(
                  color: Colors.white70, fontSize: big ? 18 : 15)),
          Text(v.toStringAsFixed(2),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: big ? 30 : 18,
                  fontWeight: FontWeight.w900)),
        ],
      );
}
