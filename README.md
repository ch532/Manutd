# Connect Gold WebView App

A Flutter WebView application with integrated multiple ad networks (AdMob, Appodeal, Unity Ads, and Start.io) that loads your website at https://connectgold.sbs.

## Features

- **WebView Integration**: Seamless web browsing experience
- **Multiple Ad Networks**: Integrated support for:
  - Google AdMob
  - Appodeal
  - Unity Ads
  - Start.io
- **Ad Types**: Banner, Interstitial, and Rewarded ads
- **Smart Ad Display**: Automatic ad scheduling based on page views
- **Navigation Controls**: Back, forward, home, and refresh buttons
- **Ad Testing**: Built-in ad testing interface
- **Network Status**: Real-time ad network initialization status

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android SDK (API level 21+)
- iOS development setup (for iOS builds)

### 2. Installation

1. Clone or download this project
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### 3. Ad Network Configuration

#### Google AdMob
1. Create an AdMob account at https://admob.google.com/
2. Create a new app in AdMob console
3. Get your App ID and ad unit IDs
4. Update the following files:
   - `android/app/src/main/AndroidManifest.xml`: Replace the AdMob App ID
   - `lib/services/ad_manager.dart`: Replace test ad unit IDs with your real ones

#### Appodeal
1. Create an Appodeal account at https://appodeal.com/
2. Create a new app in Appodeal dashboard
3. Get your App Key
4. Update `android/app/src/main/AndroidManifest.xml` with your Appodeal App Key

#### Unity Ads
1. Create a Unity account at https://unity.com/
2. Create a new project in Unity dashboard
3. Get your Game ID
4. Update `android/app/src/main/AndroidManifest.xml` with your Unity Game ID

#### Start.io
1. Create a Start.io account at https://www.start.io/
2. Create a new app in Start.io dashboard
3. Get your App ID
4. Update `android/app/src/main/AndroidManifest.xml` with your Start.io App ID

### 4. Configuration Files

#### AndroidManifest.xml
The file already contains placeholder values. Replace them with your actual IDs:

```xml
<!-- Google AdMob App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXX~XXXXXXXXXX"/>

<!-- Start.io App ID -->
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="YOUR_STARTIO_APP_ID" />

<!-- Unity Ads Game ID -->
<meta-data
    android:name="com.unity3d.ads.APPLICATION_ID"
    android:value="YOUR_UNITY_GAME_ID" />

<!-- Appodeal App Key -->
<meta-data
    android:name="com.appodeal.APPLICATION_KEY"
    android:value="YOUR_APPODEAL_APP_KEY" />
```

#### Ad Manager Configuration
Update `lib/services/ad_manager.dart` with your ad unit IDs:

```dart
final Map<String, String> _adUnitIds = {
  'android': {
    'admob_banner': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    'admob_interstitial': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    'admob_rewarded': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
  },
  'ios': {
    'admob_banner': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    'admob_interstitial': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    'admob_rewarded': 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
  },
};
```

### 5. Build and Run

#### Android
```bash
flutter build apk --release
flutter install
```

#### iOS
```bash
flutter build ios --release
```

## App Structure

```
lib/
├── main.dart                 # Main app entry point
├── services/
│   └── ad_manager.dart      # Ad network management
└── screens/
    └── webview_screen.dart  # Main WebView screen
```

## Features Overview

### WebView Features
- Full web browsing experience
- JavaScript enabled
- External link handling
- Loading indicators
- Navigation controls

### Ad Integration
- **Banner Ads**: Displayed at the bottom of the screen
- **Interstitial Ads**: Show every 3 page views
- **Rewarded Ads**: Show every 5 page views
- **Ad Testing**: Built-in test interface for all ad networks

### Navigation
- Back/Forward buttons
- Home button (returns to connectgold.sbs)
- Refresh button
- Menu with additional options

### Ad Testing
Tap the ads icon in the bottom navigation to access:
- Interstitial ad testing
- Rewarded ad testing
- Appodeal ad testing
- Unity Ads testing
- Start.io ad testing

## Ad Network Status

The app includes a status checker that shows the initialization status of all ad networks:
- ✅ AdMob
- ✅ Appodeal
- ✅ Unity Ads
- ✅ Start.io

## Permissions

The app requires the following permissions:
- Internet access
- Network state access
- Location access (for targeted ads)
- Phone state access
- External storage access

## Troubleshooting

### Common Issues

1. **Ads not showing**: Check your ad network configuration and ensure you're using real ad unit IDs
2. **App crashes on startup**: Verify all ad network keys are properly configured
3. **WebView not loading**: Check internet connectivity and website availability

### Debug Mode

For testing, the app uses test ad unit IDs. Replace them with real IDs for production.

## Production Checklist

- [ ] Replace all test ad unit IDs with real ones
- [ ] Update all ad network app keys/IDs
- [ ] Test ads on real devices
- [ ] Configure ad targeting settings
- [ ] Set up ad revenue tracking
- [ ] Test app performance with ads
- [ ] Configure app signing for release

## Support

For issues related to:
- **AdMob**: Check [AdMob documentation](https://developers.google.com/admob/flutter/quick-start)
- **Appodeal**: Check [Appodeal documentation](https://wiki.appodeal.com/en/flutter/get-started)
- **Unity Ads**: Check [Unity Ads documentation](https://docs.unity.com/ads/en-us/manual/MonetizationAdsUnityAdsIntegrationGuide)
- **Start.io**: Check [Start.io documentation](https://support.start.io/hc/en-us)

## License

This project is licensed under the MIT License.