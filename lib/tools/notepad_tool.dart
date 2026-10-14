import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Bloco de notas rápido: salva automaticamente no aparelho.
class NotepadTool extends StatefulWidget {
  const NotepadTool({super.key});
  @override
  State<NotepadTool> createState() => _NotepadToolState();
}

class _NotepadToolState extends State<NotepadTool> {
  final _c = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((p) => _c.text = p.getString('notepad_text') ?? '');
  }

  Future<void> _save(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('notepad_text', v);
    if (mounted) {
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 1),
          () => mounted ? setState(() => _saved = false) : null);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notepad),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_done_rounded, color: Color(0xFF22C55E)),
            ),
          IconButton(
            tooltip: t.reset,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              _c.clear();
              _save('');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _c,
          onChanged: _save,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: t.notepadHint,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}
