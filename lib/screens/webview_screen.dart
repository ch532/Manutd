import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool _hasError = false;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _pageLoadCount = 0;

  @override
  void initState() {
    super.initState();
    _adManager = AdManager();
    _currentUrl = widget.initialUrl;
    _initializeWebView();
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
              _hasError = false;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
              _pageLoadCount++;
            });
            
            // Show interstitial ad every 3 page loads
            if (_pageLoadCount % 3 == 0) {
              _showInterstitialAd();
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
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
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
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

  Future<void> _showInterstitialAd() async {
    try {
      await _adManager.showRandomInterstitial();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _webViewController.reload();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshPage();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect Gold',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPage,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () => _launchExternalUrl(_currentUrl),
            tooltip: 'Open in Browser',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showSettingsDialog();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
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
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _isLoading
              ? const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load page',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your internet connection',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshPage,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Banner Ad at the bottom
          Container(
            height: 60,
            child: _adManager.getRandomBannerAd(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _canGoBack ? Colors.white : Colors.white54,
              ),
              onPressed: _canGoBack ? () async {
                if (await _webViewController.canGoBack()) {
                  await _webViewController.goBack();
                }
              } : null,
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                _webViewController.loadRequest(Uri.parse('https://connectgold.sbs'));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: _canGoForward ? Colors.white : Colors.white54,
              ),
              onPressed: _canGoForward ? () async {
                if (await _webViewController.canGoForward()) {
                  await _webViewController.goForward();
                }
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ads),
              title: const Text('Ad Networks Status'),
              subtitle: Text(
                'AdMob: ${_adManager.isAdMobInitialized ? "✓" : "✗"}\n'
                'Appodeal: ${_adManager.isAppodealInitialized ? "✓" : "✗"}\n'
                'Unity Ads: ${_adManager.isUnityAdsInitialized ? "✓" : "✗"}\n'
                'Start.io: ${_adManager.isStartAppInitialized ? "✓" : "✗"}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Current URL'),
              subtitle: Text(_currentUrl),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Connect Gold'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect Gold WebView App',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Integrated Ad Networks:'),
            Text('• Google AdMob'),
            Text('• Appodeal'),
            Text('• Unity Ads'),
            Text('• Start.io'),
            SizedBox(height: 8),
            Text('Website: https://connectgold.sbs'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}