import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

class CalculatorTool extends StatefulWidget {
  const CalculatorTool({super.key});
  @override
  State<CalculatorTool> createState() => _CalculatorToolState();
}

class _CalculatorToolState extends State<CalculatorTool> {
  String _expr = '';
  String _result = '';

  void _tap(String k) {
    setState(() {
      if (k == 'C') {
        _expr = '';
        _result = '';
      } else if (k == '⌫') {
        if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1);
      } else if (k == '=') {
        _result = _eval(_expr);
      } else {
        _expr += k;
        _result = _eval(_expr);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    const keys = [
      'C', '(', ')', '⌫',
      '7', '8', '9', '÷',
      '4', '5', '6', '×',
      '1', '2', '3', '−',
      '0', '.', '=', '+',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.calculator)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_expr,
                      style: const TextStyle(fontSize: 30),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(_result,
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.3,
            children: [
              for (final k in keys) _key(k),
            ],
          ),
        ],
      ),
    );
  }

  Widget _key(String k) {
    final op = '÷×−+=()'.contains(k);
    final clear = k == 'C' || k == '⌫';
    return Material(
      color: k == '='
          ? null
          : clear
              ? Colors.red.withValues(alpha: 0.12)
              : op
                  ? AppTheme.brand.withValues(alpha: 0.12)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: k == '='
            ? BoxDecoration(
                gradient: AppTheme.gradient(AppTheme.hero),
                borderRadius: BorderRadius.circular(16))
            : null,
        child: InkWell(
          onTap: () => _tap(k),
          child: Center(
            child: Text(k,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: k == '=' ? Colors.white : null)),
          ),
        ),
      ),
    );
  }
}

// ---- avaliador simples (+ - × ÷ % parênteses) ----
String _eval(String s) {
  if (s.trim().isEmpty) return '';
  try {
    final expr = s.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');
    final v = _Parser(expr).parse();
    if (v.isNaN || v.isInfinite) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  } catch (_) {
    return '';
  }
}

class _Parser {
  _Parser(this.s);
  final String s;
  int _i = 0;

  double parse() {
    final v = _expr();
    return v;
  }

  double _expr() {
    var v = _term();
    while (_i < s.length && (s[_i] == '+' || s[_i] == '-')) {
      final op = s[_i++];
      final t = _term();
      v = op == '+' ? v + t : v - t;
    }
    return v;
  }

  double _term() {
    var v = _factor();
    while (_i < s.length && (s[_i] == '*' || s[_i] == '/' || s[_i] == '%')) {
      final op = s[_i++];
      final f = _factor();
      v = op == '*' ? v * f : (op == '/' ? v / f : v % f);
    }
    return v;
  }

  double _factor() {
    if (_i < s.length && s[_i] == '(') {
      _i++;
      final v = _expr();
      if (_i < s.length && s[_i] == ')') _i++;
      return v;
    }
    if (_i < s.length && s[_i] == '-') {
      _i++;
      return -_factor();
    }
    final start = _i;
    while (_i < s.length && (RegExp(r'[0-9.]').hasMatch(s[_i]))) {
      _i++;
    }
    return double.parse(s.substring(start, _i));
  }
}
