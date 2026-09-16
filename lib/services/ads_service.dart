import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob: banner + premiado (IDs REAIS de produção).
/// App ID (no AndroidManifest): ca-app-pub-5880219350817278~8076477663
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  // Produção. Em debug, os dispositivos de teste abaixo recebem anúncios de
  // teste através destes mesmos IDs — protege a conta de tráfego inválido.
  static const bool _useTestAds = false;
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _realBanner = 'ca-app-pub-5880219350817278/4137232652';
  static const _realRewarded = 'ca-app-pub-5880219350817278/6819236312';
  static bool _ph(String id) => id.contains('0000000000');

  /// IDs de dispositivo de teste (hash do logcat). Só usados em debug.
  static const List<String> _testDeviceIds = ['B3EEABB8EE11C2BE770B684D95219ECB'];

  bool _init = false;
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  String get bannerUnitId =>
      (_useTestAds || _ph(_realBanner)) ? _testBanner : _realBanner;
  String get _rewardedUnitId =>
      (_useTestAds || _ph(_realRewarded)) ? _testRewarded : _realRewarded;

  void init() {
    if (_init || !_supported) return;
    _init = true;
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: _testDeviceIds));
    }
    MobileAds.instance.initialize();
  }

  Future<bool> showRewarded(void Function() onReward) async {
    if (!_supported) {
      onReward();
      return true;
    }
    final c = Completer<bool>();
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          var earned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!c.isCompleted) c.complete(earned);
            },
            onAdFailedToShowFullScreenContent: (ad, e) {
              ad.dispose();
              if (!c.isCompleted) c.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (ad, r) {
            earned = true;
            onReward();
          });
        },
        onAdFailedToLoad: (e) {
          if (!c.isCompleted) c.complete(false);
        },
      ),
    );
    return c.future;
  }
}
