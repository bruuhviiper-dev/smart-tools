import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Calculadora de idade: escolha a data de nascimento → anos, meses e dias.
class AgeTool extends StatefulWidget {
  const AgeTool({super.key});
  @override
  State<AgeTool> createState() => _AgeToolState();
}

class _AgeToolState extends State<AgeTool> {
  DateTime? _birth;

  (int, int, int) _age(DateTime b, DateTime n) {
    var years = n.year - b.year;
    var months = n.month - b.month;
    var days = n.day - b.day;
    if (days < 0) {
      months--;
      days += DateTime(n.year, n.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return (years, months, days);
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(t.ageCalculator)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FilledButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _birth ?? DateTime(now.year - 20),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (d != null) setState(() => _birth = d);
            },
            icon: const Icon(Icons.cake_rounded),
            label: Text(_birth == null
                ? t.birthDate
                : '${_birth!.day}/${_birth!.month}/${_birth!.year}'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 24),
          if (_birth != null) ...[
            Builder(builder: (_) {
              final (y, m, d) = _age(_birth!, now);
              final totalDays = now.difference(_birth!).inDays;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient(kToolGradients[7]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _big('$y', t.years),
                        _big('$m', t.months),
                        _big('$d', t.days),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${t.total}: $totalDays ${t.days}',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey)),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _big(String v, String k) => Column(
        children: [
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900)),
          Text(k, style: const TextStyle(color: Colors.white70)),
        ],
      );
}
