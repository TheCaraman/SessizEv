# Güncel ek — 2026-11-17 / ayrı aktif deneme dalı

Aşağıdaki0.1.1 ve salt doğrulayıcı bilgileri tarihsel devirdir. Aktif oynanabilir kaynak workers/codex-house-atmosphere-v3, dalcodex/house-atmosphere-v3; sürüm0.1.6-dev.20261117.2. Kök/masaüstü başlatıcı bu worktree'yi açar; ana proje koduyla birleştirilmiş sayılmaz. Claude003 adayı ayrı korunur, otomatik taşınmadı.

Yeni: HOUSE-ATMOS-004 tam üst hol ve kaynaklı ışık; kalıcı parlaklık/fare/FOV/ana ses; NIGHT-WITNESS-002 yeni Gün3 nöbetinde ölçülmüş masum hareket ve Gün4 çelişkili ifadeler. docs/qa/LiveNightWitness.md kapsam/test/sınır kaynağıdır. Eski aktif nöbete geçmiş tanık eklenmez; tümü sağlıklı evde de olay geçerli. DAY4-CLOSURE-001 ücretsiz erteleme, onaylı20:00bekleme, ortak aday iş çözümü ve güncel özet ekler (QA: Day4Closure.md). Genel gece yönetmeni ve tam Gün4/kampanya eksik; sanat kabulü/elle tam oyun hâlâ açık. Güncel test sonuçları live-night-witness-last-run.json içinde kaydedilir.

---

# CLAUDE — Güncel devir / 2026-11-16

## İlk okuma

AGENTS.md, CLAUDE.md, bu belge, docs/coordination/STATUS.md ve TASKS.md. Önce git status ve git log kontrol et. Eski START_HERE içindeki Gün 2 yok bilgisi düzeltildi. Kanonik proje C:/Users/eyups/OneDrive/Belgeler/TheQuietHours/project; dal automation/integration. Önceki görsel/kod checkpoint'i 7c05f97. Bu devir ayrıca commit ve geliştirme etiketiyle kaydedilir.

## Sahibin güncel önceliği

Koridorun hâlâ No, I'm Not a Human atmosferinden uzak, dar/boğuk, penceresiz/dış dünyasız hissettiğini; kapıdan oda kartı görünmesi ve büyümesi hissini reddetti. Resmî görseller gerçekten araştırıldı, yorum ve sınırlar docs/qa/CorridorReferenceRevision.md içinde. 3D yürünebilir koridor + katmanlı 2D oda mimarisi geçerli. PS1/piksel, aşırı düşük poligon görünümü ve fotogerçekçi oda çizimleri reddedildi. Kullanıcı koridorun baştan yapımına izin verdi; yeni büyük yaratıcı fikir için yine sahibine sor. Yaş sınırı kaygısıyla öldürme açılmadı; kovma/izolasyon var.

## Gerçekte yapılanlar

- Gün 1–3: ilk yayın/radyo, Elena kabul/red; Marcus/Arthur gelişi; kaynak/yatak/iş yönetimi; kayıt/devam; Gün 3 seed'li elektrik nedeni, gerçek nedene bağlı kanıt, onarım fiyatı/onayı, gece uyku/nöbet/saat ve sabah çözümü.
- Gün 4'ün ilk kayıtlı kanıt incelemesi, üç yetişkin için kovma, aynı oda dinleyici hatırası, tek izolasyon odası hazırlama/yerleştirme/salıverme, temel kontrol diyalogları. Tam Gün 4/kampanya bitmiş değil.
- Kayıt sürümü 5: pending doğrulama, backup döndürme/geri alma; aday commit canlı durumu ancak başarılı kayıttan sonra uygular. Enfeksiyon yeniden atılmaz. Bütün eski işlemler henüz bu işlem modeline taşınmış değil.
- 13 ana oda aynı çizimsel dilde yeniden üretildi; orijinaller, promptlar, manifest, gerçek RoomView ekranları saklandı. Living ve utility için ayrı gece/gündüz-kesinti/gece-kesinti kaynakları var; diğer odaların özel ışık varyantları yok.
- Son koridor: 3m dolaşım, giriş açıklığı da 3m; iki katta merdiven yanında 1,1m fiziksel parapet; alt girişte iki, üst koridor sonunda bir gerçek dış pencere. Üst depo x6,8–8,2 / z8,5–10 oldu; depo hâlâ penceresiz. HousePlan ve HouseLayout güncellendi.
- Pencerenin opak ışık kartı kaldırıldı. Önde 3D çit/yol/bahçe, uzakta özgün image_gen sokak çizimi assets/exterior/briar_glen_street_day.png. Mahalle simülasyonu/açık dünya yok. Fon gece kararıyor; aynı fon farklı katlarda kullanılıyor.
- Oda kartı kapıdan kaldırıldı: gerçek menteşe .55s, kararma .12s, sabit ölçekte RoomView görünüşü .25s. Geri çıkışta kanat anında sıfırlanır; ters kapanış animasyonu henüz yok. Referansın tam kapı tekniği araştırmada doğrulanmış DEĞİL.
- Daha açık sıva/tavan, boyalı ahşap kapı dokusu, daha az turuncu baskı/gren/vinyet; pencere ışığı koridora ulaşıyor. Havada kalan merdiven fotoğrafları kaldırıldı, saat masaya indi.

