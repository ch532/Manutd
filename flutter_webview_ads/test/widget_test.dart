// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webview_ads/main.dart';

void main() {
  testWidgets('WebView Ads app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WebViewAdsApp());

    // The app should show the splash screen initially
    expect(find.text('WebView Ads'), findsOneWidget);
    expect(find.text('Initializing ad networks...'), findsOneWidget);
    
    // Check for ad network chips
    expect(find.text('AdMob'), findsOneWidget);
    expect(find.text('Unity Ads'), findsOneWidget);
    expect(find.text('Start.io'), findsOneWidget);
    expect(find.text('Appodeal'), findsOneWidget);
  });
}
