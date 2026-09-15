import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/strings.dart';

/// Pede uma permissão e só mostra [child] quando concedida.
/// Enquanto isso exibe uma tela amigável com botões conceder/abrir ajustes.
class PermissionGate extends StatefulWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.rationale,
    required this.child,
    required this.icon,
  });

  final Permission permission;
  final String rationale;
  final IconData icon;
  final Widget child;

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _request();
  }

  Future<void> _request() async {
    final s = await widget.permission.request();
    if (mounted) setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    if (_status == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_status!.isGranted || _status!.isLimited) return widget.child;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 72, color: Colors.grey),
            const SizedBox(height: 20),
            Text(widget.rationale,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _status!.isPermanentlyDenied ? openAppSettings : _request,
              icon: const Icon(Icons.lock_open_rounded),
              label: Text(
                  _status!.isPermanentlyDenied ? t.openSettings : t.grant),
            ),
          ],
        ),
      ),
    );
  }
}
