# ====================================================================
# OSMAN'S ULTIMATE PC SETUP & AUTOMATION HUB
# ====================================================================

# Kendi GitHub deponun temel Raw adresi (Sonundaki eğik çizgiye dikkat et)
$PC = "https://raw.githubusercontent.com/KullaniciAdin/pc-setup-hub/main/"

function EkraniTemizle {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "            OSMAN'S ULTIMATE PC SETUP HUB            " -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
}

function ModulCalistir ($ModulYolu) {
    try {
        Write-Host "Modül indiriliyor... Lütfen bekleyin." -ForegroundColor DarkGray
        $Kod = Invoke-RestMethod -Uri ($PC + $ModulYolu)
        Invoke-Expression $Kod
    } catch {
        Write-Host "Modül indirilirken bir hata oluştu! İnternet bağlantınızı veya GitHub linkini kontrol edin." -ForegroundColor Red
        Write-Host "Detay: $_" -ForegroundColor DarkGray
    }
}

function AnaMenu {
    while ($true) {
        EkraniTemizle
        Write-Host "[1] Otomatik Yedekleme Sistemi Kur (Oyunlar/Klasörler)"
        Write-Host "[2] Ekran Değiştirme Otomasyonu (Yakında)"
        Write-Host "[3] Çıkış"
        Write-Host "=====================================================" -ForegroundColor Cyan
        
        $secim = Read-Host "Seçiminiz (1-3)"
        
        switch ($secim) {
            "1" { ModulCalistir "modules/yedekleme.ps1"; Write-Host "`nDevam etmek için Enter'a basın..."; Read-Host }
            "2" { Write-Host "Ekran değiştirme modülü hazırlanıyor..."; Start-Sleep 2 }
            "3" { exit }
            default { Write-Host "Hatalı Seçim!" -ForegroundColor Red; Start-Sleep 1 }
        }
    }
}

# Programı Başlat
AnaMenu
