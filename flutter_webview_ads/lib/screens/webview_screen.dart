import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:startapp_sdk/startapp.dart';
import '../services/ad_manager.dart';

class WebViewScreen extends StatefulWidget {
  final String? initialUrl;
  
  const WebViewScreen({
    super.key,
    this.initialUrl,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  final TextEditingController _urlController = TextEditingController();
  final AdManager _adManager = AdManager();
  
  bool _isLoading = true;
  bool _hasError = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _loadingProgress = 0;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Ad-related variables
  BannerAd? _bannerAd;
  StartAppBannerAd? _startioBannerAd;
  bool _showBannerAd = true;
  int _adNetworkIndex = 0; // 0: AdMob, 1: Start.io, 2: Appodeal
  Timer? _adRotationTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeConnectivity();
    await _initializeWebView();
    await _initializeAds();
    _startAdRotation();
  }

  Future<void> _initializeConnectivity() async {
    final Connectivity connectivity = Connectivity();
    _connectionStatus = await connectivity.checkConnectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        setState(() {
          _connectionStatus = result;
        });
        if (!result.contains(ConnectivityResult.none)) {
          _reloadWebView();
        }
      },
    );
  }

  Future<void> _initializeWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _urlController.text = url;
            });
            _updateNavigationState();
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateNavigationState();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      );

    // Load initial URL
    final initialUrl = widget.initialUrl ?? 'https://www.google.com';
    _urlController.text = initialUrl;
    await _webViewController.loadRequest(Uri.parse(initialUrl));
  }

  Future<void> _initializeAds() async {
    await _adManager.initialize();
    if (_adManager.isInitialized) {
      _loadBannerAd();
    }
  }

  void _startAdRotation() {
    _adRotationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _rotateAds();
      }
    });
  }

  void _rotateAds() {
    setState(() {
      _adNetworkIndex = (_adNetworkIndex + 1) % 3;
    });
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    // Dispose previous ads
    _bannerAd?.dispose();
    _startioBannerAd?.dispose();
    
    switch (_adNetworkIndex) {
      case 0: // AdMob
        final bannerAd = await _adManager.loadAdMobBanner();
        if (mounted && bannerAd != null) {
          setState(() {
            _bannerAd = bannerAd;
            _startioBannerAd = null;
          });
        }
        break;
      case 1: // Start.io
        final startioBanner = await _adManager.loadStartioBanner();
        if (mounted && startioBanner != null) {
          setState(() {
            _startioBannerAd = startioBanner;
            _bannerAd = null;
          });
        }
        break;
      case 2: // Appodeal (banner via their widget system)
        setState(() {
          _bannerAd = null;
          _startioBannerAd = null;
        });
        break;
    }
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _webViewController.canGoBack();
    final canGoForward = await _webViewController.canGoForward();
    
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _navigateToUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    try {
      await _webViewController.loadRequest(Uri.parse(url));
    } catch (e) {
      _showErrorSnackBar('Invalid URL: $url');
    }
  }

  void _reloadWebView() {
    _webViewController.reload();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _reloadWebView,
        ),
      ),
    );
  }

  void _showInterstitialAd() {
    switch (_adNetworkIndex % 4) {
      case 0:
        _adManager.showAdMobInterstitial();
        break;
      case 1:
        _adManager.loadAndShowUnityInterstitial();
        break;
      case 2:
        _adManager.loadAndShowStartioInterstitial();
        break;
      case 3:
        _adManager.showAppodealInterstitial();
        break;
    }
  }

  void _showRewardedAd() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Watch Ad for Reward'),
        content: const Text('Watch a rewarded ad to unlock premium features!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _adManager.loadAndShowUnityRewarded(
                onRewarded: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward earned! Premium features unlocked.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _adRotationTimer?.cancel();
    _bannerAd?.dispose();
    _startioBannerAd?.dispose();
    _adManager.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView with Ads'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadWebView,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'interstitial':
                  _showInterstitialAd();
                  break;
                case 'rewarded':
                  _showRewardedAd();
                  break;
                case 'toggle_banner':
                  setState(() {
                    _showBannerAd = !_showBannerAd;
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'interstitial',
                child: Text('Show Interstitial Ad'),
              ),
              const PopupMenuItem(
                value: 'rewarded',
                child: Text('Show Rewarded Ad'),
              ),
              PopupMenuItem(
                value: 'toggle_banner',
                child: Text(_showBannerAd ? 'Hide Banner' : 'Show Banner'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // URL Input Bar
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Enter URL...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _navigateToUrl(_urlController.text),
                      ),
                    ),
                    onSubmitted: _navigateToUrl,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Controls
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _canGoBack ? () => _webViewController.goBack() : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _canGoForward ? () => _webViewController.goForward() : null,
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => _navigateToUrl('https://www.google.com'),
                ),
              ],
            ),
          ),
          
          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
            ),
          
          // Connection Status
          if (_connectionStatus.contains(ConnectivityResult.none))
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'No internet connection',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          
          // WebView
          Expanded(
            child: _hasError
                ? _buildErrorWidget()
                : WebViewWidget(controller: _webViewController),
          ),
          
          // Banner Ad
          if (_showBannerAd) _buildBannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load page',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _reloadWebView,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAdWidget() {
    return Container(
      height: 60,
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildCurrentBannerAd(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBannerAd() {
    switch (_adNetworkIndex) {
      case 0: // AdMob
        if (_bannerAd != null) {
          return AdWidget(ad: _bannerAd!);
        }
        break;
      case 1: // Start.io
        if (_startioBannerAd != null) {
          return StartAppBanner(_startioBannerAd!);
        }
        break;
      case 2: // Appodeal
        return const Center(
          child: Text(
            'Appodeal Banner',
            style: TextStyle(color: Colors.grey),
          ),
        );
    }
    
    // Fallback
    return const Center(
      child: Text(
        'Ad Loading...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}