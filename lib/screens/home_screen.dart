import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../tools/altimeter_tool.dart';
import '../tools/battery_tool.dart';
import '../tools/calculator_tool.dart';
import '../tools/compass_tool.dart';
import '../tools/converter_tool.dart';
import '../tools/flashlight_tool.dart';
import '../tools/level_tool.dart';
import '../tools/magnifier_tool.dart';
import '../tools/metal_detector_tool.dart';
import '../tools/plumb_tool.dart';
import '../tools/protractor_tool.dart';
import '../tools/qr_generator_tool.dart';
import '../tools/qibla_tool.dart';
import '../tools/qr_tool.dart';
import '../tools/ruler_tool.dart';
import '../tools/sound_meter_tool.dart';
import '../tools/speedometer_tool.dart';
import '../tools/stopwatch_tool.dart';
import '../tools/timer_tool.dart';
import '../tools/vibration_tool.dart';
import '../tools/world_clock_tool.dart';
import '../widgets/banner_ad.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final s = context.watch<AppState>();

    final sections = <_Section>[
      _Section(t.catMeasure, [
        _Tool(Icons.straighten_rounded, t.ruler, 2, () => const RulerTool()),
        _Tool(Icons.change_history_rounded, t.protractor, 9, () => const ProtractorTool()),
        _Tool(Icons.architecture_rounded, t.level, 3, () => const LevelTool()),
        _Tool(Icons.vertical_align_center_rounded, t.plumb, 11, () => const PlumbTool()),
        _Tool(Icons.explore_rounded, t.compass, 1, () => const CompassTool()),
        _Tool(Icons.swap_horiz_rounded, t.converter, 6, () => const ConverterTool()),
        _Tool(Icons.calculate_rounded, t.calculator, 7, () => const CalculatorTool()),
      ]),
      _Section(t.catSensors, [
        _Tool(Icons.graphic_eq_rounded, t.soundMeter, 10, () => const SoundMeterTool()),
        _Tool(Icons.sensors_rounded, t.metalDetector, 4, () => const MetalDetectorTool()),
        _Tool(Icons.vibration_rounded, t.vibration, 8, () => const VibrationTool()),
        _Tool(Icons.mosque_rounded, t.qibla, 5, () => const QiblaTool()),
        _Tool(Icons.speed_rounded, t.speedometer, 0, () => const SpeedometerTool()),
        _Tool(Icons.terrain_rounded, t.altimeter, 6, () => const AltimeterTool()),
      ]),
      _Section(t.catEveryday, [
        _Tool(Icons.flashlight_on_rounded, t.flashlight, 0, () => const FlashlightTool()),
        _Tool(Icons.search_rounded, t.magnifier, 4, () => const MagnifierTool()),
        _Tool(Icons.qr_code_scanner_rounded, t.qr, 5, () => const QrTool()),
        _Tool(Icons.timer_rounded, t.stopwatch, 8, () => const StopwatchTool()),
        _Tool(Icons.hourglass_bottom_rounded, t.timer, 9, () => const TimerTool()),
        _Tool(Icons.battery_full_rounded, t.battery, 2, () => const BatteryTool()),
        _Tool(Icons.flip_camera_ios_rounded, t.mirror, 4, () => const MirrorTool()),
        _Tool(Icons.qr_code_rounded, t.qrGenerator, 7, () => const QrGeneratorTool()),
        _Tool(Icons.public_rounded, t.worldClock, 1, () => const WorldClockTool()),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (!s.isPro) const _ProCard(),
                for (final sec in sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
                    child: Text(sec.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3)),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: sec.tools.length,
                    itemBuilder: (c, i) => _ToolCard(tool: sec.tools[i]),
                  ),
                ],
              ],
            ),
          ),
          const BannerPlaceholder(),
        ],
      ),
    );
  }
}

class _Section {
  _Section(this.title, this.tools);
  final String title;
  final List<_Tool> tools;
}

class _Tool {
  _Tool(this.icon, this.name, this.gi, this.builder);
  final IconData icon;
  final String name;
  final int gi;
  final Widget Function() builder;
}

class _ProCard extends StatelessWidget {
  const _ProCard();
  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PremiumScreen())),
        child: Ink(
          decoration:
              BoxDecoration(gradient: AppTheme.gradient(AppTheme.hero)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.proTitle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      Text(t.proSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final g = kToolGradients[tool.gi % kToolGradients.length];
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient(g),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => tool.builder())),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool.icon, color: Colors.white, size: 38),
                const SizedBox(height: 8),
                Text(tool.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
