# Gün4 değerlendirme kapanışı — DAY4-CLOSURE-001

## Amaç ve kapsam
Day4Design §3 ve §5 kapsamında ücretsiz erteleme, akşam değerlendirmesine onaylı bekleme ve açık soruşturmayla kesit kapanışı. Mevcut kovma/izolasyon/görüşme akışı korunur. Tam Gün4 suçlama sahnesi, açık suçlama kaydı/güven bedeli, tüm kişisel cevaplar, Gün4 tahliye yayını ve Gün5 hâlâ tamamlanmamıştır. Bu uygulama bunları var saymaz.

## Dosyalar / düğüm / kurulum
scripts/narrative/day4_closure.gd RefCounted; CampaignDirector.closure sahne-yerel sahip, ShelterManager referansı enjekte edilir. Yeni autoload yok. scripts/narrative/day4_review.gd mevcut inceleme ve yeni güncel özet. scripts/narrative/campaign_director.gd oda eylemleri/iptal bağlantısı. scripts/shelter/shelter_manager.gd ortak saf iş çözümü. scripts/save/save_manager.gd yeni optional flag doğrulaması. resources/events/day4_review.json closing_minute=1200. localization/strings.csv18EN/TR anahtarı. tests/day4_closure_test.gd/.tscn ve Run-Tests paketi. Godot4.7.2 import ve mevcut Start-Game.ps1 yeterli.

Hiyerarşi: HouseBlockout→CampaignDirector→closure(RefCounted), HouseBlockout→ShelterManager(Node), RoomView(CanvasLayer)→eylem HFlowContainer, JournalView(CanvasLayer)→PanelContainer→ScrollContainer→Label. EventBus.room_view_closed ve day_started (yükleme dahil) onayı iptal eder. review_requested mevcut modal özeti açıp kontrolü kilitler; kapatma serbest dolaşımı geri verir.

## Oyuncu akışı
Gün4'te Daniel odasında Review last night ile incelemeyi aç. Geri dönünce Keep investigating ücretsiz erteleme işareti koyar; teşhis/ceza/kaynak etkisi yok. Akşamdan önce Wait until evening review(20:00) iki basışlıdır. İlk basış sonuçları açıklar ve düğme Confirm olur; odadan çıkmak iptal eder. Zaman/kanıt/sakin/iş/kaynak/diğer flag değişirse yeni teklif gerekir. Aynı durumlu save/load bile eski onayı iptal eder.

Bekleme20:00'ye ilerletir; enerji geri vermez, yiyecek/su tüketmez. Bu saat aralığında bitecek gündüz işleri aynı kayıt adayında çözülür; iş raporları gerçek bitiş saatinde, sırayla ve tek kez kaydolur. Gece işleri beklemede kalır, yazılmamış gece raporu üretilmez. Aktif Gün4 ziyaretçi beklerken seçenek çıkmaz. Onarımsız elektrik veya sıfır kaynak bekleme/kapanışı engellemez.

20:00 sonrasında Complete review yine açık iki basışlı onaydır. Bütün kanıtları toplamak, hedef seçmek, birini çıkarmak veya izole etmek şart değildir. Seçim completed/completed_at işaretini kaydeder ve yalnız güncel özeti açar. Gün/saat/kişi/kaynak/enerji değişmez. Tamamlanan özete dönülebilir; keşif, inceleme ve mevcut kararlar sürer. Sonraki kararla özetin güncel kısmı değişir, özgün tamamlanma saati değişmez. Sleep mevcut açık kesit sınırını gösterir; Gün5'e geçmez ve günlük tüketim yapmaz.

## Özetin güvenilirliği
Toplamlar mevcut resident, resident+isolated, day4_expelled işaretleri ve yalnız toplanmış evidence türlerinden hesaplanır. Npcs.infected, gizli olay faili veya duyulmamış gece hareketi okunmaz. Elektrik için yalnız mevcut outage durumu gösterilir. Sahte teşhis, başarılı kurtarma veya son yazılmaz. İlk inceleme sayfası özeti ayrıca içerir; kapanış ekranı doğrudan kısa özetle açılır.

