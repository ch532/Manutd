import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

enum AdNetwork { admob, appodeal, unity, startio }

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Test mode - set to false for production
  static const bool testMode = true;

  // AdMob Test IDs
  static final String _admobBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _admobInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  // Unity Ads Test IDs
  static final String _unityGameId = Platform.isAndroid
      ? '4374881'  // Test Game ID for Android
      : '4374880'; // Test Game ID for iOS

  static const String _unityInterstitialPlacementId = 'Interstitial_Android';
  static const String _unityRewardedPlacementId = 'Rewarded_Android';

  // Appodeal Test App Key
  static final String _appodealAppKey = Platform.isAndroid
      ? 'fee50c333ff3825fd6ad6d38cff78154de3025546d47a84f'
      : 'dee74c5129f53fc629a44a690a02296694e35ecd23f2c197';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // AdMob ads
  BannerAd? _admobBannerAd;
  InterstitialAd? _admobInterstitialAd;

  // Start.io ads
  StartAppBannerAd? _startioBannerAd;
  StartAppInterstitialAd? _startioInterstitialAd;

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeAdMob();
      await _initializeUnityAds();
      await _initializeStartio();
      await _initializeAppodeal();
      
      _isInitialized = true;
      if (kDebugMode) {
        print('AdManager: All ad networks initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Failed to initialize ad networks: $e');
      }
    }
  }

  Future<void> _initializeAdMob() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        print('AdManager: AdMob initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: AdMob initialization failed: $e');
      }
    }
  }

  Future<void> _initializeUnityAds() async {
    try {
      await UnityAds.init(
        gameId: _unityGameId,
        onComplete: () {
          if (kDebugMode) {
            print('AdManager: Unity Ads initialized');
          }
        },
        onFailed: (error, message) {
          if (kDebugMode) {
            print('AdManager: Unity Ads initialization failed: $error - $message');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Unity Ads initialization failed: $e');
      }
    }
  }

  Future<void> _initializeStartio() async {
    try {
      // Initialize Start.io SDK
      StartAppSdk();
      if (kDebugMode) {
        print('AdManager: Start.io initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Start.io initialization failed: $e');
      }
    }
  }

  Future<void> _initializeAppodeal() async {
    try {
      await Appodeal.initialize(
        appKey: _appodealAppKey,
        adTypes: [
          AppodealAdType.Banner,
          AppodealAdType.Interstitial,
          AppodealAdType.RewardedVideo,
        ],
      );
      
      // Set test mode for Appodeal
      if (testMode) {
        await Appodeal.setTesting(true);
      }
      
      if (kDebugMode) {
        print('AdManager: Appodeal initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Appodeal initialization failed: $e');
      }
    }
  }

  // Banner Ads
  Future<BannerAd?> loadAdMobBanner() async {
    try {
      _admobBannerAd?.dispose();
      
      final bannerAd = BannerAd(
        adUnitId: _admobBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('AdManager: AdMob Banner loaded');
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('AdManager: AdMob Banner failed to load: $error');
            }
            ad.dispose();
          },
        ),
      );

      await bannerAd.load();
      _admobBannerAd = bannerAd;
      return bannerAd;
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: AdMob Banner load error: $e');
      }
      return null;
    }
  }

  Future<StartAppBannerAd?> loadStartioBanner() async {
    try {
      final startAppSdk = StartAppSdk();
      final bannerAd = await startAppSdk.loadBannerAd(StartAppBannerType.BANNER);
      _startioBannerAd = bannerAd;
      if (kDebugMode) {
        print('AdManager: Start.io Banner loaded');
      }
      return bannerAd;
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Start.io Banner load error: $e');
      }
      return null;
    }
  }

  // Interstitial Ads
  Future<void> loadAdMobInterstitial() async {
    try {
      await InterstitialAd.load(
        adUnitId: _admobInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _admobInterstitialAd = ad;
            if (kDebugMode) {
              print('AdManager: AdMob Interstitial loaded');
            }
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              print('AdManager: AdMob Interstitial failed to load: $error');
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: AdMob Interstitial load error: $e');
      }
    }
  }

  Future<void> showAdMobInterstitial() async {
    if (_admobInterstitialAd != null) {
      _admobInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _admobInterstitialAd = null;
          loadAdMobInterstitial(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            print('AdManager: AdMob Interstitial failed to show: $error');
          }
          ad.dispose();
          _admobInterstitialAd = null;
        },
      );
      
      await _admobInterstitialAd!.show();
    } else {
      if (kDebugMode) {
        print('AdManager: AdMob Interstitial not ready');
      }
    }
  }

  Future<void> loadAndShowUnityInterstitial() async {
    try {
      await UnityAds.load(
        placementId: _unityInterstitialPlacementId,
        onComplete: (placementId) {
          if (kDebugMode) {
            print('AdManager: Unity Interstitial loaded: $placementId');
          }
          UnityAds.showVideoAd(
            placementId: placementId,
            onComplete: (placementId) {
              if (kDebugMode) {
                print('AdManager: Unity Interstitial completed: $placementId');
              }
            },
            onFailed: (placementId, error, message) {
              if (kDebugMode) {
                print('AdManager: Unity Interstitial failed: $placementId - $error - $message');
              }
            },
          );
        },
        onFailed: (placementId, error, message) {
          if (kDebugMode) {
            print('AdManager: Unity Interstitial load failed: $placementId - $error - $message');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Unity Interstitial error: $e');
      }
    }
  }

  Future<void> loadAndShowStartioInterstitial() async {
    try {
      final startAppSdk = StartAppSdk();
      final interstitialAd = await startAppSdk.loadInterstitialAd();
      final shown = await interstitialAd.show();
      if (kDebugMode) {
        print('AdManager: Start.io Interstitial shown: $shown');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Start.io Interstitial error: $e');
      }
    }
  }

  Future<void> showAppodealInterstitial() async {
    try {
      final isLoaded = await Appodeal.isLoaded(AppodealAdType.Interstitial);
      if (isLoaded) {
        await Appodeal.show(AppodealAdType.Interstitial);
        if (kDebugMode) {
          print('AdManager: Appodeal Interstitial shown');
        }
      } else {
        if (kDebugMode) {
          print('AdManager: Appodeal Interstitial not loaded');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Appodeal Interstitial error: $e');
      }
    }
  }

  // Rewarded Ads
  Future<void> loadAndShowUnityRewarded({required Function() onRewarded}) async {
    try {
      await UnityAds.load(
        placementId: _unityRewardedPlacementId,
        onComplete: (placementId) {
          if (kDebugMode) {
            print('AdManager: Unity Rewarded loaded: $placementId');
          }
          UnityAds.showVideoAd(
            placementId: placementId,
            onComplete: (placementId) {
              if (kDebugMode) {
                print('AdManager: Unity Rewarded completed: $placementId');
              }
              onRewarded();
            },
            onFailed: (placementId, error, message) {
              if (kDebugMode) {
                print('AdManager: Unity Rewarded failed: $placementId - $error - $message');
              }
            },
          );
        },
        onFailed: (placementId, error, message) {
          if (kDebugMode) {
            print('AdManager: Unity Rewarded load failed: $placementId - $error - $message');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Unity Rewarded error: $e');
      }
    }
  }

  Future<void> showAppodealRewarded({required Function() onRewarded}) async {
    try {
      final isLoaded = await Appodeal.isLoaded(AppodealAdType.RewardedVideo);
      if (isLoaded) {
        await Appodeal.show(AppodealAdType.RewardedVideo);
        // Note: Appodeal callback for reward should be handled via their callback system
        if (kDebugMode) {
          print('AdManager: Appodeal Rewarded shown');
        }
      } else {
        if (kDebugMode) {
          print('AdManager: Appodeal Rewarded not loaded');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdManager: Appodeal Rewarded error: $e');
      }
    }
  }

  // Cleanup
  void dispose() {
    _admobBannerAd?.dispose();
    _admobInterstitialAd?.dispose();
    _startioBannerAd?.dispose();
    _startioInterstitialAd?.dispose();
  }
}