#!/bin/bash

echo "🚀 Starting GitHub Release Update..."

cd /Users/sakinburakcivelek/flutter_projects/price_list

echo "🧹 Cleaning..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🌍 Generating localizations..."
flutter gen-l10n

echo "🗑️ Deleting old assets..."
gh release delete-asset v2.5.0 price_list_android_v2.5.0.apk --yes || true
gh release delete-asset v2.5.0 price_list_macos_v2.5.0.zip --yes || true

echo "🤖 Building Android..."
flutter build apk --release

echo "🍎 Building macOS..."
flutter build macos --release

echo "📦 Creating macOS zip..."
cd build/macos/Build/Products/Release
zip -r ../../../../../price_list_macos_v2.5.0.zip price_list.app
cd ../../../../../

echo "📤 Uploading assets..."
gh release upload v2.5.0 build/app/outputs/flutter-apk/app-free-release.apk --clobber
gh release upload v2.5.0 price_list_macos_v2.5.0.zip --clobber

echo "✅ Done!"
gh release view v2.5.0