# ====================================================================
# OSMAN'S ULTIMATE PC SETUP & AUTOMATION HUB
# ====================================================================

function EkraniTemizle {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "            OSMAN'S ULTIMATE PC SETUP HUB            " -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
}

function AnaMenu {
    while ($true) {
        EkraniTemizle
        Write-Host "[1] Otomatik Yedekleme Sistemi Kur (Yapım Aşamasında)"
        Write-Host "[2] Ekran Değiştirme Otomasyonu (Yapım Aşamasında)"
        Write-Host "[3] Çıkış"
        Write-Host "=====================================================" -ForegroundColor Cyan
        
        $secim = Read-Host "Seçiminiz (1-3)"
        
        switch ($secim) {
            "1" { Write-Host "Yedekleme modülü hazırlanıyor..."; Start-Sleep 2 }
            "2" { Write-Host "Ekran değiştirme modülü hazırlanıyor..."; Start-Sleep 2 }
            "3" { exit }
            default { Write-Host "Hatalı Seçim!" -ForegroundColor Red; Start-Sleep 1 }
        }
    }
}

# Programı Başlat
AnaMenu
