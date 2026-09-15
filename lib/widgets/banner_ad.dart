import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';

import '../services/ads_service.dart';
import '../services/app_state.dart';

/// Banner adaptativo no rodapé. Some para quem tem Premium.
class BannerPlaceholder extends StatefulWidget {
  const BannerPlaceholder({super.key});
  @override
  State<BannerPlaceholder> createState() => _BannerPlaceholderState();
}

class _BannerPlaceholderState extends State<BannerPlaceholder> {
  BannerAd? _ad;
  bool _loaded = false, _failed = false, _req = false;
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_req) {
      _req = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (!_supported) {
      setState(() => _failed = true);
      return;
    }
    final w = MediaQuery.of(context).size.width.truncate();
    final size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait, w);
    if (size == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final ad = BannerAd(
      size: size,
      adUnitId: AdsService.instance.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, e) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
    await ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().adsRemoved || _failed) {
      return const SizedBox.shrink();
    }
    if (_ad == null || !_loaded) return const SizedBox(height: 60);
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
