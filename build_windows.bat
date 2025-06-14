@echo off
echo ========================================
echo    Price List Windows Build Script
echo ========================================
echo.

REM Proje hazırlığı
echo [1/5] Proje temizleniyor...
flutter clean
if %errorlevel% neq 0 (
    echo HATA: Flutter clean başarısız!
    pause
    exit /b 1
)

echo [2/5] Bağımlılıklar yükleniyor...
flutter pub get
if %errorlevel% neq 0 (
    echo HATA: Flutter pub get başarısız!
    pause
    exit /b 1
)

echo [3/5] Windows desktop desteği etkinleştiriliyor...
flutter config --enable-windows-desktop
if %errorlevel% neq 0 (
    echo HATA: Windows desktop yapılandırması başarısız!
    pause
    exit /b 1
)

echo [4/5] Windows release build'i oluşturuluyor...
flutter build windows --release
if %errorlevel% neq 0 (
    echo HATA: Windows build başarısız!
    pause
    exit /b 1
)

echo [5/5] Zip arşivi oluşturuluyor...
powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'price_list_windows_v2.1.0.zip' -Force"
if %errorlevel% neq 0 (
    echo HATA: Zip oluşturma başarısız!
    pause
    exit /b 1
)

echo.
echo ========================================
echo        BUILD BAŞARIYLA TAMAMLANDI!
echo ========================================
echo.
echo Oluşturulan dosyalar:
echo - price_list_windows_v2.1.0.zip
echo - build\windows\x64\runner\Release\ klasörü
echo.
echo GitHub Release güncellemesi için:
echo gh release delete-asset v2.0.0 price_list_windows_v2.0.0.zip --yes
echo gh release upload v2.0.0 price_list_windows_v2.1.0.zip
echo.
pause