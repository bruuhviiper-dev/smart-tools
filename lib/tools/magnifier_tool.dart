import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';

import '../l10n/strings.dart';
import 'perm_gate.dart';

/// Lupa: câmera traseira com zoom + lanterna. Ótimo para ler letra miúda.
class MagnifierTool extends StatelessWidget {
  const MagnifierTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.magnifier)),
      body: PermissionGate(
        permission: Permission.camera,
        rationale: t.needCamera,
        icon: Icons.photo_camera_rounded,
        child: const _CameraView(front: false, magnifier: true),
      ),
    );
  }
}

/// Espelho: câmera frontal.
class MirrorTool extends StatelessWidget {
  const MirrorTool({super.key});
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.mirror)),
      body: PermissionGate(
        permission: Permission.camera,
        rationale: t.needCamera,
        icon: Icons.photo_camera_front_rounded,
        child: const _CameraView(front: true, magnifier: false),
      ),
    );
  }
}

class _CameraView extends StatefulWidget {
  const _CameraView({required this.front, required this.magnifier});
  final bool front;
  final bool magnifier;

  @override
  State<_CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> {
  CameraController? _ctrl;
  double _zoom = 1, _minZoom = 1, _maxZoom = 1;
  bool _torch = false, _frozen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      final cam = cams.firstWhere(
        (c) => widget.front
            ? c.lensDirection == CameraLensDirection.front
            : c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(cam, ResolutionPreset.high,
          enableAudio: false);
      await c.initialize();
      _minZoom = await c.getMinZoomLevel();
      _maxZoom = await c.getMaxZoomLevel();
      if (widget.magnifier && _maxZoom > 2) {
        _zoom = 2;
        await c.setZoomLevel(2);
      }
      if (!mounted) return;
      setState(() => _ctrl = c);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _setZoom(double z) async {
    z = z.clamp(_minZoom, _maxZoom);
    setState(() => _zoom = z);
    try {
      await _ctrl?.setZoomLevel(z);
    } catch (_) {}
  }

  Future<void> _toggleFreeze() async {
    final c = _ctrl;
    if (c == null) return;
    try {
      if (_frozen) {
        await c.resumePreview();
      } else {
        await c.pausePreview();
      }
    } catch (_) {}
    setState(() => _frozen = !_frozen);
  }

  Future<void> _toggleTorch() async {
    try {
      if (_torch) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() => _torch = !_torch);
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_torch) TorchLight.disableTorch().catchError((_) {});
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }
    final c = _ctrl;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleFreeze,
            child: widget.front
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: CameraPreview(c),
                  )
                : CameraPreview(c),
          ),
        ),
        if (!widget.front)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.zoom_out_rounded, color: Colors.white),
                    Expanded(
                      child: Slider(
                        min: _minZoom,
                        max: _maxZoom.clamp(_minZoom + 0.1, 10),
                        value: _zoom.clamp(_minZoom, _maxZoom),
                        onChanged: _setZoom,
                      ),
                    ),
                    const Icon(Icons.zoom_in_rounded, color: Colors.white),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'torch',
                      onPressed: _toggleTorch,
                      backgroundColor:
                          _torch ? Colors.amber : Colors.black54,
                      child: const Icon(Icons.flashlight_on_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton.small(
                      heroTag: 'freeze',
                      onPressed: _toggleFreeze,
                      backgroundColor:
                          _frozen ? Colors.blue : Colors.black54,
                      child: Icon(
                          _frozen
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
