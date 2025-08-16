#!/bin/bash

VERSION="v2.6.0"
echo "🚀 Starting GitHub Release Update for ${VERSION}..."

cd /Users/sakinburakcivelek/flutter_projects/price_list

echo "🧹 Cleaning..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🌍 Generating localizations..."
flutter gen-l10n

echo "📝 Updating existing release..."
gh release edit ${VERSION} --notes "$(cat <<'EOF'
# Price List Calculator v2.6.0

## 🚀 Enhanced User Experience & Input Improvements

### ✨ New Features
- **Automatic Comma-to-Dot Conversion** - All numeric inputs now automatically convert commas to dots for decimal notation
- **Always Visible Sale Price** - Sale price is now displayed without requiring PIN authentication
- **Selectable Price Values** - All price amounts are now selectable/copyable for easy sharing
- **Enhanced PIN Dialog** - Auto-focus on PIN input field with Enter key support for quick access
- **Exchange Rate Display** - Shows which exchange rate was used for currency conversion

### 🎨 UI/UX Improvements
- **Improved Input Experience** - Seamless decimal input across all numeric fields (price, discounts, exchange rates)
- **Better Price Visibility** - Reorganized price display order: Purchase → Purchase+VAT → Sale → Sale+VAT
- **Enhanced Accessibility** - Selectable text for all calculated values
- **Streamlined PIN Flow** - Faster PIN entry with keyboard shortcuts

### 🔧 Technical Enhancements
- **Reusable Text Input Helper** - Created TextInputHelpers utility for comma-to-dot conversion
- **Extended Price Calculation Result** - Added exchange rate and currency information to calculation results
- **Improved Results Display** - Enhanced calculation results card with rate information

### 📱 User Experience
- **Faster Workflow** - Reduced clicks and improved input flow for better productivity
- **Better Data Sharing** - Selectable price values for easy copying to other applications
- **Clearer Information** - Exchange rate transparency in conversion results

**Latest Update**: Enhanced input handling and improved price visibility for better user experience
EOF
)"

echo "🗑️ Deleting old assets..."
gh release delete-asset ${VERSION} price_list_android_${VERSION}.apk --yes || true
gh release delete-asset ${VERSION} price_list_macos_${VERSION}.zip --yes || true

echo "🤖 Building Android..."
flutter build apk --release

echo "🍎 Building macOS..."
flutter build macos --release

echo "📦 Creating macOS zip..."
cd build/macos/Build/Products/Release
zip -r ../../../../../price_list_macos_${VERSION}.zip price_list.app
cd ../../../../../

echo "📤 Uploading assets..."
# Check which APK file exists and upload it
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    gh release upload ${VERSION} build/app/outputs/flutter-apk/app-release.apk#price_list_android_${VERSION}.apk --clobber
elif [ -f "build/app/outputs/flutter-apk/app-free-release.apk" ]; then
    gh release upload ${VERSION} build/app/outputs/flutter-apk/app-free-release.apk#price_list_android_${VERSION}.apk --clobber
else
    echo "❌ No APK file found in build/app/outputs/flutter-apk/"
    exit 1
fi
gh release upload ${VERSION} price_list_macos_${VERSION}.zip --clobber

echo "✅ Done!"
gh release view ${VERSION}