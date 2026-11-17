# Gün4 tahliye yayını — DAY4-RADIO-001

## Amaç ve kapsam
Ana spesifikasyondaki Gün4 uzak tahliye bölgesi duyurusunu bağlamak. Yayın kaynağı ve güvenli güzergâh doğrulanmış değildir; bu bir iddiadır. Day4Design kapsamındaki çekirdek inceleme/karar akışını tamamlayan haber parçası; sonraki gece, Gün5, tahliye yolculuğu veya son açmaz. Bu teslim metin/anlatım, günlük ve kayıt davranışıdır. Yeni seslendirme, müzik veya radyo statik sesi üretilmedi; mevcut ses kapsamı kapı/boru geçicileridir.

## Dosyalar ve kurulum
- scripts/narrative/day4_broadcast.gd: CampaignDirector.day4_broadcast RefCounted; ShelterManager sahne-yerel enjekte edilir.
- resources/events/day4_broadcast.json: gün,15dk,sabit kayıt ID ve metin/claim anahtarları. resources/evidence/day4_broadcast.json: yalnız claim.
- scripts/narrative/campaign_director.gd: Gün4 radio etiketi/süresi/eylemi; diğer günler eski yoldadır. LAST_AUTHORED_DAY artık4; Gün4 sabahındaki yanlış erken kesit-sonu kaldırıldı, notlar/radyo yönlendirmesi eklendi. _resolve_night gün>=4 koruması değişmedi.
- scripts/narrative/day4_review.gd: yalnız gerçekten alınmış mesaj güncel özete eklenir.
- scripts/evidence/evidence_manager.gd ve scripts/save/save_manager.gd: katalog ve semantik kalıcılık.
- localization/strings.csv:8EN/TR anahtarı. tests/day4_broadcast_test.gd/.tscn ve Run-Tests kaydı.

Mevcut hiyerarşi: HouseBlockout→CampaignDirector→day4_broadcast (RefCounted); RoomView oturma odası Radio eylemi/anlatımı; JournalView claim. Yeni Node/autoload/model/eklenti yok. Godot4.7.2 ile import; Start-Game.ps1 veya masaüstü kısayolu. Kurulu motor kullanılır, standalone export değildir.

## Davranış
Gün4 oturma odasında acil durum kanalını ilk dinlemek15dk. Pilli radyo elektrik kesintisinde de çalışır; yakıt/kaynak/yardımcı veya NPC gerekmez. Uzak tahliye kabul bölgesi duyurulur, konum ve diğer talimatlar cızırtıda kaybolur; güvenli yol veya kurtuluş garantisi verilmez. Rota/tarih uydurulmaz, gerçek yayıncı kimliği açıklanmaz. Önceki hafıza kaybı uyarısı hiç duyulmamışsa aynı dinleme içinde tekrar edilir ve öğrenildiği kaydolur. Önceden duyulmuşsa yeniden zorlanmaz.

İlk tam dinleme tek claim ekler. Sonraki eylem açıkça ücretsiz not okumasıdır; yeni bir yayın alındığı veya zaman geçtiği iddia edilmez. İlk dinlemede tekrar edilen eski uyarı notlarda da korunur. Genel bilgi kişiye yönelik suçlama dayanağı listesine eklenmez. Dinlememek Gün4 kapanışını engellemez; kapanış sonrası keşif sırasında da alınabilir, tamamlanma saati değişmez. Uydurulmuş bilgiye dönüşmemesi için duyulmamış mesaj özette görünmez.

Day4 yalnız ve sağlıklı ya da enfekte Daniel için aynı içerik. Bütün sakin durumları/seed/enfeksiyon/enerji/erzak korunur. Aktif ziyaretçi kesintisinde yeni dinleme bekler; yeni içerik odadan çıkıp görüşmeyi bitirdikten sonra alınır. Yeterli15dk yoksa ne kısmi bilgi ne bedel uygulanır. Diğer sakinlerin bu arada biten gündüz işleri aynı adayda çözülür.

## Kayıt / hata
Save v5 optional flags: day4_evacuation_heard(bool), day4_evacuation_heard_at(tam bitiş dakikası), day4_radio_included_memory(bool). heard_memory_loss_report ve radio_day_4 önceki sistemle aynı bayraklardır. Eski radio_day_4=true tek başına yeni duyuruyu duyulmuş yapmaz; yeni eylem hâlâ15dk. Eski kayda haber eklenmez.

Gün>=4,435–1439 bitiş saati, mevcut gün/saat sırası, tek doğru claim ve ilk dinleme başlangıcıyla claim zamanının eşliği doğrulanır. Yetim claim, bozuk tip, eksik zaman/katalog veya çelişen öğrenme işaretleri reddedilir. SaveManager.commit_candidate önce diske yazıp sonra canlı uygular. Yazma hatasında saat, bilgi, claim ve iş raporları değişmez; normal başarısız kayıt mesajı ve tekrar yolu vardır. Geçici onay veya rastgele seçim yok.

## Deneme ve bitti
Gün3 gecesinden Gün4 sabahına gel→erken bitiş mesajı yerine araştırma yönlendirmesi→oturma odasında radyo→Tab günlük→Daniel odasında inceleme→20:00 bekleme→kapanış. Bu gerçek motor zinciri otomatik testte uygulanır. Gün5 açılmaz. Eski Gün4 kayıtları da eylemi sunar.

Test matrisi0/3sakin×elektrikvar/yok×hafıza raporu duyuldu/kaçtı×sağlıklı/enfekte Daniel. İlk15dk, ücretsiz doğru not tekrarı, sourceclaim ve özet, suçlama dayanağına sızmama, save/load tam eşitlik, pending dosya yazma hatası, başka iş bitişi, bozuk tip/zaman/yetimclaim, geçsaat, radyoyu kaçırıp kapanış ve kapanış sonrası keşif. EN/TR720p/1080p/1440p anlatım/düğme sınırları ve gerçek GPU iki görüntü. Elle tam oynama veya radyo seslendirme testi sayılmaz.

Sık hatalar: İlk eylem bir kez15dk; daha sonra bedava olan not okumasıdır. Anahtar görünürse CSV yeniden import edilmeli. Kayıtta sadece eski radio_day_4 olması yeni yayını atlamaz. Elektrik kesik diye radyoyu kapatma veya yakıt eksiltme yapılmamalı.

Bitti ölçütü: ilgili test+tam regresyon+GPU görsel inceleme+launcher sürümü+Git/devir. Sonraki bağımlılık Gün5 sinyal soruşturması, karakter/ilişki genişlemesi ve nihai sanat/sestir; genel kampanya tamamlanmadı.

Sonuç:28 paket/7078 WASAPI PASS; radyo245. Son GPU249PASS, iki ilave dil başlık/ipucu kontrolü ve iki yakalama dahil. GPU fixture oda başlığının da doğru dilde kurulması için her dilde odayı yeniden açar; bu son test düzenlemesi ürün kodunu değiştirmez. EN/TR görüntüler incelendi. Günlük C:\Users\eyups\AppData\Local\Temp\tqh-tests-a17ee915c33f413f9280306113db0ec5; day4-radio-last-run.json. Claude salt okunur incelemesinde bloklayan hata bulmadı; JSON önbelleği ve420 yerine DAY_START kullanımı düşük öncelikli teknik borç, bu checkpointte çözülmüş sayılmıyor.
