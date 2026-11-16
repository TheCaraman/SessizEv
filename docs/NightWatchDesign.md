# Aktif gece — NIGHT-001 uygulama şartnamesi

Durum: Uygulama öncesi teknik tasarım. Bu belge oynanabilir gece nöbeti değildir. Mevcut Gün 1–3 sürümü korunur; üretim kodunda henüz gece saati genişletilmedi.

## Amaç ve kapsam

Özgün tasarımın uyuma/uyanık kalma seçimini üç günlük kesitte gerçek kılmak: Daniel koridorda yürür, kapıdan 2D odalara bakar, mevcut elektrik olayını inceler ve isterse kalan geceyi uyuyarak bitirir. Yeni saldırı, rastgele canavar, yeni suçlu veya yeni ziyaretçi eklenmez. Gün 1–2 sessiz gece çözümü başlangıçta korunur; ilk aktif gece Gün 3'tür. Oyuncu tüm sakinleri reddetse de akış çalışır.

## Mevcut sınır ve zorunlu düzeltme

GameState.advance_minutes şu anda LAST_MINUTE=1439 sınırına bağlıdır. Gün 3 olayı 23:00'te keser; ikinci uyku Gün 4'e atlar. Enerji sabah doğrudan 100 olur. Bu davranış gerçek sekiz saatlik nöbete yetmez. Salt düğme ve aynı zaman atlaması, özellik teslimi sayılmayacak.

## Zaman modeli

Kampanya günü sabah 07:00'de başlar ve ertesi sabah biter. Aktif gecede dakika, o günün gece yarısından itibaren tek yönlü mutlak değer olarak tutulur: 23:00=1380; 01:00=1500; 03:00=1620; 05:00=1740; sonraki 07:00=1860. Ekran saati ve ışık hesabı dakika modulo 1440 kullanır; olay zamanları mutlak değer kullanır. Gece 01:00'de kampanya günü artmaz; Gün 4 ve günlük tüketim yalnızca gece tamamlanınca gerçekleşir.

NightSession sahne-yerel denetleyici olacak; kalıcı veri GameState.night_session içinde tutulacak. Bütün kayıt/göç ve saat müşterileri bu değişiklikle birlikte güncellenecek; yalnızca LAST_MINUTE değerini yükseltmek yasak. Dört iki saatlik aralık seçim/özet sınırıdır, sabit gerçek zaman beklemesi değildir. Serbest yürümek saati ilerletmez; mevcut anlamlı eylemler ve açık bekleme seçimi ilerletir.

## Akış

1. Gün 3 akşamı Daniel'ın odasında uyku ve uyanık kalma ayrı seçenekler sunulur. Kapıda ziyaretçi/aktif konuşma varken geçiş yoktur. Başlamadan süre/enerji etkisi gösterilir; iptal ücretsizdir.
2. Her iki yol 23:00 elektrik olayına saygı duyar. Uyanık Daniel'a uyandığı söylenmez. Olay gözlemi ile uykudan uyanma anlatımı ayrı anahtarlar alır; fiziksel kanıt aynı nedenden doğar.
3. Uyanık oyuncu olay sonrası koridorda kalabilir ve tesisat odasını açabilir. Daniel'ın konumu fail bilgisi veya otomatik tanıklık üretmez. Mevcut tarihsel hareket kaydı görünür NPC animasyonu sayılmaz.
4. Bekleme bir sonraki iki saat sınırına kadar gider; önce gerçekleşecek yazılmış olay veya eylem sonu varsa orada durur. Bekleme iptali hiçbir durum değiştirmez.
5. Daniel kendi odasında kalan geceyi uyuyabilir. Uyku, aynı gece oturumunu bitirir; ikinci tüketim veya tekrar elektrik olayı oluşmaz.
6. 07:00'de tek sabah çözümü çalışır. Tamamlanmamış elektrik arızası taşınır; Gün 4'ün diğer hikâyesi mevcut kesit sonu bildirimi olarak kalır.

## Enerji — dengeleme varsayımı

İlk uygulama için uyanık geçirilen her iki saat 10 enerjiye eşdeğerdir; kısmi aralıklar dakika üzerinden hesaplanır, yuvarlama yalnızca sonuçta yapılır. Sekiz saat nöbet 40 enerjiye mal olur. Uykuda geçen sekiz saat 65 enerji geri verir; üst sınır 100'dür. Sıfıra yakın enerji oyuncuyu rastgele öldürmez veya otomatik suç işlemez. Bu sayılar test varsayımıdır; kesin üretim dengesi değildir.

