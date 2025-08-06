import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  const WebViewScreen({
    super.key,
    required this.initialUrl,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  late AdManager _adManager;
  
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';
  String _pageTitle = '';
  
  // AdMob Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Ad display timers
  Timer? _interstitialTimer;
  Timer? _rewardedTimer;
  int _pageViewCount = 0;
  
  // Ad configuration
  final int _interstitialAdInterval = 3; // Show interstitial every 3 page views
  final int _rewardedAdInterval = 5; // Show rewarded ad every 5 page views

  @override
  void initState() {
    super.initState();
    _adManager = AdManager();
    _initializeWebView();
    _loadBannerAd();
    _startAdTimers();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
              _pageViewCount++;
            });
            _checkAdDisplay();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle external links
            if (!request.url.startsWith('http://') && 
                !request.url.startsWith('https://')) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              setState(() {
                _currentUrl = change.url!;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _loadBannerAd() async {
    try {
      _bannerAd = await _adManager.loadAdMobBannerAd();
      if (_bannerAd != null) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
    }
  }

  void _startAdTimers() {
    // Load interstitial ad
    _adManager.loadAdMobInterstitialAd();
    
    // Load rewarded ad
    _adManager.loadAdMobRewardedAd();
  }

  void _checkAdDisplay() {
    // Show interstitial ad every few page views
    if (_pageViewCount % _interstitialAdInterval == 0 && _pageViewCount > 0) {
      _showInterstitialAd();
    }
    
    // Show rewarded ad every few page views
    if (_pageViewCount % _rewardedAdInterval == 0 && _pageViewCount > 0) {
      _showRewardedAd();
    }
  }

  Future<void> _showInterstitialAd() async {
    try {
      await _adManager.showAdMobInterstitialAd();
      // Reload interstitial ad after showing
      _adManager.loadAdMobInterstitialAd();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
    }
  }

  Future<void> _showRewardedAd() async {
    try {
      await _adManager.showAdMobRewardedAd();
      // Reload rewarded ad after showing
      _adManager.loadAdMobRewardedAd();
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }
  }

  @override
  void dispose() {
    _interstitialTimer?.cancel();
    _rewardedTimer?.cancel();
    _bannerAd?.dispose();
    _adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitle.isNotEmpty ? _pageTitle : 'Connect Gold',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
          // Menu button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Home'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ads_info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Ad Networks Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                
                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Banner Ad
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _canGoBack
                  ? () async {
                      if (await _webViewController.canGoBack()) {
                        await _webViewController.goBack();
                      }
                    }
                  : null,
            ),
            
            // Home button
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                _webViewController.loadRequest(Uri.parse('https://connectgold.sbs'));
              },
            ),
            
            // Forward button
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: _canGoForward
                  ? () async {
                      if (await _webViewController.canGoForward()) {
                        await _webViewController.goForward();
                      }
                    }
                  : null,
            ),
            
            // Ad test button
            IconButton(
              icon: const Icon(Icons.ads, color: Colors.white),
              onPressed: () {
                _showAdTestDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'home':
        _webViewController.loadRequest(Uri.parse('https://connectgold.sbs'));
        break;
      case 'share':
        _shareCurrentPage();
        break;
      case 'ads_info':
        _showAdNetworksInfo();
        break;
      case 'settings':
        _showSettings();
        break;
    }
  }

  void _shareCurrentPage() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAdNetworksInfo() {
    final status = _adManager.getInitializationStatus();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ad Networks Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: status.entries.map((entry) {
            return ListTile(
              leading: Icon(
                entry.value ? Icons.check_circle : Icons.error,
                color: entry.value ? Colors.green : Colors.red,
              ),
              title: Text(entry.key.toUpperCase()),
              subtitle: Text(entry.value ? 'Initialized' : 'Failed to initialize'),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              subtitle: Text('Connect Gold WebView App'),
            ),
            ListTile(
              leading: Icon(Icons.ads),
              title: Text('Ad Networks'),
              subtitle: Text('AdMob, Appodeal, Unity Ads, Start.io'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAdTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Ads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('Interstitial Ad'),
              onTap: () {
                Navigator.of(context).pop();
                _showInterstitialAd();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Rewarded Ad'),
              onTap: () {
                Navigator.of(context).pop();
                _showRewardedAd();
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('Appodeal Interstitial'),
              onTap: () {
                Navigator.of(context).pop();
                _adManager.showAppodealInterstitial();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Unity Ads'),
              onTap: () {
                Navigator.of(context).pop();
                _adManager.showUnityAdsInterstitial();
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('Start.io Interstitial'),
              onTap: () {
                Navigator.of(context).pop();
                _adManager.showStartioInterstitial();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}