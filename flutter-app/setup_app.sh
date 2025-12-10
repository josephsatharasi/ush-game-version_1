#!/bin/bash

echo "🚀 Setting up Ushh app..."

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Generate app icons for all platforms
echo "🎨 Generating app icons..."
flutter pub run flutter_launcher_icons

echo "✅ Setup complete!"
echo ""
echo "📱 App name: Ushh"
echo "🎯 App icon: assets/images/ushh_appicon.png"
echo "📍 Location permissions: Added for all platforms"
echo ""
echo "To build the app:"
echo "  Android: flutter build apk"
echo "  iOS: flutter build ios"
echo "  Web: flutter build web"
echo "  Windows: flutter build windows"
echo "  macOS: flutter build macos"