# Price List Calculator

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)

> **Language Options / Dil Seçenekleri:**  
> 🇹🇷 [Türkçe](README.md) | 🇺🇸 [English](README_EN.md)

A currency-based price calculation application. Calculate original prices in USD, EUR, and TL currencies with multiple discount and profit margin calculations.

## 📋 Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Usage](#usage)
- [Feature Details](#feature-details)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### 💱 Currency Support
- **Real-time Rates**: Automatic currency rate fetching from İş Bank
- **Multi-currency**: USD ($), EUR (€), and TL (₺) support
- **Manual Rate Entry**: Optional manual exchange rate editing

### 🧮 Advanced Calculation
- **Multiple Discounts**: Apply up to 3 different discount rates
- **Profit Margin**: Flexible profit margin calculation
- **VAT Calculation**: Automatic 20% VAT included price calculation
- **Tax Included Price**: Purchase price + 20% tax calculation

### 🔒 Security
- **PIN Protection**: Protect purchase prices with PIN
- **Privacy**: Secure storage of sensitive information
- **PIN Update**: Ability to change PIN code

### 💾 Preset System
- **Save Settings**: Save frequently used discount combinations
- **Quick Apply**: Apply saved settings with one click
- **Preset Management**: Edit and delete saved settings

### 🌍 Multi-language Support
- **Turkish** and **English** interface
- **Dynamic Translation**: Change language within the app
- **Localization**: Date and currency formats

### 📱 Platform Support
- **Android**: Full feature support
- **iOS**: Full feature support  
- **macOS**: Desktop support
- **Windows**: Desktop support

## 📱 Screenshots

### Main Screen
```
┌─────────────────────────────────────┐
│ 💱 Exchange Rates                   │
│ USD: 34.25 ₺  EUR: 37.18 ₺         │
│                                     │
│ 🏷️ Product Pricing                  │
│ Original Price: [_____] $           │
│ Currency: [USD] [EUR] [TL]          │
│                                     │
│ ⚙️ Discounts and Profit Settings    │
│ Discount 1: 45%  Discount 2: 10%    │
│ Discount 3: 0%   Profit Margin: 40% │
│                                     │
│ 📊 Calculation Results              │
│ Converted Price: 3,425.00 ₺        │
│ Sale Price: 1,918.20 ₺             │
│ VAT Included: 2,301.84 ₺           │
└─────────────────────────────────────┘
```

## 🚀 Installation

### 📦 Ready Application Download

#### 🤖 Android
1. Download `price_list_android_v2.0.0.apk` from [Releases page](https://github.com/amITranquil/price_list/releases)
2. Enable "Unknown sources" option in phone settings
3. Run and install the APK file

#### 🍎 macOS
1. Download `price_list_macos_v2.0.0.zip` from [Releases page](https://github.com/amITranquil/price_list/releases)
2. Extract the ZIP file
3. Drag `Price List.app` file to Applications folder
4. Grant permission from "Security & Privacy" settings on first launch

#### 🪟 Windows
1. Download `price_list_windows_v2.0.0.zip` from [Releases page](https://github.com/amITranquil/price_list/releases)
2. Extract the ZIP file to your desired folder
3. Run `price_list.exe` file
4. If Windows Defender warning appears on first launch, click "Run anyway"

### 🛠️ Developer Installation

#### Requirements

- **Flutter SDK**: 3.2.5 or higher
- **Dart SDK**: 3.2.5 or higher
- **Android Studio** / **VS Code**
- **Git**

#### Steps

1. **Clone the project**
```bash
git clone https://github.com/amITranquil/price_list.git
cd price_list
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run
```

### Platform Specific Installation

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

## 📖 Usage

### Initial Setup

1. **PIN Creation**: When you first open the app, you'll be asked to create a PIN code
2. **Language Selection**: You can select Turkish/English from the language icon in the top right corner

### Basic Usage

#### 1. Checking Exchange Rates
- The app automatically fetches current rates
- Click the 🔄 icon to refresh rates
- You can manually edit rates if desired

#### 2. Price Calculation
```
1. Enter the original price (e.g., 100)
2. Select the currency (USD/EUR/TL)
3. Set discount rates
4. Determine profit margin
5. Click "Calculate Price" button
```

#### 3. Discount and Profit Settings
- **Discount 1-3**: Sequential discount application
- **Profit Margin**: Add profit on net purchase price
- **Default Values**: Discount 45%-10%-0%, Profit 40%

#### 4. Viewing Results
- **Converted Price**: Original price × Exchange rate
- **Purchase Price**: Price after discounts applied (PIN required)
- **Sale Price**: Price with profit margin added
- **VAT Included**: Final price with 20% VAT added

### Advanced Features

#### Preset System

1. **Saving Presets**:
   - Set your discount and profit settings
   - Enter preset name at the bottom
   - Click "Save Current Values" button

2. **Using Presets**:
   - Select your saved preset from dropdown menu
   - Settings are automatically applied

3. **Deleting Presets**:
   - Select the preset to delete
   - Click "Delete Selected" button

#### PIN Protection

1. **Viewing Purchase Price**:
   - Enter your PIN code
   - Click "Show" button

2. **Changing PIN**:
   - Click the ⚙️ icon in the top right corner
   - Enter current PIN
   - Set new PIN

## 🔧 Feature Details

### Calculation Formula

```dart
// 1. Currency conversion
convertedPrice = originalPrice × exchangeRate

// 2. Discount application (sequential)
price1 = originalPrice × (1 - discount1/100)
price2 = price1 × (1 - discount2/100)
price3 = price2 × (1 - discount3/100)

// 3. Purchase price (with exchange rate)
purchasePrice = price3 × exchangeRate

// 4. Tax included purchase
purchaseTaxIncluded = purchasePrice × 1.20

// 5. Adding profit margin
salePrice = purchasePrice × (1 + profitMargin/100)

// 6. VAT included sale
vatIncludedPrice = salePrice × 1.20
```

### Data Storage

- **Hive Database**: Local data storage
- **PIN Encryption**: Secure PIN storage
- **Preset Management**: User settings
- **Language Preference**: Selected language storage

### API Integration

- **İş Bank API**: Real-time exchange rates
- **HTML Parsing**: Currency data extraction
- **Error Handling**: Fallback on connection errors

## 🛠 Development

### Project Structure

```
lib/
├── main.dart              # Application entry point
├── l10n/                  # Multi-language files
│   ├── app_en.arb        # English translations
│   └── app_tr.arb        # Turkish translations
├── screens/               # Screen widgets
│   ├── price_calculator_screen.dart
│   ├── create_pin_page.dart
│   └── update_pin_page.dart
└── utils/                 # Helper classes
    └── database_helper.dart
```

### Dependencies

```yaml
dependencies:
  flutter_localizations: # Multi-language support
  intl: ^0.19.0          # Number formatting
  http: ^1.2.2           # API calls
  html: ^0.15.4          # HTML parsing
  window_manager: ^0.4.2  # Desktop window management
  hive: ^2.2.0           # Local database
  hive_flutter: ^1.1.0   # Flutter integration
```

### Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

### Building

```bash
# Debug build
flutter run

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release

# Release build (macOS)
flutter build macos --release

# Release build (Windows)
flutter build windows --release
```

## 🤝 Contributing

### Contribution Process

1. **Fork** the project
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)
5. **Open Pull Request**

### Development Rules

- Follow **Flutter/Dart** standards
- Write **tests**
- Update **documentation**
- Make **commit messages** descriptive

### Issue Reporting

Use [GitHub Issues](https://github.com/amITranquil/price_list/issues) for bug reports or feature requests.

## 📄 License

This project is for private use. Commercial use is prohibited.

## 📞 Contact

- **GitHub**: [@amITranquil](https://github.com/amITranquil)
- **Project Link**: [https://github.com/amITranquil/price_list](https://github.com/amITranquil/price_list)

## 🔄 Version History

### v2.0.0 (Current)
- ✅ TL currency support added
- ✅ Dynamic currency symbols
- ✅ Improved user interface
- ✅ Enhanced multi-language support
- ✅ Windows desktop platform support
- ✅ Unified release for all platforms

### v1.0.2
- ✅ macOS icon issues fixed
- ✅ Flavor implementation
- ✅ Windows and macOS optimizations

### v1.0.0
- ✅ Initial release
- ✅ Basic calculation features
- ✅ PIN protection
- ✅ Preset system

---

*This application was developed using the Flutter framework.*