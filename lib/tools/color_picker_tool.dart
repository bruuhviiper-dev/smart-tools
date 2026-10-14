import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';

/// Seletor de cores: HSV → prévia + HEX + RGB, com copiar.
class ColorPickerTool extends StatefulWidget {
  const ColorPickerTool({super.key});
  @override
  State<ColorPickerTool> createState() => _ColorPickerToolState();
}

class _ColorPickerToolState extends State<ColorPickerTool> {
  double _h = 210, _s = 0.7, _v = 0.9;

  Color get _color => HSVColor.fromAHSV(1, _h, _s, _v).toColor();

  String get _hex =>
      '#${_color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final c = _color;
    final r = (c.r * 255).round();
    final g = (c.g * 255).round();
    final b = (c.b * 255).round();
    return Scaffold(
      appBar: AppBar(title: Text(t.colorPicker)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: c.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Center(
              child: Text(_hex,
                  style: TextStyle(
                      color: _v > 0.6 ? Colors.black : Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 20),
          _slider('H', _h, 360, (v) => setState(() => _h = v),
              _hueGradient()),
          _slider('S', _s * 100, 100, (v) => setState(() => _s = v / 100), [
            HSVColor.fromAHSV(1, _h, 0, _v).toColor(),
            HSVColor.fromAHSV(1, _h, 1, _v).toColor()
          ]),
          _slider('V', _v * 100, 100, (v) => setState(() => _v = v / 100),
              [Colors.black, HSVColor.fromAHSV(1, _h, _s, 1).toColor()]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _chip('RGB', '$r, $g, $b')),
              const SizedBox(width: 12),
              Expanded(child: _chip('HEX', _hex)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _hex));
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$_hex ✓')));
            },
            icon: const Icon(Icons.copy_rounded),
            label: Text(t.copy),
          ),
        ],
      ),
    );
  }

  List<Color> _hueGradient() => [
        for (var i = 0; i <= 360; i += 60)
          HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor()
      ];

  Widget _slider(String label, double value, double max,
          ValueChanged<double> onCh, List<Color> colors) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 20, child: Text(label)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  thumbColor: Colors.white,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Slider(
                    min: 0,
                    max: max,
                    value: value.clamp(0, max),
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                    onChanged: onCh,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _chip(String k, String v) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(k, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(v,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
