import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/units.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';

class ConverterTool extends StatefulWidget {
  const ConverterTool({super.key});
  @override
  State<ConverterTool> createState() => _ConverterToolState();
}

/// Unidades por categoria: fator para a unidade base (exceto temperatura).
const _cats = <String, Map<String, double>>{
  'Length': {'m': 1, 'km': 1000, 'cm': 0.01, 'mm': 0.001, 'mi': 1609.34, 'ft': 0.3048, 'in': 0.0254, 'yd': 0.9144},
  'Weight': {'kg': 1, 'g': 0.001, 'mg': 1e-6, 'lb': 0.453592, 'oz': 0.0283495, 't': 1000, 'st': 6.35029},
  'Temperature': {'°C': 1, '°F': 1, 'K': 1},
  'Area': {'m²': 1, 'km²': 1e6, 'cm²': 1e-4, 'ft²': 0.092903, 'ac': 4046.86, 'ha': 10000},
  'Volume': {'L': 1, 'mL': 0.001, 'm³': 1000, 'gal': 3.78541, 'qt': 0.946353, 'cup': 0.236588},
  'Speed': {'km/h': 1, 'm/s': 3.6, 'mph': 1.60934, 'kn': 1.852, 'ft/s': 1.09728},
  'Data': {'MB': 1, 'KB': 0.001, 'GB': 1000, 'TB': 1e6},
  'Time': {'s': 1, 'min': 60, 'h': 3600, 'd': 86400, 'ms': 0.001, 'wk': 604800},
};

class _ConverterToolState extends State<ConverterTool> {
  String _cat = 'Length';
  String _from = 'm';
  String _to = 'cm';
  final _c = TextEditingController(text: '1');
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _seeded = true;
      _applyDefaults(_cat);
    }
  }

  void _applyDefaults(String cat) {
    final sys = context.read<AppState>().system;
    final d = Units.converterDefaults(cat, sys);
    final units = _cats[cat]!.keys.toList();
    if (d.length == 2 && units.contains(d[0]) && units.contains(d[1])) {
      _from = d[0];
      _to = d[1];
    } else {
      _from = units.first;
      _to = units.elementAt(1);
    }
  }

  double _toBaseTemp(double v, String u) {
    switch (u) {
      case '°F': return (v - 32) * 5 / 9;
      case 'K': return v - 273.15;
      default: return v; // °C
    }
  }

  double _fromBaseTemp(double c, String u) {
    switch (u) {
      case '°F': return c * 9 / 5 + 32;
      case 'K': return c + 273.15;
      default: return c;
    }
  }

  String get _result {
    final v = double.tryParse(_c.text.replaceAll(',', '.')) ?? 0;
    double out;
    if (_cat == 'Temperature') {
      out = _fromBaseTemp(_toBaseTemp(v, _from), _to);
    } else {
      final units = _cats[_cat]!;
      out = v * units[_from]! / units[_to]!;
    }
    return out
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final units = _cats[_cat]!.keys.toList();
    return Scaffold(
      appBar: AppBar(title: Text(t.converter)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final c in _cats.keys)
                ChoiceChip(
                  label: Text(t.convCat(c)),
                  selected: _cat == c,
                  onSelected: (_) => setState(() {
                    _cat = c;
                    _applyDefaults(c);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _c,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          _dropdown(units, _from, (v) => setState(() => _from = v!)),
          const Center(child: Icon(Icons.swap_vert_rounded, size: 30)),
          _dropdown(units, _to, (v) => setState(() => _to = v!)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$_result $_to',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(List<String> items, String value, ValueChanged<String?> f) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: [for (final u in items) DropdownMenuItem(value: u, child: Text(u))],
        onChanged: f,
      );
}