## Doğrulama ve dürüst sınırlar

22 paket / 6063 denetim PASS (son tam koşu tqh-tests-d4cec1aca6d5453a8a035881ca0e6e38). GPU kapı9, oda ışığı64 PASS. Alt/üst koridor, giriş gündüz/gece gerçek renderları incelendi. Son dış fon değişiminden sonra odaklı power669, presentation88, layout97 PASS. Presentation kapanışında AudioStreamWAV ve AudioStreamPlaybackWAV için iki ObjectDB uyarısı var; QA-AUDIO-EXIT-001 açık. Birkaç frame/.06s bekletme denemesi bunu çözmedi ve geri alındı. Uyarısız test iddia etme.

Manuel fiziksel oyun kontrolü yapıldı diye iddia etme. Önceki oturumda Godot bilgisayar kontrolü otomatik onay incelemesinde reddedildi; bu izin alternatif UI aracıyla aşılmadı. Kaydedilmiş GPU sahneleri ve otomatik mantık kontrolleri gerçek kanıttır; baştan sona elle oynanış değildir.

## Sonraki işler — öncelik sırası

1. CORRIDOR-REFERENCE-002: koridor sanatını tamamla. Boş/düz resim çerçeveleri, sert düz şerit perdeler, kutu biçimli telefon/ayakkabı/diğer küçük eşyalar hâlâ prototip. Koridor yüzeyleri ve çizim dili hedef kalitede sayılmaz. Son continuation'da yalnız dosyalar okundu; perde/çerçeve için yeni kod YAZILMADI. Sahibi kabul etti diye varsayma. Önce docs/qa gerçek görüntülerini incele.
2. Geçişte kapanış ve gerekiyorsa kullanıcı görüşüne göre daha iyi görsel süreklilik. Yeni zoom/kart yaklaşımı geri getirme. Gerçek kapı/oda UI giriş kilidi ve kampanya zamanı korunmalı.
3. QA-AUDIO-EXIT-001 ses yaşam döngüsü uyarısı; kapsamı dağıtmadan araştır.
4. Elena graphic_candidate_v2 tema olarak yakın ama nihai kullanım onayı YOK. Üç default karakter hâlâ eski gerçekçi figürler. Onay olmadan adayları default yerine koyma; Marcus/Arthur'u aday yönünde topluca üretme.
5. Diğer 11 odanın ışık varyantları, izolasyon hazır dekoru, genel ayarlar/erişilebilirlik ve ses eksikleri.
6. NightObservation yalnız saf doğrulayıcı/rota sözleşmesi. Canlı gece hareketi/tanık üretimi ve kayıt bağlantısı YOK; eski kayda tanık uydurma. Görsel öncelik tamamlanmadan bunu öne çekme.
7. Sonra Gün 4 ve tam 14 gün/18 NPC, ilişkiler, sonlar/testler, final sanat/animasyon/ses, performans, Windows yayın paketi. Tam oyun henüz yok.

## Deneme sürümü ve dosyalar

Geliştirme sürümü: 0.1.1-dev.20261116.2. Ana menüde sürüm görünür. Proje adı ve user:// kayıt yolu değişmedi, save schema değişmedi. Masaüstü THE QUIET HOURS.lnk → kökte OYUNU_AC.cmd → project/OYUNU_AC.cmd → tools/Start-Game.ps1; kanonik projeyi import edip açar. Oyuncu eski çalışan süreci kendisi kapatıp kısayoldan yeniden başlatmalı. Bu standalone export değildir, kurulmuş Godot 4.7.2 kullanır. Kaynak yedeği runtime/checkpoints altında Git bundle olarak ayrıca hazırlanır; sistem oyun kayıtlarını silmez.

Araçlar: tools/Run-Tests.ps1 (izole kullanıcı verisi); tools/Start-Game.ps1 -PrepareOnly (import/başlatma zincirini denetler, oyun açmaz). scenes/dev/corridor_review.tscn -- --capture-corridor [--foyer] [--upper] [--night]; scenes/dev/room_style_review.tscn -- --capture-all-rooms. Promptlar docs/art/prompts; manifest docs/art/asset_manifest.json.

## Devir ve çalışma kuralı

Bu dosyanın yazılması Claude'un okuduğu anlamına gelmez. Claude okuduğunda docs/coordination/messages altında ayrı ACK dosyası yazmalı; sonra sahipliği üstlenmeli. Aynı ortak klasörde dal değiştirme, başkasının değişikliğini silme. Sahip en son mevcut çalışmayı kaydetme, bütün yapılan/yapılacakları güncelleme ve deneme sürümüne ekleme istedi. Codex bu devirde yeni görsel düzenleme başlatmıyor.

Devir sürüm kontrolü: config/version ve ana menü etiketi 0.1.1-dev.20261116.2. Menü regresyonu80PASS; Start-Game.ps1 -PrepareOnly kanonik proje/engine import zincirini doğruladı. checkpoint-main-menu.png gerçek GPU sürüm etiketi kontrolüdür.
