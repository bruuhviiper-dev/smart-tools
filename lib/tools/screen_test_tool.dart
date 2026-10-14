import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';

/// Teste de tela: cores sólidas em tela cheia para achar pixels mortos /
/// usar como luz de tela. Toque = próxima cor, voltar = sair.
class ScreenTestTool extends StatefulWidget {
  const ScreenTestTool({super.key});
  @override
  State<ScreenTestTool> createState() => _ScreenTestToolState();
}

class _ScreenTestToolState extends State<ScreenTestTool> {
  static const _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.cyan,
    Color(0xFFFF00FF),
  ];
  int _i = 0;
  bool _full = false;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _enterFull() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    setState(() => _full = true);
  }

  void _exitFull() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() => _full = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    if (_full) {
      return GestureDetector(
        onTap: () => setState(() => _i = (_i + 1) % _colors.length),
        onLongPress: _exitFull,
        child: Scaffold(
          backgroundColor: _colors[_i],
          body: const SizedBox.expand(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.screenTest)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(t.screenTestHint, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  for (var k = 0; k < _colors.length; k++)
                    GestureDetector(
                      onTap: () {
                        _i = k;
                        _enterFull();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colors[k],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                _i = 0;
                _enterFull();
              },
              icon: const Icon(Icons.fullscreen_rounded),
              label: Text(t.start),
            ),
          ],
        ),
      ),
    );
  }
}
