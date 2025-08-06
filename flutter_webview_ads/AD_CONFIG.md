# Ad Network Configuration Guide

This guide will help you configure the ad networks with your actual IDs.

## 🔧 Configuration Steps

### 1. Google AdMob Configuration

1. **Create AdMob Account**
   - Go to https://admob.google.com
   - Sign up for a new account
   - Create a new app

2. **Get Your IDs**
   - App ID: `ca-app-pub-XXXXXXXXXX~XXXXXXXXXX`
   - Banner Ad Unit ID: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`
   - Interstitial Ad Unit ID: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`
   - Rewarded Ad Unit ID: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`

3. **Update Files**
   - Replace IDs in `lib/services/ad_manager.dart`:
   ```dart
   static const String _adMobAppId = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX';
   static const String _adMobBannerId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
   static const String _adMobInterstitialId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
   static const String _adMobRewardedId = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
   ```
   
   - Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXX~XXXXXXXXXX"/>
   ```

### 2. Appodeal Configuration

1. **Create Appodeal Account**
   - Go to https://appodeal.com
   - Sign up for a new account
   - Create a new app

2. **Get Your App Key**
   - App Key: `your-appodeal-app-key`

3. **Update Files**
   - Replace in `lib/services/ad_manager.dart`:
   ```dart
   static const String _appodealAppKey = 'your-appodeal-app-key';
   ```
   
   - Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.appodeal.APPLICATION_KEY"
       android:value="your-appodeal-app-key" />
   ```

### 3. Unity Ads Configuration

1. **Create Unity Account**
   - Go to https://unity.com
   - Sign up for a new account
   - Go to Unity Ads dashboard

2. **Get Your Game ID**
   - Game ID: `your-unity-game-id`

3. **Update Files**
   - Replace in `lib/services/ad_manager.dart`:
   ```dart
   static const String _unityGameId = 'your-unity-game-id';
   static const bool _unityTestMode = false; // Set to false for production
   ```
   
   - Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.unity3d.ads.APPLICATION_ID"
       android:value="your-unity-game-id" />
   ```

### 4. Start.io Configuration

1. **Create Start.io Account**
   - Go to https://start.io
   - Sign up for a new account
   - Create a new app

2. **Get Your App ID**
   - App ID: `your-startapp-app-id`

3. **Update Files**
   - Replace in `lib/services/ad_manager.dart`:
   ```dart
   static const String _startAppAppId = 'your-startapp-app-id';
   ```
   
   - Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.startapp.sdk.APPLICATION_ID"
       android:value="your-startapp-app-id" />
   ```

## 🧪 Testing Configuration

### Test Ad Unit IDs

For testing purposes, you can use these test IDs:

**AdMob Test IDs:**
- App ID: `ca-app-pub-3940256099942544~3347511713`
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

**Appodeal Test Key:**
- `dee74c5129f53fc629a44a690a02296694eb74e47e91b6e8`

**Unity Ads Test Game ID:**
- `1234567`

**Start.io Test App ID:**
- `203002564`

## 🔍 Verification Steps

1. **Check Ad Network Status**
   - Run the app
   - Go to Settings → Ad Networks Status
   - Verify all networks show ✓ (checkmark)

2. **Test Banner Ads**
   - Banner ads should appear at the bottom
   - Should rotate between different networks

3. **Test Interstitial Ads**
   - Navigate through 3 pages
   - Interstitial ad should appear

4. **Check Console Logs**
   - Look for initialization messages
   - Verify no error messages

## 🚀 Production Deployment

### Before Going Live:

1. **Replace Test IDs**
   - Use your actual production IDs
   - Set `_unityTestMode = false`

2. **Update App Information**
   - Change app name in `pubspec.yaml`
   - Update package name if needed
   - Update app icon

3. **Build for Production**
   ```bash
   ./build.sh android  # For Android APK
   ./build.sh ios      # For iOS build
   ```

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21
- Target SDK: 33
- All permissions are already configured

### iOS
- Minimum iOS version: 11.0
- Add required frameworks in Xcode
- Configure Info.plist for ad networks

## 🛠️ Troubleshooting

### Common Issues:

1. **Ads not showing**
   - Check internet connection
   - Verify ad network initialization
   - Check console for error messages

2. **App crashes on startup**
   - Verify all ad network configurations
   - Check AndroidManifest.xml syntax
   - Ensure all dependencies are installed

3. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check for missing dependencies

### Debug Commands:
```bash
./build.sh check    # Check Flutter installation
./build.sh deps     # Install dependencies
./build.sh analyze  # Analyze project
./build.sh clean    # Clean and rebuild
```

## 📞 Support

- **AdMob**: https://developers.google.com/admob/flutter/quick-start
- **Appodeal**: https://wiki.appodeal.com/en/flutter/get-started
- **Unity Ads**: https://docs.unity.com/ads/en-us/manual/Flutter
- **Start.io**: https://developers.startapp.com/

## 📋 Checklist

- [ ] AdMob IDs configured
- [ ] Appodeal App Key configured
- [ ] Unity Ads Game ID configured
- [ ] Start.io App ID configured
- [ ] AndroidManifest.xml updated
- [ ] Test ads working
- [ ] Production IDs ready
- [ ] App built successfully
- [ ] Tested on real device