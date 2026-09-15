import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';

/// Informações da bateria: nível e estado (carregando / descarregando).
class BatteryTool extends StatefulWidget {
  const BatteryTool({super.key});
  @override
  State<BatteryTool> createState() => _BatteryToolState();
}

class _BatteryToolState extends State<BatteryTool> {
  final _battery = Battery();
  StreamSubscription<BatteryState>? _sub;
  int _level = 0;
  BatteryState _state = BatteryState.unknown;

  @override
  void initState() {
    super.initState();
    _refresh();
    _sub = _battery.onBatteryStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final l = await _battery.batteryLevel;
    if (mounted) setState(() => _level = l);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _stateLabel(T t) {
    switch (_state) {
      case BatteryState.charging:
        return t.charging;
      case BatteryState.full:
        return t.full;
      default:
        return t.discharging;
    }
  }

  Color get _color {
    if (_level > 50) return Colors.green;
    if (_level > 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final charging =
        _state == BatteryState.charging || _state == BatteryState.full;
    return Scaffold(
      appBar: AppBar(title: Text(t.battery)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de bateria com preenchimento.
            SizedBox(
              width: 140,
              height: 260,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: (_level / 100).clamp(0.02, 1),
                    widthFactor: 1,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (charging)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: Icon(Icons.bolt_rounded,
                          size: 48, color: Colors.white),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('$_level%',
                style: TextStyle(
                    fontSize: 56, fontWeight: FontWeight.w900, color: _color)),
            Text('${t.batteryStatus}: ${_stateLabel(t)}',
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
