# Ortak durum — 2026-11-16

Son oyun kilometre taşı: `2169bad` — Gün 1, Elena'nın kabul/ret/kapıyı açmama yolları,
uyku, Gün 2 sabahı, enfeksiyon ataması ve kayıt altyapısı.

Gün 2 ziyaretleri (Marcus, Arthur), yatak seçimi, radyo ve kayıt v2 var (DAY2-002, dal feat/day2-002-arrivals). İş atama ve yönetim ekranı yok (DAY2-003). Oda ve karakter görselleri yer tutucu, ses yok.
Ana menü, duraklatma menüsü, elle kayıt ve kayıttan devam var (SAVE-002, dal feat/save-002-menu-continue); fareyle elle denenmedi.
Koridorlar 3D, odalar 2D. Depo penceresiz geri kondu; giriş penceresi duruyor.

## Mevcut çalışma

- Codex: COORD-001 tamamlandı; dosya sahipliği bırakıldı. Ortak çalışma belgeleri,
  ayrı proje kopyasında test komutu ve Git aktarım betiği hazır.
- Codex: DAY2-001 tamamlandı; Gün 2 şartnamesi docs/Day2Design.md içinde.
  Kod henüz uygulanmadı; uygulama DAY2-002 olarak sırada. Dosya sahipliği bırakıldı.
- Claude: SAVE-002 ve DAY2-002 tamamlandı; dosya sahipliği bırakıldı. Klasörün HEAD'i feat/day2-002-arrivals dalında. Altı test, 944 denetim.
- Uzak depo: Sahibin tercihiyle şimdilik yalnızca yerel depo.
- Kaynak klasör: Oturumun oluşturduğu klasör; kalıcı taşıma henüz yapılmadı.

Doğrulama: yeni test betiğiyle kampanya 69, etkileşim 13, ev 90 ve hareket 6
denetim geçti (toplam 178). SAVE-002 sonrası: beş test, 207 denetim. Test kayıtlarının ayrı kullanıcı dizininde oluştuğu görüldü.

## Sonraki işler

Önce Gün 1'i ve menüleri kullanıcıyla elle doğrula.
Ardından Gün 2: Marcus/Arthur gelişleri, oda ve iş atama. Aktif görev dosyalarını
kontrol etmeden aynı sistemleri paralel düzenleme.
