import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_theme.dart';
import '../l10n/strings.dart';
import '../services/app_state.dart';
import '../services/purchase_service.dart';

/// Recurso Pro: se o usuário não for Pro, abre a tela de assinatura e devolve
/// false (quem chamou deve abortar a ação). Se já for Pro, devolve true.
bool requirePro(BuildContext context) {
  if (context.read<AppState>().isPro) return true;
  Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()));
  return false;
}

/// Paywall do Smart Tools Pro: assinatura mensal/anual + vitalício.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selected = PurchaseService.yearlyId;

  @override
  void initState() {
    super.initState();
    // Rebuild quando os preços reais da Play chegarem.
    PurchaseService.instance.addListener(_onPrices);
  }

  @override
  void dispose() {
    PurchaseService.instance.removeListener(_onPrices);
    super.dispose();
  }

  void _onPrices() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final s = context.watch<AppState>();
    final ps = PurchaseService.instance;

    if (s.isPro) {
      // Já é Pro: agradece e fecha.
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded,
                  size: 90, color: AppTheme.brand),
              const SizedBox(height: 16),
              Text(t.proTitle,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('✓ ${t.featAllTools}',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho gradiente.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: BoxDecoration(
                gradient: AppTheme.gradient(AppTheme.hero),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Icon(Icons.workspace_premium_rounded,
                      size: 64, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(t.proTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(t.proSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _feature(t.featNoAds),
                  _feature(t.featAllTools),
                  _feature(t.featRecord),
                  _feature(t.featExport),
                  _feature(t.featPrecision),
                  const SizedBox(height: 20),
                  _plan(t, ps, PurchaseService.yearlyId, t.yearly,
                      '${ps.priceOf(PurchaseService.yearlyId)}${t.perYear}',
                      badge: t.bestValue),
                  _plan(t, ps, PurchaseService.monthlyId, t.monthly,
                      '${ps.priceOf(PurchaseService.monthlyId)}${t.perMonth}'),
                  _plan(t, ps, PurchaseService.lifetimeId, t.lifetime,
                      '${ps.priceOf(PurchaseService.lifetimeId)} · ${t.oneTime}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => ps.buy(_selected),
                  child: Text(t.subscribe,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            TextButton(
              onPressed: () => ps.restore(),
              child: Text(t.restore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.brand, size: 24),
            const SizedBox(width: 12),
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _plan(T t, PurchaseService ps, String id, String title, String price,
      {String? badge}) {
    final sel = _selected == id;
    return GestureDetector(
      onTap: () => setState(() => _selected = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: sel
              ? AppTheme.brand.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
              color: sel ? AppTheme.brand : Colors.grey.withValues(alpha: 0.4),
              width: sel ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(sel
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
                color: sel ? AppTheme.brand : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.brand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(price, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
