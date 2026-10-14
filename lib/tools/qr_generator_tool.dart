import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/strings.dart';

/// Gerador de QR Code: digite um texto/link e gere o QR na hora.
class QrGeneratorTool extends StatefulWidget {
  const QrGeneratorTool({super.key});
  @override
  State<QrGeneratorTool> createState() => _QrGeneratorToolState();
}

class _QrGeneratorToolState extends State<QrGeneratorTool> {
  final _c = TextEditingController();
  String _data = '';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.qrGenerator)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _c,
            minLines: 1,
            maxLines: 4,
            onChanged: (v) => setState(() => _data = v.trim()),
            decoration: InputDecoration(
              hintText: t.qrGenHint,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              suffixIcon: _c.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() {
                        _c.clear();
                        _data = '';
                      }),
                    ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: _data.isEmpty
                  ? SizedBox(
                      width: 240,
                      height: 240,
                      child: Center(
                        child: Icon(Icons.qr_code_2_rounded,
                            size: 120, color: Colors.grey.shade300),
                      ),
                    )
                  : QrImageView(
                      data: _data,
                      version: QrVersions.auto,
                      size: 240,
                      gapless: false,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (_data.isNotEmpty)
            Center(
              child: Text(t.qrGenReady,
                  style: const TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }
}
