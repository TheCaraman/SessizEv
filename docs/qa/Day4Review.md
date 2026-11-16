# Gün 4 — ilk sabah değerlendirmesi

## Amaç ve mevcut kapsam

Daniel'ın odasında Gün 4'te ücretsiz “Review last night / Dün geceyi değerlendir” seçeneği vardır. Mevcut JournalView opak, kaydırılabilir panelini kullanır. Toplanan kanıtlar türleri korunarak gösterilir; hiç kayıt yoksa eksiklik açıkça yazılır. Evin güncel sakin sayısı gösterilir. Gizli elektrik nedeni, fail snapshot'ı veya enfeksiyon okunmaz; isimli tanık üretilmez. Bu teslim tam suçlama, izolasyon, kovma veya Gün 4 ana olayının tamamı değildir. Kesit sonu sınırı ve Gün 5'e geçiş engeli korunur.

## Dosyalar ve düğümler

- scripts/narrative/day4_review.gd: saf metin derleme ve ücretsiz açılışın kaydı.
- resources/events/day4_review.json: gün/kimlik/açılış anahtarları ve fallback.
- scripts/narrative/campaign_director.gd: uygun oda eylemi.
- scripts/core/event_bus.gd: review_requested(text).
- scripts/dev/house_blockout.gd: mevcut RoomView kapatılır, JournalView açılır, oyuncu kontrolü kapanır.
- scripts/ui/journal_view.gd: isteğe bağlı içerik; normal Tab günlüğü eski davranışını korur.
- localization/strings.csv: İngilizce/Türkçe metinler.
- tests/day4_review_test.gd/.tscn ve tools/Run-Tests.ps1: sekiz sakin alt kümesi, gerçek oda eylemi, kayıt ve render senaryosu.

Hiyerarşi değişmez: HouseBlockout altında CampaignDirector, RoomView ve çalışma anında JournalView. Yeni autoload yok. Godot 4.7.2 ile içe aktar, Gün 3 gecesini bitir, Daniel'ın odasında değerlendirme seç. İlk açılış day4_reviewed ve transaction/day4-review-open bayraklarını güvenli aday işlemiyle kaydeder; başarısızsa panel açılmaz ve hata metni/yeniden deneme seçeneği kalır. Tekrar okuma ücretsiz ve değişikliksizdir. Kaynak, zaman, sakin veya enfeksiyon değiştirilmez.

## Test ve sınırlar

Headless DAY4 REVIEW TEST 70 denetim geçti. Elena/Marcus/Arthur'un sekiz kabul alt kümesi, sıfır kanıt, sabit NPC/kaynak/zaman, kayıt bayrağı, modal kontrol, iptal/yeniden okuma, diğer gün reddi ve en/tr 1080p/1440p metin yolu sınandı. Hata yazıcısı alt sistemde ayrı SAVE WRITE testinde sınanır; bu panel için fareyle disk hatası deneyi yapılmadı.

Sık hata: eski kayda geriye dönük tanık eklemek veya yalnız gizli sebep var diye kanıt göstermek. Değerlendirme yalnız GameState.evidence listesini gösterir. Bu read-only başlangıçtan sonraki bağımlılık, yeni gecelerde gerçek hareket/tanık kaydı ve ayrı karar doğrulayıcısıdır. Diğer odaların eski gerçekçi geçici sanatı bu teslimde değiştirilmedi.

Son doğrulama: 18 paket/5787 denetim geçti; Forward+ capture koşusu 74 denetim. En/tr 1080p/1440p görüntüleri kaydedildi; Türkçe 1080p ve İngilizce 1440p açıldı. Olayı olmayan eski kayıtta kesinti yaşandığı iddia edilmez. Elle baştan sona oynama yapılmadı.