Enerji bedeli olay başına tekrar uygulanmaz. Uyanık/uykuda geçen dakikalar kaynak veridir; enerji farkı bunlardan türetilir. Başlangıç enerji değeri saklanır. Sabah enerji değerini körlemesine 100 yapan mevcut satır aktif gece için kaldırılır; eski sessiz geceler geriye uyumlu kalır. Gündüz dinlenmenin enerji etkisi aynı teslimde açık biçimde gösterilir; sınırsız ücretsiz dinlenme yoktur.

## Kayıt şeması

Yeni sürüm (v5 aday) night_session: day, state (awake/sleeping/resolved), start_minute, cursor_minute, awake_minutes, asleep_minutes, initial_energy, resolved_boundaries ve morning_resolved. Sayaçlar negatif olamaz; toplam süre 480'i aşamaz; gün/saat ilişkisi doğrulanır. Kaydın yüklenmesi olay veya enerji bedelini tekrar uygulamaz. Eski v1–v4 kayıtları mevcut kesinti bilgisini korur; oynanmamış nöbet uydurulmaz. Eski Gün 4 kayıtları geriye dönük gece açmaz.

## Dosyalar ve bağımlılıklar

- scripts/time/night_session.gd: yeni sahne-yerel oturum denetleyicisi; açık begin/watch/wait/sleep/resolve yöntemleri ve sınır sinyalleri.
- scripts/core/game_state.gd: kalıcı oturum, modüler ekran saati/faz hesabı ve tek sabah tüketimi.
- scripts/save/save_manager.gd: v5 yapı ve gece aralığı doğrulaması; geçersiz kayıtta atomiklik.
- scripts/narrative/campaign_director.gd: seçenekler, maliyet onayı, olay kesmeleri ve sabah geçişi.
- scripts/narrative/power_incident.gd: uyanık/uyuyan anlatım ayrımı; neden/uygunluk kuralları aynı.
- scripts/dev/house_blockout.gd ve scripts/ui/room_view.gd: gece yarısından sonraki doğru saat/ışık ve kontrol aktarımı.
- scenes/main/house_blockout.tscn: NightSession düğümü; yeni autoload yok.
- localization/strings.csv: eylem, onay, uyku ve nöbet metinleri en/tr.
- tests/night_session_test.gd/.tscn: entegrasyon ve kayıt sınırları; Run-Tests.ps1 kapısı.

İlk uygulama genel procedural EventDirector değildir. Yeni olay bankası, görünür sakin koridor yürüyüşü, otomatik tanık sistemi ve final gece sanatı ayrı bağımlılıklardır.

## Zorunlu kabul matrisi

1. Gün 3 20:00'den nöbet/uyku seçimi aynı fiziksel elektrik nedenini korur; uyanık kişiye uyandı denmez.
2. 23:00→01:00→03:00→05:00→07:00 ekran saatleri doğru, ilk dört noktada kampanya günü ve tüketim aynı kalır.
3. Her sınırın hemen öncesi/sonrası kayıt-yükleme; enerji, kaynak, kanıt ve olay bir kez çözülür.
4. Sıfır/sağlıklı/enfekte sakin; Marcus yok/ölü/kovulmuş/izole/yorgun; iki onarım yolu korunur.
5. Onarım/inceleme gece yarısını geçebilir; sabah sınırını aşan eylem açıkça kesilir veya başlamadan uyarır. Kısmi kaynak harcaması yoktur.
6. Her sınırda kalan geceyi uyuma, bekleme iptali ve odadan dönme; kontrol ve fare modu geri gelir.
7. Tam nöbet, tam uyku ve karışık süreler; aynı dakika iki kez enerji harcatmaz. Yeni gün tek tüketim yapar.
8. Bozuk v5 ve v1–v4 göçü kampanya/enfeksiyon atamasını değiştirmez.
9. Pencere ışığı 00:00'de gündüze dönmez; 07:00'de şafak; kesinti bağımsızdır.
10. En/tr 1080p/1440p gerçek render; gece yürüyüşü ve kapı/oda geçişleri kullanıcı kontrolüyle ayrıca doğrulanır.

Bitti: çalışma kodu ve sahneler, tüm regresyon kapıları, gerçek gece renderı, kayıt turu ve açık sınırlar birlikte teslim edilir. Bu belgenin tamamlanması özelliğin tamamlanması değildir.
