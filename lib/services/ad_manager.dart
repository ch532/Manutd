import 'dart:io';
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

  bool _isInitialized = false;
  bool _isAdMobInitialized = false;
  bool _isAppodealInitialized = false;
  bool _isUnityAdsInitialized = false;
  bool _isStartAppInitialized = false;

  // AdMob IDs - Replace with your actual IDs
  static const String _adMobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _adMobBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _adMobInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _adMobRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // Appodeal IDs - Replace with your actual IDs
  static const String _appodealAppKey = 'dee74c5129f53fc629a44a690a02296694eb74e47e91b6e8';

  // Unity Ads IDs - Replace with your actual IDs
  static const String _unityGameId = '1234567';
  static const bool _unityTestMode = true;

  // Start.io IDs - Replace with your actual IDs
  static const String _startAppAppId = '203002564';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize all ad networks in parallel
      await Future.wait([
        _initializeAdMob(),
        _initializeAppodeal(),
        _initializeUnityAds(),
        _initializeStartApp(),
      ]);

      _isInitialized = true;
      debugPrint('All ad networks initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ad networks: $e');
      rethrow;
    }
  }

  Future<void> _initializeAdMob() async {
    try {
      await MobileAds.instance.initialize();
      
      // Initialize test ads
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['EMULATOR'],
        ),
      );

      _isAdMobInitialized = true;
      debugPrint('AdMob initialized successfully');
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  Future<void> _initializeAppodeal() async {
    try {
      await Appodeal.initialize(
        appKey: _appodealAppKey,
        adTypes: [
          AppodealAdType.banner,
          AppodealAdType.interstitial,
          AppodealAdType.rewardedVideo,
        ],
      );

      _isAppodealInitialized = true;
      debugPrint('Appodeal initialized successfully');
    } catch (e) {
      debugPrint('Appodeal initialization error: $e');
    }
  }

  Future<void> _initializeUnityAds() async {
    try {
      await UnityAds.init(
        gameId: _unityGameId,
        testMode: _unityTestMode,
        onInitializationComplete: () {
          debugPrint('Unity Ads initialization complete');
        },
        onInitializationFailed: (error, message) {
          debugPrint('Unity Ads initialization failed: $error - $message');
        },
      );

      _isUnityAdsInitialized = true;
      debugPrint('Unity Ads initialized successfully');
    } catch (e) {
      debugPrint('Unity Ads initialization error: $e');
    }
  }

  Future<void> _initializeStartApp() async {
    try {
      await StartAppSDK.setAppId(_startAppAppId);
      await StartAppSDK.init();

      _isStartAppInitialized = true;
      debugPrint('Start.io initialized successfully');
    } catch (e) {
      debugPrint('Start.io initialization error: $e');
    }
  }

  // AdMob Banner Ad
  BannerAd createAdMobBannerAd() {
    return BannerAd(
      adUnitId: _adMobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('AdMob banner ad loaded'),
        onAdFailedToLoad: (ad, error) => debugPrint('AdMob banner ad failed to load: $error'),
      ),
    );
  }

  // AdMob Interstitial Ad
  Future<InterstitialAd?> createAdMobInterstitialAd() async {
    try {
      InterstitialAd? interstitialAd;
      await InterstitialAd.load(
        adUnitId: _adMobInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
            debugPrint('AdMob interstitial ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob interstitial ad failed to load: $error');
          },
        ),
      );
      return interstitialAd;
    } catch (e) {
      debugPrint('Error creating AdMob interstitial ad: $e');
      return null;
    }
  }

  // Appodeal Banner
  Widget createAppodealBanner() {
    return AppodealBanner(
      placement: AppodealBannerPlacement.bottom,
      onAdLoaded: () => debugPrint('Appodeal banner loaded'),
      onAdFailedToLoad: () => debugPrint('Appodeal banner failed to load'),
    );
  }

  // Appodeal Interstitial
  Future<void> showAppodealInterstitial() async {
    try {
      if (await Appodeal.isLoaded(AppodealAdType.interstitial)) {
        await Appodeal.show(AppodealAdType.interstitial);
        debugPrint('Appodeal interstitial shown');
      } else {
        debugPrint('Appodeal interstitial not loaded');
      }
    } catch (e) {
      debugPrint('Error showing Appodeal interstitial: $e');
    }
  }

  // Unity Ads Banner
  Widget createUnityAdsBanner() {
    return UnityBannerAd(
      placementId: 'Banner_Android',
      onAdLoaded: () => debugPrint('Unity Ads banner loaded'),
      onAdFailed: (error, message) => debugPrint('Unity Ads banner failed: $error - $message'),
    );
  }

  // Unity Ads Interstitial
  Future<void> showUnityAdsInterstitial() async {
    try {
      if (await UnityAds.isReady('Interstitial_Android')) {
        await UnityAds.show('Interstitial_Android');
        debugPrint('Unity Ads interstitial shown');
      } else {
        debugPrint('Unity Ads interstitial not ready');
      }
    } catch (e) {
      debugPrint('Error showing Unity Ads interstitial: $e');
    }
  }

  // Start.io Banner
  Widget createStartAppBanner() {
    return StartAppBannerAd(
      onAdLoaded: () => debugPrint('Start.io banner loaded'),
      onAdFailedToLoad: (error) => debugPrint('Start.io banner failed: $error'),
    );
  }

  // Start.io Interstitial
  Future<void> showStartAppInterstitial() async {
    try {
      await StartAppSDK.showAd();
      debugPrint('Start.io interstitial shown');
    } catch (e) {
      debugPrint('Error showing Start.io interstitial: $e');
    }
  }

  // Show random interstitial ad
  Future<void> showRandomInterstitial() async {
    final random = DateTime.now().millisecondsSinceEpoch % 4;
    
    switch (random) {
      case 0:
        if (_isAdMobInitialized) {
          final ad = await createAdMobInterstitialAd();
          await ad?.show();
        }
        break;
      case 1:
        if (_isAppodealInitialized) {
          await showAppodealInterstitial();
        }
        break;
      case 2:
        if (_isUnityAdsInitialized) {
          await showUnityAdsInterstitial();
        }
        break;
      case 3:
        if (_isStartAppInitialized) {
          await showStartAppInterstitial();
        }
        break;
    }
  }

  // Get random banner ad
  Widget getRandomBannerAd() {
    final random = DateTime.now().millisecondsSinceEpoch % 4;
    
    switch (random) {
      case 0:
        if (_isAdMobInitialized) {
          final ad = createAdMobBannerAd();
          ad.load();
          return Container(
            height: 50,
            child: AdWidget(ad: ad),
          );
        }
        break;
      case 1:
        if (_isAppodealInitialized) {
          return createAppodealBanner();
        }
        break;
      case 2:
        if (_isUnityAdsInitialized) {
          return createUnityAdsBanner();
        }
        break;
      case 3:
        if (_isStartAppInitialized) {
          return createStartAppBanner();
        }
        break;
    }
    
    // Fallback to empty container if no ads are available
    return const SizedBox.shrink();
  }

  bool get isInitialized => _isInitialized;
  bool get isAdMobInitialized => _isAdMobInitialized;
  bool get isAppodealInitialized => _isAppodealInitialized;
  bool get isUnityAdsInitialized => _isUnityAdsInitialized;
  bool get isStartAppInitialized => _isStartAppInitialized;
}