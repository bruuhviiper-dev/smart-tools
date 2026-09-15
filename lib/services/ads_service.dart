import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob: banner + premiado. EM TESTE — trocar os IDs reais e `_useTestAds=false`
/// antes de publicar (e pôr o App ID no AndroidManifest).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const bool _useTestAds = true;
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _realBanner = 'ca-app-pub-0000000000000000/0000000000';
  static const _realRewarded = 'ca-app-pub-0000000000000000/0000000000';
  static bool _ph(String id) => id.contains('0000000000');

  bool _init = false;
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  String get bannerUnitId =>
      (_useTestAds || _ph(_realBanner)) ? _testBanner : _realBanner;
  String get _rewardedUnitId =>
      (_useTestAds || _ph(_realRewarded)) ? _testRewarded : _realRewarded;

  void init() {
    if (_init || !_supported) return;
    _init = true;
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
