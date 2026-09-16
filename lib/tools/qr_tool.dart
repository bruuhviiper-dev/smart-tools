import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';

/// Scanner de QR / código de barras.
class QrTool extends StatefulWidget {
  const QrTool({super.key});
  @override
  State<QrTool> createState() => _QrToolState();
}

class _QrToolState extends State<QrTool> {
  final _ctrl = MobileScannerController();
  String? _value;

  void _onDetect(BarcodeCapture cap) {
    if (_value != null || cap.barcodes.isEmpty) return;
    final code = cap.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() => _value = code);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isUrl =>
      _value != null &&
      (_value!.startsWith('http://') || _value!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.qr),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _ctrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          // Moldura central.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_value != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(_value!,
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _value!));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t.copied)));
                          },
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(t.copy),
                        ),
                        const SizedBox(width: 10),
                        if (_isUrl)
                          FilledButton.icon(
                            onPressed: () => launchUrl(Uri.parse(_value!),
                                mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: Text(t.open),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () => setState(() => _value = null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
