@echo off
echo ========================================
echo    Price List Windows Build Script
echo ========================================
echo.

REM Proje hazırlığı
echo [1/5] Proje temizleniyor...
flutter clean
if %errorlevel% neq 0 (
    echo HATA: Flutter clean başarısız! Devam ediliyor...
    echo.
) else (
    echo ✓ Proje temizleme başarılı
    echo.
)

echo [2/5] Bağımlılıklar yükleniyor...
flutter pub get
if %errorlevel% neq 0 (
    echo HATA: Flutter pub get başarısız!
    echo Bu adım başarısız olursa build devam edemez!
    pause
    exit /b 1
) else (
    echo ✓ Bağımlılıklar başarıyla yüklendi
    echo.
)

echo [3/5] Windows desktop desteği etkinleştiriliyor...
flutter config --enable-windows-desktop
if %errorlevel% neq 0 (
    echo UYARI: Windows desktop yapılandırması başarısız! Devam ediliyor...
    echo.
) else (
    echo ✓ Windows desktop desteği etkinleştirildi
    echo.
)

echo [4/5] Windows release build'i oluşturuluyor...
echo Bu işlem birkaç dakika sürebilir...
flutter build windows --release
if %errorlevel% neq 0 (
    echo HATA: Windows build başarısız!
    echo Muhtemel nedenler:
    echo - Visual Studio C++ tools yüklü değil
    echo - Windows development environment eksik
    echo flutter doctor komutunu çalıştırın
    pause
    exit /b 1
) else (
    echo ✓ Windows build başarıyla tamamlandı
    echo.
)

echo [5/5] Zip arşivi oluşturuluyor...
if not exist "build\windows\x64\runner\Release" (
    echo HATA: Build klasörü bulunamadı!
    echo Build başarısız olmuş olabilir.
    pause
    exit /b 1
)

powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'price_list_windows_v2.1.0.zip' -Force"
if %errorlevel% neq 0 (
    echo HATA: Zip oluşturma başarısız!
    echo PowerShell hatası veya dosya erişim sorunu olabilir.
    pause
    exit /b 1
) else (
    echo ✓ Zip arşivi başarıyla oluşturuldu
    echo.
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