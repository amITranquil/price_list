@echo off
echo ========================================
echo   GitHub Release Güncelleme Script
echo ========================================
echo.

REM GitHub CLI'nin yüklü olup olmadığını kontrol et
gh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo HATA: GitHub CLI yüklü değil!
    echo Lütfen GitHub CLI'yi indirin: https://cli.github.com/
    echo.
    echo Alternatif olarak manuel yöntem:
    echo 1. https://github.com/amITranquil/price_list/releases/tag/v2.0.0
    echo 2. "Edit release" butonuna tıklayın
    echo 3. Eski Windows dosyasını silin
    echo 4. Yeni zip dosyasını yükleyin
    pause
    exit /b 1
)

REM Zip dosyasının var olup olmadığını kontrol et
if not exist "price_list_windows_v2.1.0.zip" (
    echo HATA: price_list_windows_v2.1.0.zip dosyası bulunamadı!
    echo Önce build_windows.bat dosyasını çalıştırın.
    pause
    exit /b 1
)

echo [1/2] Eski Windows dosyası siliniyor...
gh release delete-asset v2.0.0 price_list_windows_v2.0.0.zip --yes
if %errorlevel% neq 0 (
    echo UYARI: Eski dosya silinemedi (zaten silinmiş olabilir)
)

echo [2/2] Yeni Windows dosyası yükleniyor...
gh release upload v2.0.0 price_list_windows_v2.1.0.zip
if %errorlevel% neq 0 (
    echo HATA: Dosya yükleme başarısız!
    pause
    exit /b 1
)

echo.
echo ========================================
echo     GITHUB RELEASE GÜNCELLENDI!
echo ========================================
echo.
echo Güncellenmiş release: https://github.com/amITranquil/price_list/releases/tag/v2.0.0
echo.
pause