## Ortak iş çözümü
Önceden _complete yalnız GameState üzerinde çalışıyordu. Şimdi _complete_in(state,id,at) aynı job/meal flag/rapor/tekillik kurallarını parametre durumunda uygular. Normal _complete canlı container referanslarıyla çağırır; mevcut davranışı ve gece raporunu korur. project_daytime yalnız verilen aday kopyaya uygular; önce resident olmayan işleri temizler, uygun gündüz işlerini end→ID sırasıyla çözer, night_watch'u tamamlamaz. Bekleme adayı önce diske gider; from_dict sinyallerinde biten işler artık yoktur ve ikinci defa çözülmez.

## Kalıcılık / hata
Save şeması5 korunur; optional flags day4_review_deferred(bool), day4_review_completed(bool), day4_review_completed_at(tam dakika). Yeni işaret varsa gün>=4 ve day4_reviewed=true gerekir. Tamamlanma saatinin20:00–23:59 ve Gün4 için mevcut saatten ileride olmaması doğrulanır; eksik/zıt timestamp reddedilir. Eski flag'siz save geçerli; yeni karar/yapılmış geçmiş uydurulmaz. Yeni v6 göçüne ihtiyaç yok.

Bütün değişiklikler SaveManager.commit_candidate ile önce kalıcı yazılır. Başarısız wait save saati/işleri/raporları değiştirmez; onay iptal olur. Başarısız kapanış/erteleme de canlı değişiklik uygulamaz. config tercihlerine ve infection atamalarına dokunulmaz. Protokol güç kaybına karşı mutlak dosya sistemi atomikliği garantisi değildir; mevcut güvenli pending/backup zincirini kullanır.

## Deneme / sık sorunlar / bitti
Yeni veya mevcut Gün4 sabahında incelemeyi aç; ücretsiz ertele, beklemeyi onayla,20:00'de kapanışı onayla; özet→keşif→özete dön. Aktif iş varsa raporlarının tek oluştuğunu doğrula. Sıfır sakin/kaynak ve onarımsız ev de geçerli. Menüde yeni anahtar görünürse CSV yeniden import et. Sadece ilk basıştan sonra hiçbir şey değişmemesi beklenir.20:00'den önce Complete yoktur; Wait sunulur.

Test8sakin altkümesi, sıfır food/water/repair, gerçekRoomView veJournalmodal, ücretsiz erteleme/idempotency, yanlışoda, waitfirstpress/leave/load/error, saf projection+sıralı iki iş+pendingwatch+doublecompletion,20:00sınırı, changed evidence quote, kalıcı closure/eşitload, gizliinfectiondeğişiminde aynı özet, invalidtypes/timestamps, summaryreread, EN/TR720p/1080p/1440p, kararsonrasıgüncelözet ve Gün5'e atlamama. Görüntükanıtı gerçek GPU'da alınır; fare/klavye ile tam elle oynama iddiası yok.

Bitti: ilgili testler, tam regresyon, GPUözet görüntüsü, launcher sürüm doğrulaması, Git/ortak devir. Sonraki bağımlılık açık suçlama/basis kaydı ve Gün4'ün eksik yazarlı içeriğidir; tam kampanya bitmiş değildir.

Görsel QA sonrası JournalView'a JournalCloseHint eklendi (localization bir ek EN/TR anahtarı). Panel altındaki kalıcı Tab/Esc ipucu iki dilde ve üç çözünürlükte ölçülür; SubViewport'a gönderilen pause InputEventAction gerçekten modalı kapatıp player kontrolünü geri getirir. Bu motor girdisi testidir, elle fiziksel tuş testi değildir.

Sonuç:26paket/6610 gerçekWASAPI PASS; closure236, GPU238(iki görüntü dahil). EN/TR görüntüler incelendi; Tab/Esc ipucu yerinde. Tam koşu ve GPU bu nihai ürün koduyla0.1.6-dev.20261117.2 üzerinde çalıştı. Günlükler C:\Users\eyups\AppData\Local\Temp\tqh-tests-ab525d96823649bd916e045fbd6fd29b; makine kaydı day4-closure-last-run.json. PowerShell belge güncellemesindeki akıllı tırnak parser hatası işlem yürütmeden reddedildi, düz metinle düzeltildi; oyun/test hatası değildi.
