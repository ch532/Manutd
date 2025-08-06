#!/bin/bash

# Connect Gold WebView App Build Script
# This script helps with building and managing the Flutter app

echo "🚀 Connect Gold WebView App Build Script"
echo "=========================================="

# Function to check if Flutter is installed
check_flutter() {
    if command -v flutter &> /dev/null; then
        echo "✅ Flutter is installed"
        flutter --version
        return 0
    else
        echo "❌ Flutter is not installed"
        echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
        return 1
    fi
}

# Function to get dependencies
get_dependencies() {
    echo "📦 Getting Flutter dependencies..."
    flutter pub get
}

# Function to analyze the project
analyze_project() {
    echo "🔍 Analyzing project..."
    flutter analyze
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    flutter test
}

# Function to build for Android
build_android() {
    echo "🤖 Building for Android..."
    flutter build apk --release
    echo "✅ Android APK built successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
}

# Function to build for iOS
build_ios() {
    echo "🍎 Building for iOS..."
    flutter build ios --release
    echo "✅ iOS build completed!"
}

# Function to run the app
run_app() {
    echo "▶️  Running the app..."
    flutter run
}

# Function to clean the project
clean_project() {
    echo "🧹 Cleaning project..."
    flutter clean
    flutter pub get
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  check     - Check if Flutter is installed"
    echo "  deps      - Get dependencies"
    echo "  analyze   - Analyze the project"
    echo "  test      - Run tests"
    echo "  android   - Build for Android"
    echo "  ios       - Build for iOS"
    echo "  run       - Run the app"
    echo "  clean     - Clean the project"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check    # Check Flutter installation"
    echo "  $0 deps     # Install dependencies"
    echo "  $0 android  # Build Android APK"
    echo "  $0 run      # Run the app"
}

# Main script logic
case "$1" in
    "check")
        check_flutter
        ;;
    "deps")
        if check_flutter; then
            get_dependencies
        fi
        ;;
    "analyze")
        if check_flutter; then
            analyze_project
        fi
        ;;
    "test")
        if check_flutter; then
            run_tests
        fi
        ;;
    "android")
        if check_flutter; then
            get_dependencies
            build_android
        fi
        ;;
    "ios")
        if check_flutter; then
            get_dependencies
            build_ios
        fi
        ;;
    "run")
        if check_flutter; then
            get_dependencies
            run_app
        fi
        ;;
    "clean")
        if check_flutter; then
            clean_project
        fi
        ;;
    "help"|*)
        show_help
        ;;
esac

echo ""
echo "🎉 Script completed!"