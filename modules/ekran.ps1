# ====================================================================
# MODÜL: EKRAN DEĞİŞTİRME OTOMASYONU (ControlMyMonitor)
# ====================================================================

Clear-Host
Write-Host "--- EKRAN DEĞİŞTİRME OTOMASYONU KURULUMU ---" -ForegroundColor Yellow
Write-Host "ControlMyMonitor indiriliyor ve geçiş dosyaları hazırlanıyor..." -ForegroundColor DarkGray

$HedefKlasor = "D:\programlar\ControlMyMonitor"
$ZipDosyasi = "$env:TEMP\ControlMyMonitor.zip"
$NirsoftURL = "https://www.nirsoft.net/utils/controlmymonitor.zip"

# 1. Klasörü oluştur
if (!(Test-Path $HedefKlasor)) {
    New-Item -ItemType Directory -Force -Path $HedefKlasor | Out-Null
}

# 2. ControlMyMonitor'ü indir ve çıkart
try {
    Write-Host "En güncel ControlMyMonitor sürümü indiriliyor..."
    Invoke-WebRequest -Uri $NirsoftURL -OutFile $ZipDosyasi
    
    Write-Host "Dosyalar çıkartılıyor..."
    Expand-Archive -Path $ZipDosyasi -DestinationPath $HedefKlasor -Force
    Remove-Item $ZipDosyasi -Force
} catch {
    Write-Host "İndirme sırasında bir hata oluştu! Lütfen internet bağlantınızı kontrol edin." -ForegroundColor Red
    return
}

# 3. Geçiş Scriptlerini Oluştur
$PS5GecisKodu = @"
@echo off
displayswitch.exe /extend
timeout /t 2 /nobreak > NUL
"D:\programlar\ControlMyMonitor\ControlMyMonitor.exe" /SetValue "\\.\DISPLAY1\Monitor0" 60 15
exit
"@

$PCGecisKodu = @"
@echo off
"D:\programlar\ControlMyMonitor\ControlMyMonitor.exe" /SetValue "\\.\DISPLAY1\Monitor0" 60 17
timeout /t 1 /nobreak > NUL
displayswitch.exe /external
exit
"@

$PS5BatYolu = "$HedefKlasor\PS5_Gecis.bat"
$PCBatYolu = "$HedefKlasor\PC_Gecis.bat"

$PS5GecisKodu | Out-File -FilePath $PS5BatYolu -Encoding default
$PCGecisKodu | Out-File -FilePath $PCBatYolu -Encoding default

# 4. Masaüstüne Kısayol Oluştur
$Masaustu = [Environment]::GetFolderPath("Desktop")
$WshShell = New-Object -ComObject WScript.Shell

$PS5Kisayol = $WshShell.CreateShortcut("$Masaustu\PS5 Gecis.lnk")
$PS5Kisayol.TargetPath = $PS5BatYolu
$PS5Kisayol.IconLocation = "shell32.dll, 86"
$PS5Kisayol.Save()

$PCKisayol = $WshShell.CreateShortcut("$Masaustu\PC Gecis.lnk")
$PCKisayol.TargetPath = $PCBatYolu
$PCKisayol.IconLocation = "shell32.dll, 35"
$PCKisayol.Save()

Write-Host "`n[BAŞARILI] Kurulum Tamamlandı!" -ForegroundColor Green
Write-Host "ControlMyMonitor ve Bat dosyaları '$HedefKlasor' dizinine kuruldu." -ForegroundColor Cyan
Write-Host "Masaüstünüze hızlı geçiş kısayolları eklendi." -ForegroundColor Cyan
