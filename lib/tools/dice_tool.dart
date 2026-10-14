import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Dado e moeda: sorteio rápido (números e cara/coroa).
class DiceTool extends StatefulWidget {
  const DiceTool({super.key});
  @override
  State<DiceTool> createState() => _DiceToolState();
}

class _DiceToolState extends State<DiceTool> {
  final _rnd = Random();
  int _dice = 1;
  bool _heads = true;

  void _roll() {
    HapticFeedback.mediumImpact();
    setState(() => _dice = _rnd.nextInt(6) + 1);
  }

  void _flip() {
    HapticFeedback.mediumImpact();
    setState(() => _heads = _rnd.nextBool());
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.dice)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Dado
          GestureDetector(
            onTap: _roll,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient(kToolGradients[1]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text('$_dice',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 110,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _roll,
            icon: const Icon(Icons.casino_rounded),
            label: Text(t.roll),
          ),
          const SizedBox(height: 28),
          // Moeda
          GestureDetector(
            onTap: _flip,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient(kToolGradients[2]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(_heads ? t.heads : t.tails,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: _flip,
            icon: const Icon(Icons.monetization_on_rounded),
            label: Text(t.flip),
          ),
        ],
      ),
    );
  }
}
