import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:startapp_sdk/startapp_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // AdMob
  BannerAd? _admobBannerAd;
  InterstitialAd? _admobInterstitialAd;
  RewardedAd? _admobRewardedAd;
  
  // Appodeal
  bool _appodealInitialized = false;
  
  // Unity Ads
  bool _unityAdsInitialized = false;
  
  // Start.io
  bool _startioInitialized = false;
  
  // Ad configuration
  final Map<String, String> _adUnitIds = {
    'android': {
      'admob_banner': 'ca-app-pub-1171216593802007/8884489855',
      'admob_interstitial': 'ca-app-pub-1171216593802007/4945244849',
      'admob_rewarded': 'ca-app-pub-1171216593802007/1435861786',
    },
    'ios': {
      'admob_banner': 'ca-app-pub-1171216593802007/8884489855',
      'admob_interstitial': 'ca-app-pub-1171216593802007/4945244849',
      'admob_rewarded': 'ca-app-pub-1171216593802007/1435861786',
    },
  };

  // Appodeal configuration
  final String _appodealAppKey = '543d15c055aac7e15a71dae4432f7f78befc17eeed095af5';
  
  // Unity Ads configuration
  final String _unityGameId = '5883117';
  final bool _unityTestMode = false;
  
  // Start.io configuration
  final String _startioAppId = '205787982';

  Future<void> initialize() async {
    try {
      // Initialize AdMob
      await MobileAds.instance.initialize();
      
      // Initialize Appodeal
      await _initializeAppodeal();
      
      // Initialize Unity Ads
      await _initializeUnityAds();
      
      // Initialize Start.io
      await _initializeStartio();
      
      debugPrint('All ad networks initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ad networks: $e');
      rethrow;
    }
  }

  Future<void> _initializeAppodeal() async {
    try {
      await Appodeal.setAppKey(_appodealAppKey);
      await Appodeal.setLogLevel(AppodealLogLevel.verbose);
      await Appodeal.setTesting(true);
      
      // Set ad types
      await Appodeal.setAdType(AppodealAdType.banner);
      await Appodeal.setAdType(AppodealAdType.interstitial);
      await Appodeal.setAdType(AppodealAdType.rewardedVideo);
      
      _appodealInitialized = true;
      debugPrint('Appodeal initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Appodeal: $e');
    }
  }

  Future<void> _initializeUnityAds() async {
    try {
      await UnityAds.init(
        gameId: _unityGameId,
        testMode: _unityTestMode,
        listener: (state, args) {
          debugPrint('Unity Ads: $state - $args');
        },
      );
      
      _unityAdsInitialized = true;
      debugPrint('Unity Ads initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Unity Ads: $e');
    }
  }

  Future<void> _initializeStartio() async {
    try {
      await StartAppSDK.setLogLevel(StartAppSDK.LogLevel.DEBUG);
      await StartAppSDK.init(_startioAppId);
      
      _startioInitialized = true;
      debugPrint('Start.io initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Start.io: $e');
    }
  }

  // AdMob Banner Ad
  Future<BannerAd?> loadAdMobBannerAd() async {
    try {
      final adUnitId = _getAdUnitId('admob_banner');
      _admobBannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('AdMob Banner ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdMob Banner ad failed to load: $error');
            ad.dispose();
          },
        ),
      );
      
      await _admobBannerAd!.load();
      return _admobBannerAd;
    } catch (e) {
      debugPrint('Error loading AdMob banner ad: $e');
      return null;
    }
  }

  // AdMob Interstitial Ad
  Future<void> loadAdMobInterstitialAd() async {
    try {
      final adUnitId = _getAdUnitId('admob_interstitial');
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _admobInterstitialAd = ad;
            debugPrint('AdMob Interstitial ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob Interstitial ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading AdMob interstitial ad: $e');
    }
  }

  Future<void> showAdMobInterstitialAd() async {
    if (_admobInterstitialAd != null) {
      await _admobInterstitialAd!.show();
      _admobInterstitialAd = null;
    }
  }

  // AdMob Rewarded Ad
  Future<void> loadAdMobRewardedAd() async {
    try {
      final adUnitId = _getAdUnitId('admob_rewarded');
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _admobRewardedAd = ad;
            debugPrint('AdMob Rewarded ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob Rewarded ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading AdMob rewarded ad: $e');
    }
  }

  Future<void> showAdMobRewardedAd() async {
    if (_admobRewardedAd != null) {
      await _admobRewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _admobRewardedAd = null;
    }
  }

  // Appodeal Ads
  Future<void> showAppodealBanner() async {
    if (_appodealInitialized) {
      try {
        await Appodeal.show(AppodealShowStyle.bannerBottom);
      } catch (e) {
        debugPrint('Error showing Appodeal banner: $e');
      }
    }
  }

  Future<void> showAppodealInterstitial() async {
    if (_appodealInitialized) {
      try {
        await Appodeal.show(AppodealShowStyle.interstitial);
      } catch (e) {
        debugPrint('Error showing Appodeal interstitial: $e');
      }
    }
  }

  Future<void> showAppodealRewardedVideo() async {
    if (_appodealInitialized) {
      try {
        await Appodeal.show(AppodealShowStyle.rewardedVideo);
      } catch (e) {
        debugPrint('Error showing Appodeal rewarded video: $e');
      }
    }
  }

  // Unity Ads
  Future<void> showUnityAdsInterstitial() async {
    if (_unityAdsInitialized) {
      try {
        await UnityAds.showVideoAd(
          placementId: 'Interstitial_Android',
        );
      } catch (e) {
        debugPrint('Error showing Unity Ads interstitial: $e');
      }
    }
  }

  Future<void> showUnityAdsRewarded() async {
    if (_unityAdsInitialized) {
      try {
        await UnityAds.showVideoAd(
          placementId: 'Rewarded_Android',
        );
      } catch (e) {
        debugPrint('Error showing Unity Ads rewarded: $e');
      }
    }
  }

  // Start.io Ads
  Future<void> showStartioInterstitial() async {
    if (_startioInitialized) {
      try {
        await StartAppSDK.showAd();
      } catch (e) {
        debugPrint('Error showing Start.io interstitial: $e');
      }
    }
  }

  Future<void> showStartioRewarded() async {
    if (_startioInitialized) {
      try {
        await StartAppSDK.showRewardedAd();
      } catch (e) {
        debugPrint('Error showing Start.io rewarded: $e');
      }
    }
  }

  // Helper method to get ad unit ID based on platform
  String _getAdUnitId(String adType) {
    final platform = _getPlatform();
    return _adUnitIds[platform]?[adType] ?? _adUnitIds['android']![adType]!;
  }

  String _getPlatform() {
    // This is a simplified version - in a real app you'd use platform detection
    return 'android'; // You can enhance this with proper platform detection
  }

  // Dispose ads
  void dispose() {
    _admobBannerAd?.dispose();
    _admobInterstitialAd?.dispose();
    _admobRewardedAd?.dispose();
  }

  // Get initialization status
  Map<String, bool> getInitializationStatus() {
    return {
      'admob': true, // AdMob is always initialized if we reach this point
      'appodeal': _appodealInitialized,
      'unity_ads': _unityAdsInitialized,
      'startio': _startioInitialized,
    };
  }
}