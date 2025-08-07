# Configuration Guide

This guide will help you configure all ad networks for the Connect Gold WebView app.

## Quick Setup Checklist

- [ ] Google AdMob setup
- [ ] Appodeal setup  
- [ ] Unity Ads setup
- [ ] Start.io setup
- [ ] Update configuration files
- [ ] Test the app

## 1. Google AdMob Setup

### Step 1: Create AdMob Account
1. Go to https://admob.google.com/
2. Sign in with your Google account
3. Accept the terms and conditions

### Step 2: Create App
1. Click "Apps" in the left sidebar
2. Click "Add app"
3. Select "Android" or "iOS"
4. Enter app name: "Connect Gold"
5. Click "Add"

### Step 3: Get App ID
1. Copy the App ID (format: ca-app-pub-XXXXXXXXXX~XXXXXXXXXX)
2. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="YOUR_APP_ID_HERE"/>
   ```

### Step 4: Create Ad Units
1. Go to "Ad units" tab
2. Create Banner ad unit
3. Create Interstitial ad unit  
4. Create Rewarded ad unit
5. Copy the ad unit IDs

### Step 5: Update Ad Manager
Update `lib/services/ad_manager.dart`:
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

## 2. Appodeal Setup

### Step 1: Create Account
1. Go to https://appodeal.com/
2. Sign up for an account
3. Verify your email

### Step 2: Create App
1. Click "Add App"
2. Select platform (Android/iOS)
3. Enter app details
4. Get your App Key

### Step 3: Update Configuration
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.appodeal.APPLICATION_KEY"
    android:value="YOUR_APPODEAL_APP_KEY" />
```

Update `lib/services/ad_manager.dart`:
```dart
final String _appodealAppKey = 'YOUR_APPODEAL_APP_KEY';
```

## 3. Unity Ads Setup

### Step 1: Create Unity Account
1. Go to https://unity.com/
2. Create an account
3. Verify your email

### Step 2: Create Project
1. Go to Unity Dashboard
2. Create a new project
3. Get your Game ID

### Step 3: Update Configuration
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.unity3d.ads.APPLICATION_ID"
    android:value="YOUR_UNITY_GAME_ID" />
```

Update `lib/services/ad_manager.dart`:
```dart
final String _unityGameId = 'YOUR_UNITY_GAME_ID';
```

## 4. Start.io Setup

### Step 1: Create Account
1. Go to https://www.start.io/
2. Sign up for an account
3. Verify your email

### Step 2: Create App
1. Click "Add App"
2. Select platform
3. Enter app details
4. Get your App ID

### Step 3: Update Configuration
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="YOUR_STARTIO_APP_ID" />
```

Update `lib/services/ad_manager.dart`:
```dart
final String _startioAppId = 'YOUR_STARTIO_APP_ID';
```

## 5. Testing Configuration

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Test Ad Networks
1. Open the app
2. Navigate to the menu (three dots)
3. Select "Ad Networks Info"
4. Check that all networks show as initialized

### Step 3: Test Individual Ads
1. Tap the ads icon in bottom navigation
2. Test each ad type:
   - Interstitial Ad
   - Rewarded Ad
   - Appodeal Interstitial
   - Unity Ads
   - Start.io Interstitial

## 6. Production Checklist

Before releasing to production:

- [ ] Replace all test ad unit IDs with real ones
- [ ] Update all app keys/IDs with production values
- [ ] Test ads on real devices (not emulator)
- [ ] Verify ad revenue tracking
- [ ] Test app performance
- [ ] Configure app signing
- [ ] Test on different Android versions
- [ ] Verify website loading properly

## 7. Troubleshooting

### Ads Not Showing
- Check internet connection
- Verify ad unit IDs are correct
- Ensure app is not in debug mode for production ads
- Check ad network console for any issues

### App Crashes
- Check all app keys are properly configured
- Verify AndroidManifest.xml syntax
- Check Flutter dependencies are up to date

### WebView Issues
- Verify website URL is accessible
- Check JavaScript is enabled
- Test on different devices

## 8. Support Resources

- **AdMob**: https://developers.google.com/admob/flutter/quick-start
- **Appodeal**: https://wiki.appodeal.com/en/flutter/get-started
- **Unity Ads**: https://docs.unity.com/ads/en-us/manual/MonetizationAdsUnityAdsIntegrationGuide
- **Start.io**: https://support.start.io/hc/en-us

## 9. Revenue Optimization

### Best Practices
1. **Ad Placement**: Don't overwhelm users with too many ads
2. **Ad Timing**: Space out interstitial ads appropriately
3. **User Experience**: Ensure ads don't interfere with content
4. **Testing**: Regularly test ad performance
5. **Analytics**: Monitor ad revenue and user engagement

### Ad Network Priority
Consider implementing waterfall bidding:
1. AdMob (highest priority)
2. Appodeal
3. Unity Ads
4. Start.io (fallback)

This ensures maximum fill rate and revenue optimization.