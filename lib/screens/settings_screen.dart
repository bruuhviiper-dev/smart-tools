import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/purchase_service.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          if (!s.isPro)
            Card(
              margin: const EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                tileColor: AppTheme.brand.withValues(alpha: 0.10),
                leading: const Icon(Icons.workspace_premium_rounded,
                    color: AppTheme.brand),
                title: Text(t.goPro,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(t.proSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumScreen())),
              ),
            ),
          if (s.isPro)
            const ListTile(
              leading: Icon(Icons.verified_rounded, color: AppTheme.brand),
              title: Text('Pro',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: Text(t.darkMode),
            value: s.isDark,
            onChanged: (_) => context.read<AppState>().toggleDark(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(t.measurement,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          RadioListTile<String>(
            value: 'auto',
            groupValue: s.unitsMode,
            title: Text(t.unitsAuto),
            onChanged: (v) => context.read<AppState>().setUnitsMode(v!),
          ),
          RadioListTile<String>(
            value: 'metric',
            groupValue: s.unitsMode,
            title: Text(t.unitsMetric),
            onChanged: (v) => context.read<AppState>().setUnitsMode(v!),
          ),
          RadioListTile<String>(
            value: 'imperial',
            groupValue: s.unitsMode,
            title: Text(t.unitsImperial),
            onChanged: (v) => context.read<AppState>().setUnitsMode(v!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: Text(t.restore),
            onTap: () => PurchaseService.instance.restore(),
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
            title: Text(t.rateUs),
            onTap: () => launchUrl(
                Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.smarttoolbox.tools'),
                mode: LaunchMode.externalApplication),
          ),
        ],
      ),
    );
  }
}
