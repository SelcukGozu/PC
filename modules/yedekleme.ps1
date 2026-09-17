# ====================================================================
# MODÜL: AKILLI YEDEKLEME OTOMASYONU
# ====================================================================

Add-Type -AssemblyName System.Windows.Forms

function KlasorSec ($baslik) {$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description =$baslik
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return$dialog.SelectedPath }
    return $null
}

function DosyaSec ($baslik, $filtre) {$dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title =$baslik
    $dialog.Filter =$filtre
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return$dialog.FileName }
    return $null
}

Clear-Host
Write-Host "--- AKILLI YEDEKLEME OTOMASYONU KURULUMU ---" -ForegroundColor Yellow

Write-Host "`n1. Adım: Hangi oyun/program takip edilecek?"
$exeYolu = DosyaSec "Takip edilecek .exe dosyasını seçin (Örn: javaw.exe)" "Çalıştırılabilir Dosyalar (*.exe)|*.exe"
if (!$exeYolu) { Write-Host "İptal edildi."; return }
$exeAdi = [System.IO.Path]::GetFileNameWithoutExtension($exeYolu)

Write-Host "`n2. Adım: Hangi klasör yedeklenecek? (Saves klasörünü seçin)"
$kaynakKlasor = KlasorSec "Yedeklenecek (Saves) klasörünü seçin"
if (!$kaynakKlasor) { Write-Host "İptal edildi."; return }

Write-Host "`n3. Adım: Yedekler nereye kaydedilecek? (Google Drive vb.)"
$hedefKlasor = KlasorSec "Yedeklerin atılacağı hedef klasörü seçin"
if (!$hedefKlasor) { Write-Host "İptal edildi."; return }

$KurulumKlasoru = "C:\OsmanBackup"
if (!(Test-Path $KurulumKlasoru)) { New-Item -ItemType Directory -Force -Path $KurulumKlasoru | Out-Null }
$BatDosyasi = "$KurulumKlasoru\YedeklemeServisi_$exeAdi.ps1"

$ScriptIcerigi = @"
`$HedefProgram = "$exeAdi"
`$KaynakKlasor = "$kaynakKlasor"
`$BulutKlasoru = "$hedefKlasor"
`$OyunUzantilari = @("*.dat", "*.sav", "*.save", "*.json", "*.xml", "*.ini", "*.cfg", "*.txt", "*.mca", "*.metadata")

while (`$true) {
    `$programCalisiyor = Get-Process -Name `$HedefProgram -ErrorAction SilentlyContinue
    if (`$programCalisiyor) {
        `$programCalisiyor | Wait-Process
        
        `$SonYedek = Get-ChildItem -Path `$BulutKlasoru -Filter "`$(`$HedefProgram)_Yedek_*.zip" | Sort-Object CreationTime -Descending | Select-Object -First 1
        `$YedekAlinsinMi = `$true

        if (`$SonYedek) {
            `$GecenSure = (Get-Date) - `$SonYedek.CreationTime
            if (`$GecenSure.TotalMinutes -lt 45) { `$YedekAlinsinMi = `$false }
        }

        `$EnYeniDosya = Get-ChildItem -Path `$KaynakKlasor -Recurse -Include `$OyunUzantilari -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (`$EnYeniDosya) {
            if (`$SonYedek -and (`$EnYeniDosya.LastWriteTime -le `$SonYedek.CreationTime)) { `$YedekAlinsinMi = `$false }
        } else { `$YedekAlinsinMi = `$false }

        if (`$YedekAlinsinMi) {
            `$tarih = Get-Date -Format "yyyy-MM-dd_HH-mm"
            `$zipAdi = "`$(`$HedefProgram)_Yedek_`$tarih.zip"
            `$tamHedefYol = Join-Path `$BulutKlasoru `$zipAdi
            Compress-Archive -Path "`$KaynakKlasor\*" -DestinationPath `$tamHedefYol -CompressionLevel Optimal -Force
            
            `$eskiYedekler = Get-ChildItem -Path `$BulutKlasoru -Filter "`$(`$HedefProgram)_Yedek_*.zip" | Sort-Object CreationTime -Descending
            if (`$eskiYedekler.Count -gt 2) {
                `$eskiYedekler | Select-Object -Skip 2 | ForEach-Object { Remove-Item `$_.FullName -Force }
            }
        }
    }
    Start-Sleep -Seconds 10
}
"@

$ScriptIcerigi | Out-File -FilePath $BatDosyasi -Encoding utf8

$VbsKodu = "CreateObject(`"Wscript.Shell`").Run `"powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File $BatDosyasi`", 0, False"
$BaslangicKlasoru = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$VbsKodu | Out-File -FilePath "$BaslangicKlasoru\OsmanYedekleme_$exeAdi.vbs" -Encoding utf8

Write-Host "`n[BAŞARILI] $exeAdi İçin Akıllı Yedekleme Sistemi Kuruldu!" -ForegroundColor Green
Write-Host "Bilgisayar yeniden başladığında devreye girecek." -ForegroundColor Cyan
