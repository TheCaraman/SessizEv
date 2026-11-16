# NIGHT-WITNESS-001 — kayıt doğrulama temeli

## Amaç ve mevcut teslim

NightObservation.valid(record), gece yönetmeninin ileride sağlayacağı tamamlanmış masum banyo hareketi/görüş kaydının yapısal tutarlılığını doğrular. Oyun durumuna dokunmaz, katılımcı seçmez, kişiyi yürütmez, kimseyi uyandırmaz ve kanıt/tanık bayrağı üretmez. Bu teslim oynanabilir tanıklık veya tam Gün 4 suçlama sahnesi değildir. Gerçek olay üretimi ve kayıt/yükleme bağlantısı sonraki adımdır; mevcut kayıtlara geçmiş tanık eklenmez.

Dosyalar: scripts/narrative/night_observation.gd; resources/events/night_observation.json; tests/night_observation_test.gd/.tscn; tools/Run-Tests.ps1. Yeni sahne düğümü/autoload yok; RefCounted saf doğrulayıcıdır. Godot 4.7.2 içe aktar; testi bağımsız sahneden veya Run-Tests.ps1 ile çalıştır.

## Veri ve fiziksel rota

Zorunlu alanlar: day, start/end/seen_at mutlak gece dakikaları; subject/observer farklı uygun yetişkinler; subject_reason=bathroom_visit; observer_reason=checking_after_pipe_noise; denial_reason=fear_of_accusation. steps her oda ve giriş dakikasını sırayla taşır. observation odası corridor, dakika seen_at, awake/sightline doğrulaması; snapshot iki kişinin olay anındaki resident/erişim/uygunluk durumudur. Sağlık/enfeksiyon bu seçim veya doğrulamanın ölçütü değildir.

Rotalar mevcut HouseLayout üst kat açıklıklarıyla karşılaştırıldı: guest_a → corridor; guest_b ve multipurpose → landing → corridor; sonra bathroom_upper ve aynı yoldan dönüş. Başlangıç/bitiş odası aynı, dakika artan, görüldü anı gerçek corridor aralığındadır. Zemin kat utility yolu bu masum olayda yoktur. Dolayısıyla bu kayıt panoda sabotaj görmüş olmayı desteklemez.

Snapshot route_access ve observation awake/sightline, doğrulayıcının dünyadan ölçtüğü sonuçlar değildir: olay üreticisinin gerçek kaynaklardan sağlaması gereken sözleşmedir. Salt true yazılmış bir fixture gerçek tanıklık kanıtı sayılmaz. Gelecek üretici pipe olay zamanı, gerçek kilit/konum/uyanıklık ve görünür hareket sınırlarını kontrol etmeden kayıt oluşturmamalıdır. Görünür NPC teleportu kabul edilmez; eski yüklemeye geriye dönük olay eklenmez.

## Test ve kalanlar

NIGHT OBSERVATION TEST 38 denetim geçti: üç rota, JSON sayıları, iki enfeksiyon atamasında aynı doğrulama; çocuk/aynı kişi/yanlış gün/zaman, boş veri, farklı neden, uyuyan tanık, ölü/kovulmuş/yok kişi, izole/yaralı/meşgul hedef, kilitli rota ve imkânsız oda sıçraması reddi; canlı GameState'in aynen kalması. Bu saf modülde yeni UI/asset olmadığı için render testi gerekmedi. Üretici bağlanınca olay/oda/kayıt ve gerçek görüntü sınaması ayrıca gereklidir.

Bitti ölçütü bu hazırlık modülünün testli veri sözleşmesidir; kapsamlı gece tanığı değildir. Sıradaki bağımlılık: sahne-yerel yönetmende gerçek zaman aralığı ve görünürlük koşullarına uyan masum hareket; ardından kayıt göçü, oyuncuya sunulan iddia ve sağlıklı/enfekte/absent fallback konuşmaları.

Tam regresyon: 21 paket/6024 denetim geçti; tqh-tests-5db9f898b9334f3eb876b25f80fe2279. Mevcut oyun kaydı ve UI akışı korunur.

## 2026-11-17 güncel ek
Yukarıdaki saltvalid modül teslimi tarihseldir. NightWitness ve NightRouteAccess artık canlı nöbete bağlandı; üretim için valid_completed, kayıt, args'lıclaim ve Gün4 ifadeleri mevcut. Eski aktif nöbete backfill yok. Güncel kapsam/sınır/test: LiveNightWitness.md ve live-night-witness-last-run.json. Genel geceAI ve tamGün4 tamamlanmadı.
