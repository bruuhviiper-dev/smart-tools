import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';

/// Contador manual / tasbih: toque para somar, persiste o valor.
class CounterTool extends StatefulWidget {
  const CounterTool({super.key});
  @override
  State<CounterTool> createState() => _CounterToolState();
}

class _CounterToolState extends State<CounterTool> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((p) => setState(() => _count = p.getInt('counter_val') ?? 0));
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('counter_val', _count);
  }

  void _inc() {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    _save();
  }

  void _dec() {
    if (_count > 0) {
      setState(() => _count--);
      _save();
    }
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.counter), actions: [
        IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: t.reset),
      ]),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _inc,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.gradient(kToolGradients[5]),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 24,
                            offset: Offset(0, 10))
                      ],
                    ),
                    child: Text('$_count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _dec,
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('−1'),
                ),
                FilledButton.icon(
                  onPressed: _inc,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('+1'),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(t.tapToCount,
                style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
