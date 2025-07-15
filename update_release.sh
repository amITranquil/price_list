#!/bin/bash

VERSION="v2.5.0"
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
# Price List Calculator v2.5.0

## 🚀 Major Updates - SOLID/DRY Refactoring

### ✨ New Features
- **3 Separate Discount Fields** - Replace single discount with discount1, discount2, discount3
- **Profit Margin Field** - Dedicated profitMargin field for better control
- **Enhanced Edit Dialog** - Edit all calculation fields (price, currency, discounts, profit margin)
- **Bulk Update with Current Rates** - Single button to update all records with current exchange rates
- **Improved PIN Management** - Fixed hardcoded PIN 1234 issue

### 🏗️ Architecture Improvements
- **CalculationHelper Class** - Centralized calculation methods following DRY principle
- **SOLID Principles** - Better separation of concerns and code organization
- **Backward Compatibility** - Existing data automatically migrated to new structure
- **Code Deduplication** - Eliminated repetitive calculation code across components

### 🎨 UI/UX Enhancements
- **Optimized Card Spacing** - Better layout for 1920x1080 resolution
- **Enhanced Record Editing** - Full field editing capabilities
- **Improved Bulk Operations** - Confirmation dialogs and better feedback
- **Better Error Handling** - More robust validation and error messages

### 🔧 Technical Details
- New CalculationRecord model with individual discount fields
- Centralized calculation logic in CalculationHelper
- Enhanced repository pattern with proper data mapping
- Improved state management across all providers
- Better type safety and validation

### 🐛 Bug Fixes
- Fixed hardcoded PIN 1234 security issue
- Resolved calculation inconsistencies
- Better handling of edge cases in discount calculations
- Improved memory management and performance

**Latest Update**: Enhanced with 3-field discount system and centralized calculations
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