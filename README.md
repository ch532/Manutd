# Connect Gold WebView App

A Flutter WebView application with integrated multiple ad networks including Google AdMob, Appodeal, Unity Ads, and Start.io.

## Features

- **WebView Integration**: Loads your website (https://connectgold.sbs) in a native WebView
- **Multiple Ad Networks**: Integrated support for 4 major ad networks
- **Banner Ads**: Displayed at the bottom of the screen
- **Interstitial Ads**: Shown every 3 page loads
- **Modern UI**: Clean and professional design
- **Error Handling**: Robust error handling and connectivity checks
- **Settings Panel**: Monitor ad network status and app information

## Integrated Ad Networks

1. **Google AdMob** - Google's mobile advertising platform
2. **Appodeal** - Unified ad mediation platform
3. **Unity Ads** - Unity's advertising solution
4. **Start.io** - Mobile advertising platform

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android SDK (API level 21+)
- iOS development tools (for iOS builds)

### 2. Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd flutter_webview_ads

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Ad Network Configuration

#### Google AdMob Setup

1. Create an AdMob account at https://admob.google.com
2. Create a new app in AdMob console
3. Replace the following IDs in `lib/services/ad_manager.dart`:

```dart
// Replace with your actual AdMob IDs
static const String _adMobAppId = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX';
static const String _adMobBannerId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
static const String _adMobInterstitialId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
static const String _adMobRewardedId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
```

4. Update the AndroidManifest.xml with your AdMob App ID:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXX~XXXXXXXXXX"/>
```

#### Appodeal Setup

1. Create an Appodeal account at https://appodeal.com
2. Create a new app in Appodeal dashboard
3. Replace the App Key in `lib/services/ad_manager.dart`:

```dart
static const String _appodealAppKey = 'your-appodeal-app-key';
```

4. Update the AndroidManifest.xml:

```xml
<meta-data
    android:name="com.appodeal.APPLICATION_KEY"
    android:value="your-appodeal-app-key" />
```

#### Unity Ads Setup

1. Create a Unity account and go to Unity Ads dashboard
2. Create a new project and get your Game ID
3. Replace the Game ID in `lib/services/ad_manager.dart`:

```dart
static const String _unityGameId = 'your-unity-game-id';
static const bool _unityTestMode = false; // Set to false for production
```

4. Update the AndroidManifest.xml:

```xml
<meta-data
    android:name="com.unity3d.ads.APPLICATION_ID"
    android:value="your-unity-game-id" />
```

#### Start.io Setup

1. Create a Start.io account at https://start.io
2. Create a new app and get your App ID
3. Replace the App ID in `lib/services/ad_manager.dart`:

```dart
static const String _startAppAppId = 'your-startapp-app-id';
```

4. Update the AndroidManifest.xml:

```xml
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="your-startapp-app-id" />
```

### 4. Website Configuration

The app is configured to load `https://connectgold.sbs` by default. To change the website:

1. Update the `initialUrl` in `lib/main.dart`:
```dart
initialUrl: 'https://your-website.com',
```

2. Update the home button URL in `lib/screens/webview_screen.dart`:
```dart
_webViewController.loadRequest(Uri.parse('https://your-website.com'));
```

### 5. Building for Production

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release
```

### 6. Testing

- Use test ad unit IDs during development
- Test on real devices for accurate ad behavior
- Monitor ad network status in the app's settings panel

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── services/
│   └── ad_manager.dart      # Ad network management
└── screens/
    └── webview_screen.dart  # Main WebView screen

android/
└── app/
    └── src/
        └── main/
            └── AndroidManifest.xml  # Android configuration

assets/
├── images/                  # App images
└── icons/                   # App icons
```

## Ad Network Features

### Banner Ads
- Displayed at the bottom of the WebView
- Randomly rotates between all 4 ad networks
- Automatic fallback if one network fails

### Interstitial Ads
- Shown every 3 page loads
- Randomly selects from available ad networks
- Non-intrusive user experience

### Ad Network Status
- Real-time status monitoring
- Available in app settings
- Shows initialization status for each network

## Permissions

The app requires the following permissions:

- `INTERNET` - For WebView and ad loading
- `ACCESS_NETWORK_STATE` - For connectivity checks
- `ACCESS_WIFI_STATE` - For network optimization
- `WRITE_EXTERNAL_STORAGE` - For ad caching
- `READ_EXTERNAL_STORAGE` - For ad assets
- `READ_PHONE_STATE` - For ad targeting
- `ACCESS_COARSE_LOCATION` - For location-based ads
- `ACCESS_FINE_LOCATION` - For precise location ads
- `VIBRATE` - For ad interactions
- `AD_ID` - For advertising ID access

## Troubleshooting

### Common Issues

1. **Ads not showing**: Check ad network initialization in settings
2. **WebView not loading**: Verify internet connection and URL
3. **App crashes**: Check ad network configurations
4. **Build errors**: Ensure all dependencies are properly configured

### Debug Mode

Enable debug logging by checking the console output for ad network initialization messages.

## Support

For issues related to:
- **AdMob**: Check [AdMob Documentation](https://developers.google.com/admob/flutter/quick-start)
- **Appodeal**: Check [Appodeal Documentation](https://wiki.appodeal.com/en/flutter/get-started)
- **Unity Ads**: Check [Unity Ads Documentation](https://docs.unity.com/ads/en-us/manual/Flutter)
- **Start.io**: Check [Start.io Documentation](https://developers.startapp.com/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Version History

- **v1.0.0**: Initial release with WebView and 4 ad networks
- Multiple ad network integration
- Modern UI design
- Error handling and connectivity checks