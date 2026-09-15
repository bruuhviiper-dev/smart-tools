import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

import '../l10n/strings.dart';

enum _Mode { off, on, sos, strobe }

class FlashlightTool extends StatefulWidget {
  const FlashlightTool({super.key});
  @override
  State<FlashlightTool> createState() => _FlashlightToolState();
}

class _FlashlightToolState extends State<FlashlightTool> {
  _Mode _mode = _Mode.off;
  bool _lit = false;
  Timer? _loop;
  double _strobeHz = 5;

  Future<void> _torch(bool on) async {
    try {
      if (on) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
      if (mounted) setState(() => _lit = on);
    } catch (_) {}
  }

  void _stop() {
    _loop?.cancel();
    _loop = null;
  }

  Future<void> _setMode(_Mode m) async {
    _stop();
    if (_mode == m) m = _Mode.off; // toca de novo = desliga
    _mode = m;
    switch (m) {
      case _Mode.off:
        await _torch(false);
        break;
      case _Mode.on:
        await _torch(true);
        break;
      case _Mode.sos:
        _runSos();
        break;
      case _Mode.strobe:
        _runStrobe();
        break;
    }
    if (mounted) setState(() {});
  }

  // · · · − − − · · ·
  void _runSos() {
    const unit = Duration(milliseconds: 220);
    final seq = <int>[1, 1, 1, 3, 3, 3, 1, 1, 1];
    var i = 0;
    () async {
      while (mounted && _mode == _Mode.sos) {
        await _torch(true);
        await Future.delayed(unit * seq[i]);
        if (_mode != _Mode.sos) break;
        await _torch(false);
        await Future.delayed(unit);
        i = (i + 1) % seq.length;
      }
    }();
  }

  void _runStrobe() {
    () async {
      while (mounted && _mode == _Mode.strobe) {
        final half = (1000 / _strobeHz / 2).round();
        await _torch(true);
        await Future.delayed(Duration(milliseconds: half));
        if (_mode != _Mode.strobe) break;
        await _torch(false);
        await Future.delayed(Duration(milliseconds: half));
      }
    }();
  }

  @override
  void dispose() {
    _stop();
    TorchLight.disableTorch().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.flashlight)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _setMode(_Mode.on),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lit
                      ? const Color(0xFFFFC400)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  boxShadow: _lit
                      ? const [
                          BoxShadow(
                              color: Color(0x88FFC400),
                              blurRadius: 60,
                              spreadRadius: 8)
                        ]
                      : null,
                ),
                child: Icon(Icons.flashlight_on_rounded,
                    size: 90, color: _lit ? Colors.white : Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Text(_mode == _Mode.off ? t.off : t.on,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                _modeChip(t.sos, Icons.sos_rounded, _Mode.sos),
                _modeChip(t.strobe, Icons.flash_on_rounded, _Mode.strobe),
              ],
            ),
            if (_mode == _Mode.strobe)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.speed_rounded, size: 20),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 20,
                        divisions: 19,
                        value: _strobeHz,
                        label: '${_strobeHz.round()} Hz',
                        onChanged: (v) => setState(() => _strobeHz = v),
                      ),
                    ),
                    Text('${_strobeHz.round()} Hz'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String label, IconData icon, _Mode m) => ChoiceChip(
        avatar: Icon(icon,
            size: 18, color: _mode == m ? Colors.white : null),
        label: Text(label),
        selected: _mode == m,
        onSelected: (_) => _setMode(m),
      );
}
