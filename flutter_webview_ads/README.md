# Flutter WebView with Multiple Ad Networks

A comprehensive Flutter WebView application that integrates multiple ad networks including **Google AdMob**, **Appodeal**, **Unity Ads**, and **Start.io**. This app provides a complete web browsing experience with monetization through various ad formats.

## Features

### 🌐 WebView Functionality
- **Full-featured web browser** with navigation controls
- **URL input** with search functionality
- **Back/Forward navigation** with state management
- **Loading progress indicator** and error handling
- **Connectivity monitoring** with offline detection
- **Modern Material Design UI**

### 📱 Ad Network Integration
- **Google AdMob** - Banner and Interstitial ads
- **Unity Ads** - Video Interstitial and Rewarded ads
- **Start.io** - Banner and Interstitial ads
- **Appodeal** - Mediation platform with multiple formats

### 🎯 Ad Features
- **Banner Ad Rotation** - Automatically rotates between different ad networks
- **Multiple Interstitial Sources** - Cycles through all ad networks
- **Rewarded Video Ads** - Unity Ads and Appodeal integration
- **Smart Ad Management** - Unified ad manager for all networks
- **Test Mode Support** - Easy testing with test ad units

## Screenshots

### App Interface
- Splash screen with animated loading
- WebView with integrated banner ads
- Navigation controls and URL input
- Ad rotation between networks

## Installation & Setup

### Prerequisites
- Flutter 3.8.1 or higher
- Android Studio / Xcode for platform-specific development
- Active accounts with ad networks (for production)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd flutter_webview_ads
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Ad Networks

#### Google AdMob
1. Create an AdMob account at [admob.google.com](https://admob.google.com)
2. Replace test ad unit IDs in `lib/services/ad_manager.dart`
3. Update app IDs in platform-specific configurations

#### Unity Ads
1. Create a Unity account and project
2. Get your Game ID from Unity Dashboard
3. Update the game ID in `AdManager`

#### Start.io
1. Register at [start.io](https://start.io)
2. Get your App ID from the dashboard
3. Update the app ID in configuration files

#### Appodeal
1. Create an account at [appodeal.com](https://appodeal.com)
2. Get your App Key
3. Update the key in `AdManager`

### 4. Platform Configuration

#### Android Configuration
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Replace YOUR_APP_IDS with actual values -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID"/>
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="YOUR_START_IO_APP_ID"/>
<!-- Add other network configurations -->
```

#### iOS Configuration
Update `ios/Runner/Info.plist`:
```xml
<!-- Replace YOUR_APP_IDS with actual values -->
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>
<key>com.startapp.sdk.APPLICATION_ID</key>
<string>YOUR_START_IO_APP_ID</string>
<!-- Add other network configurations -->
```

### 5. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point with splash screen
├── services/
│   └── ad_manager.dart      # Unified ad network manager
├── screens/
│   └── webview_screen.dart  # Main WebView interface
└── widgets/
    └── ad_banner_widget.dart # Custom ad widgets
```

## Ad Network Integration Details

### AdMob Integration
- **Banner Ads**: 320x50 standard banners
- **Interstitial Ads**: Full-screen ads between content
- **Test Mode**: Uses Google's test ad unit IDs
- **Callbacks**: Complete ad lifecycle management

### Unity Ads Integration
- **Video Interstitials**: Skippable video ads
- **Rewarded Videos**: User reward system
- **Placement IDs**: Configurable ad placements
- **Callbacks**: Start, complete, skip, and error handling

### Start.io Integration
- **Banner Ads**: Various sizes supported
- **Interstitial Ads**: Full-screen display ads
- **Native Integration**: Flutter widget support
- **Test Mode**: Built-in test ad functionality

### Appodeal Integration
- **Mediation Platform**: Access to multiple ad networks
- **Banner, Interstitial, Rewarded**: All major formats
- **Waterfall Optimization**: Automatic eCPM optimization
- **Real-time Analytics**: Performance tracking

## Key Components

### AdManager Class
The `AdManager` is a singleton that handles all ad network operations:

```dart
// Initialize all ad networks
await AdManager().initialize();

// Load and show different ad types
await adManager.loadAdMobBanner();
await adManager.showAdMobInterstitial();
await adManager.loadAndShowUnityRewarded(onRewarded: () {
  // Handle user reward
});
```

### WebView Screen
Full-featured browser with:
- URL input and navigation
- Loading states and error handling
- Connectivity monitoring
- Integrated ad display
- Menu options for ad testing

### Ad Rotation System
Automatically rotates banner ads between networks every 30 seconds:
- AdMob → Start.io → Appodeal → repeat
- Smooth transitions between ad networks
- Fallback handling for failed loads

## Testing

### Test Mode
The app runs in test mode by default (`AdManager.testMode = true`):
- Uses test ad unit IDs
- Safe for development and testing
- No risk of invalid traffic

### Production Setup
For production release:
1. Set `testMode = false` in `AdManager`
2. Replace all test IDs with production ad unit IDs
3. Test thoroughly with real ads
4. Monitor ad performance and revenue

## Permissions

### Android Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID" />
<!-- Additional permissions for ad networks -->
```

### iOS Permissions
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location to provide better ads experience.</string>
```

## Monetization Strategy

### Ad Placement Strategy
1. **Banner Ads**: Persistent bottom banner with rotation
2. **Interstitial Ads**: Between major user actions
3. **Rewarded Videos**: Optional for premium features
4. **Smart Loading**: Preload ads for better user experience

### Revenue Optimization
- **Multiple Networks**: Maximize fill rate and eCPM
- **A/B Testing**: Test different ad placements
- **Analytics**: Monitor performance across networks
- **Waterfall Setup**: Optimize ad network priority

## Troubleshooting

### Common Issues

1. **Ad Not Loading**
   - Check internet connection
   - Verify ad unit IDs
   - Ensure test mode is enabled for testing

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check platform-specific configurations
   - Verify all dependencies are compatible

3. **Ad Network Initialization Failed**
   - Check API keys and app IDs
   - Verify network-specific setup requirements
   - Check console logs for detailed error messages

### Debug Mode
Enable debug logging to troubleshoot:
```dart
// In AdManager, debug prints are enabled in debug mode
if (kDebugMode) {
  print('AdManager: Detailed debug information');
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check documentation for each ad network
- Review Flutter WebView documentation

## Acknowledgments

- Flutter team for the excellent WebView plugin
- Google AdMob for comprehensive documentation
- Unity Ads for video ad integration
- Start.io for easy Flutter integration
- Appodeal for mediation platform

---

**Note**: This app uses test ad units by default. Replace with your own ad unit IDs for production use. Always comply with each ad network's policies and guidelines.
