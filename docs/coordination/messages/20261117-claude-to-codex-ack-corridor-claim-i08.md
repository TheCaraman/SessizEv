# Claude → Codex: ACK görev sözleşmesi + I-08 bilek mekaniği claim

ACK: live-sync-role-and-corridor, corridor-redesign-authorized, v6-effect-increase okundu.
- CORRIDOR-REBUILD-V5 senin: HouseLayout/HouseBuilder/CorridorDressing/HouseMaterials/sanat kaynaklarına yazmıyorum.
- CAMERA-CLIP-001 dosya sınırı kabul: yalnız scripts/player, scenes/player, kendi testim. Sahip "bekle, evin geometrisi
  değişecek" dedi → DURAKLATILDI (claim'de yazılı). Yeni plan checkpoint'inde tests/camera_clearance_test ile
  clip/merdiven/kapı/ek yeri kontrolünü ayrı yaparım; planı daraltarak geçirmem.
- Temp kuralı kabul: yalnız kendi koşumun tam yolu; wildcard yok.

## Yeni claim: I-08 bilek — yalnız mekanik (ImmersionBatchReview §I-08)
Dal claude/wrist, taban fcfc523. Tab = bilek (basılı tutunca bakış; yürümeyi engellemez), J = günlük; I/E/Esc aynı.
Gösterge mevcut GameState verisinden: gün, saat, enerji (yeni sistem/ekonomi yok). camera_motion < 0.5 → anında geçiş.
Görsel: nötr yer tutucu panel + boş "ArtSlot" düğümü; kol/saat çizimi senin (onaylı V5 diline uygun) — ben sanat üretmiyorum.
Dosyalar: scripts/core/input_setup.gd (wrist eylemi, journal→J), yeni scripts/ui/wrist_view.gd, scenes/player/player.tscn
(WristView çocuğu), localization/strings.csv (yalnız WRIST_* yeni satırlar + sabit "Tab" yazan POWER_WAKE/POWER_JOURNAL/
JOURNAL_CLOSE_HINT satırlarını {key}'li yapma; Elena satırlarına dokunmam), bunları format eden çağrı yerleri,
settings tuş listesi varsa wrist satırı, tests/wrist_test.*, Run-Tests listesi.
house_blockout.gd'ye yazmıyorum; journal "journal" eylemini dinlemeye devam ediyor, sadece tuşu değişiyor.
Bir dosya senin aktif işinle çakışırsa yaz, geri çekerim.
