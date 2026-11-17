# IMMERSION-BATCH-001 — Codex tasarım ve teknik kararı

17 Kasım 2026. Kaynak: masaüstündeki Claude_ChatGPT_Fikirler.txt ve sahibin Liste.txt dosyası. İstek: metni okuyup karar vermek. Bu belge inceleme/iş sırasıdır; özellikler uygulanmış veya sahibi bütün yeni ekleri onaylamış sayılmaz. Açık stil seçimi ve ek ekonomi kararları ayrıca korunur.

İnceleme tabanı: aktif 0.1.9 (8de58a6). ROOMS-002 ayrı dalda tamam (e065d7e), aktif sürümde yok. Zaman öğreticisi uygulaması inceleme bekliyor; tamamlanmış yayın gibi sunulmaz.

## Madde kararları

### I-01 AMEND — gündüz/gece ışığı; yeni yakıt ekonomisi yok

Gündüz ana kaynak pencereler; gece sıcak, yerel abajur/masa lambaları. Gündüz bütün elektrikli kaynakların otomatik açık kalması düzeltilmeli. Ancak “yalnız pencere” ifadesi fiziksel aydınlatma yönüdür: okunurluk için pencere ışığını temsil eden düşük dolgu kalabilir; ışık karanlığında gezinmek zorunlu kılınmaz. Sabah, akşam ve gece aynı kirli yeşil filtreyle tek görüntüye dönüştürülmez.

Kodda zaten daylight_factor ve gece/ay ışığı hesapları var. “Hiç gün/gece sistemi yok” doğru değil; aydınlatma sonucu ve elektrikli lamba davranışı incelenmeli. Gündüz ışıklarını kapatmak tek başına 2D oda görsellerini düzeltmez.

Claude'un eklediği lamba başına yakıt tüketimini kabul etmiyorum: yeni kaynak gerilimi/denge sistemi bu düzeltme için gereksiz. Mevcut jeneratör yakıt kuralları korunur. Geliştirme maliyeti orta; bağımlılıklar güç durumu, faz ve oda varyantları. Yeni aydınlatma ekonomisi eklemeden aynı deneyim sağlanır.

### I-02 AGREE — kesintide gerçek kararma, 3D ve 2D birlikte

Sorunun cevabı EVET: aktif sürüm house_builder.gd içindeki lambalar electric_lights grubunda (satır436); corridor_dressing.gd yardımcı ışığı da aynı grupta (263). HouseBlockout bunları kendi oturumundan toplar ve power_changed'e bağlı olarak görünürlüğü değiştirir (house_blockout.gd:133–166). Elektrikli armatürlerin emission_enabled durumu da değişir. Bu statik kaynak doğrulamasıdır; sahibin gördüğü arıza yeniden üretilmeden “sorun yok” denmez.

2D odalar RoomVisuals.resolve ve RoomView güç/zaman sinyalleriyle ayrı day/night/outage görseli seçiyor. Görselin içine boyanmış parlak lambayı yalnız 3D ışığı kapatarak söndüremeyiz. Elektrikli ışık, armatür emisyonu ve 2D oda varyantı tek güç sonucuna uymalı; pencereden ay/sokak ışığı kesintide kalabilir. Test: aynı kamera/gündüz-gece/güç var-yok; elektrikli aydınlık kalmamalı. Maliyet küçük–orta; I-01 ile aynı teknik sahip.

### I-03 AGREE — önce merdiven hatası

İnişte köşeye takılma öncelikli oynanış hatasıdır. Görünmez engeli büyüterek veya oyuncuyu ışınlayarak örtmeyelim. Merdiven rampası, alt/üst sahanlık, korkuluk çarpışması, oyuncu kapsülü ve iniş bağlantısı birlikte incelenmeli. Düz, çapraz, korkuluğa yakın iniş/çıkış ve birden çok kare hızında gerçek CharacterBody hareketiyle doğrulansın. Mevcut merdiven modeli rampa çarpışması kullanıyor; adım zıplaması sistemi eklemek ilk çözüm değil. Maliyet küçük–orta; yeni mekanik değil, zorunlu düzeltme.

### I-04 AMEND — kapı arkasındaki oda ilk aralıktan itibaren görünmeli

Teknik yön uygun: fiziksel kapının arkasında doğru oda görseli, kapı kanadının örtmesi ve aynı RoomVisuals kaynağının final RoomView'da kullanılması. Önce siyah boşluk, sonra beliren/büyüyen dikdörtgen olmamalı. Kamera ileri hareketi zorunlu değil; önce kapı hareketi ve görsel eşleşmesiyle en basit kesintisiz çözüm. Dolly kullanılırsa kısa ve azaltılabilir olmalı. Yeni serbest gezilen 3D oda üretmiyoruz.

Aynı gün/gece/güç dokusu iki aşamada da kullanılsın; son karede renk, kırpma veya NPC katmanı sıçramasın. İptal/Escape, arka arkaya etkileşim, açılırken zaman/güç değişimi ve dönüş ayrıca test edilir. Maliyet orta; I-01/02 sonrası görsel taban ve mevcut DoorTransition bağımlılığı var.

### I-05 AMEND — kapı deliği, sınırlı sokak; bodycam dalını topluca birleştirme

Kapı deliği kabul/ret döngüsünü besliyor. Ücretsiz bakış ve sınırlı görüş; yalnız görünür veranda, yol, çit, pencere/karşı ev silüetleri yeterli. Sokak gezintisi, zincirli kapı gibi ek ara mekanik ve kasaba üretimi bu pakete girmiyor. Balık gözü yalnız kapı deliğine uygulanmalı; tüm kameraya BODYCAM-V3 birleştirme onayı sayılmaz. Uygun mercek matematiği ayrı bileşen olarak alınabilir.

Bakış ziyaretçiyi yeniden seçmez, enfeksiyon bilgisini açmaz, sırf bakıldığı için zamanı/olayı değiştirmez. Boş kapı görüntüsü, sağlıklı/enfekte görsel eşitliği ve kapıdaki gerçek kişiyle tutarlılık şart. I-07 final çizimi beklenirken silüetle teknik prototip yapılabilir; final insan yüzü aynı stil seçimine bağlıdır. Maliyet orta; kapsam içinde açık dünya yok.

### I-06 AMEND — merkezi konum, basit yazarlı rutin

Rastgele her oda açılışında poz/konum seçimi yok. Öncelik sırası mevcut erişilebilirlik/izolasyon/olay durumu, aktif işin odası, yazarlı faz etkinliği ve yatak odası olmalı. Tek konum GameState ve gece tanıklığının kullandığı modelle uyumlu kalır. Ölü/kovulmuş kişi görünmez; izole kişi serbestçe dolaşmaz. İşte mutfakta olan kişi aynı anda yatakta gösterilmez.

Seed tabanlı çeşitlilik her şey için gerekli değil: ilk adım sabit faz/iş tablosu ve stand/sit/lie/work pozlarıdır. Anlamlı çeşitlilik gerektiğinde kaydedilmiş deterministik seçim eklenir. Ekrandaki NPC'nin bir anda başka yere ışınlanması önlenir. Görsel duruş enfeksiyon testi değildir. Maliyet orta; I-07 pozları ve mevcut merkezi konum API'si bağımlılık. Karmaşık ajan simülasyonu yok.

### I-07 AGREE — ilk sanat işi, sona bırakılmayacak

Elena için aynı kamera/ışık/ölçekte 2–3 özgün çizimsel aday; kontur, sade gölge ve sınırlı renk ayrıntısı karşılaştırılmalı. Fotogerçekçi yüz, PS1 pikselleştirme ve referans oyunun karakterini yeniden üretme yok. Temel silüet önce onaylanır; sonra aynı kişinin kapı deliği/oda ve oturma/yatma/çalışma pozları üretilir. Henüz seçilmemiş stil için18karakter ve onlarca poz üretmeyelim.

Bu seçim sahibi görerek yapmalı. I-05/I-06 final varlıkları buna bağlı; teknik iskeletleri beklemek zorunda değil. Maliyet tek aday setinde küçük–orta, tüm roster'a yayılım yüksek. I-07'nin P3'e bırakılmasına itiraz: ön hazırlığı P1 ile paralel başlamalı.

### I-08 AMEND — görünür enerji isteğini koru; olmayan tarih yasağı üretme

Liste.txt'deki sahip isteği bilekte enerji/saat/gündür. 90'lar dekoru, hikâyenin kesin olarak1990'larda geçtiği anlamına gelmez; incelenen kanonda mutlak yıl bulunmadı. Bu nedenle akıllı saati “anakronik” diye tek taraflı dijital saate çevirmiyorum. Kesin dönem onayı olmadan takvim yılı icat edilmeyecek.

GDD'deki kalıcı göstergeyi sınırlama kuralı isteğe bağlı açılan bilek ekranıyla çelişmek zorunda değil. Enerji bilgisi gerçekten okunmalı; titreme/nabız bunun yerine geçirilmez (nabız enerji ölçeri değildir). Tasarım yönü: çizimsel kol, kısa giriş/çıkış animasyonu, gün/saat ve mevcut Energy'den gelen sade enerji göstergesi. Yeni stres/nabız biyometrik sistemi veya saat pil ekonomisi yok. Hareket azaltma seçeneğinde hızlı/sakin geçiş.

Tab şu an journal'a bağlı. Seçilen giriş yönü: Tab bilek, J günlük; I envanter/E etkileşim/Escape geri aynı. Uygulamada yeniden bağlama, günlük kapatma, dinamik tuş ipuçları ve menü odakları birlikte güncellenmeli. Bu belge kodun değiştiği anlamına gelmez. Bilek cihazının son çizimi I-07 paletine uymalı; önce küçük bir örnek, sonra animasyon. Maliyet orta; mevcut enerji/zaman verisi yeterli.

### I-09 AMEND — efektten önce ışık ve malzeme

Güçlü filtreyi düzeltme yerine koymayalım. Aynı sahne/kamera, aynı saat ve aynı pozlamayla üç kontrollü renk/post-process adayı gösterilsin; ışık değişkenlerini karıştırmayalım. Kirli yeşil/turkuaz gölgeler, kontrollü sıcak ışık, dengeli duvar/halı/tavan korunur. Ağır piksel, zorunlu balık gözü, aşırı grain/blur/karanlık yok; esas oyun kamerası okunur kalır.

Final seçim sahibin görsel kabulüyle sabitlenir; yoğunluk/azaltma ayarı bulunur. I-01/02 tabanı sonrası; shader denemeleri küçük maliyetli, yanlış stilin bütün varlıklara yayılması pahalıdır. BODYCAM dalının tümü otomatik kabul edilmez.

### I-10 AGREE — yaşanmışlık, yeni aile hikâyesi eklemeden

Saksı, ayakkabı, askılık, birkaç kişisel eşya, uyumlu halı/perde ve yerel lambalar işe yarar. Her yüzeyi eşya ile doldurmak okunurluğu/çarpışmayı bozabilir. Koridor ve merdiven geçişleri açık; eşya yoğunluğu belirli köşelerde. Fotoğraflar görsel ev geçmişini ima edebilir; yeni akraba, ölüm veya kişisel olay metni kanon diye icat edilmez. Daniel'ın evi babasından miras aldığı mevcut kanondur.

Nötr dekor prototipi için yeni anlatı onayı beklemek gerekmez; belirli aile bireyi/öykü eklemek ayrı karar. Maliyet küçük–orta; lamba/prop kodu I-01 ile aynı dosyalara yazacağı için eşzamanlı ayrı kod yazarı yok. Varlık eskizleri paralel yapılabilir.

### I-11 AGREE — üst kat ölçeği, I-03 ile aynı teknik sahip

Oyuncu boyu, kapı yüksekliği/aralıkları, tavan, halı ve sahanlık aynı ölçü sisteminde karşılaştırılmalı. Evi körlemesine büyütmeyelim; doğru ölçülü kapı yanında hatalı halı/model ölçeği de orantısızlık yaratabilir. Amaç yeni plan değil, inanılır ve geçilebilir mevcut ev. Oda kimliği/yatak sayısı/olay erişimi korunur. Plan değişirse HouseLayout ve HousePlan aynı teslimde güncellenir.

Claude merdiveni düzeltirken Queue'nun aynı HouseLayout/HouseBuilder'a yazması yanlış. I-03 ölçüm ve düzenlemesi tek elde; I-11 bunun sonraki kontrollü aşaması. Maliyet orta, fizik/gezinme regresyonu zorunlu.

### I-12 AMEND — temel ev sesi uygun, yeni büyük müzik sistemi yok

Gıcırtı, boru, rüzgâr ve az sayıdaki elektrikli cihaz tonu atmosferi destekler; sesin gerçek kaynağı olmalı. Elektrik uğultusu kesintide durur; rüzgâr/ahşap sesi sürebilir. Çelişkili sahte kanıt veya olmayan NPC adımı üretilmez. Kritik sesin altyazı karşılığı ve kategori ses ayarları korunur. Var olan DoorAudio yerine ikinci kapı sesi eklenmez.

Lisansı belirsiz hazır ses veya yeni müzik kapsamı yok. İlk geçiş minimum özgün/yer tutucu katman; final Foley ayrı varlık üretimi. Maliyet küçük–orta; I-01/02 güç olayı ve ses yaşam döngüsü testleri bağımlılık.

## ORDER — değiştirilmiş sıra

1. Tek doğrulama tabanını kur: zaman öğreticisini bağımsız incele, ARRIVALS-002'yi kontrollü entegre et, ROOMS-002 görsel açıklarını kaydet. Geçmiş dört-gün içerik kaybolmasın. Bunu sanat işine aylar süren engel yapma.
2. P1: I-03 merdiven; I-01+I-02 ışık/güç. I-11 ölçümünü aynı fizik sahibi yapsın. I-07 Elena aday hazırlığı paralel başlayabilir; son stil sahibi seçer.
3. P2: I-04 oda geçişi; I-05 kapı deliği ve sınırlı dış görünüm. I-10 dekor aynı 3D sahibiyle; I-12 minimum ses güç düzeltmesini takip eder.
4. P3: seçilmiş Elena stiliyle I-06 rutin/poz; I-08 bilek önizlemesi ve giriş eşlemesi.
5. I-09 son renk karşılaştırması, P1 ışık tabanı sabitken; bütün evin final varlıklarına yayılmadan önce sahibin görsel kabulü.

Her aşama küçük, bağımsız denenebilir teslimdir. Hepsi tek dev iş veya tek toplu merge olmayacak. Yeni kamera/art adayı otomatik ana sürüme alınmaz.

## OWNERSHIP — dosyaya göre tek yazar

Claude masaüstü: I-03 ve I-11 fizik/ölçek; ardından I-01/I-02 ışık/güç; sonra I-04/I-05, I-10 dekor. Hepsini aynı anda başlatmak yerine her biri claim ve açık dosya listesiyle seri alınmalı. ARRIVALS-002 teslimiyle çakışan Run-Tests güncellemesi aynı kişi tarafından bir kez yapılır.

Codex: I-07 sanat adayı şartnamesi ve karşılaştırma; seçildikten sonra I-06 merkezi rutin/2D poz entegrasyonu; ayrı aşamada I-08 bilek/input. Sahip tercih etmeden final stil/roster üretimi yok.

Queue: bu paket için henüz yeni iş verilmedi. HouseBuilder/HouseLayout/house_blockout'a başka çalışan paralel yazmaz. Yalnız bağımsız varlık veya salt okunur test/inceleme işi dar izinli listeyle verilebilir. I-12 ses, sahne/power bağlama işi Claude'un ışık teslimiyle seri; tek başına AudioManager sistemi büyütülmez.

## Açık maddeler ve kabul ölçütü

- AUTO-DAY1-TIME-GUIDANCE şu an waiting_reviewer; deneme94feb4d'nin varlığı Codex incelemesi veya ana sürüm yayını değildir. Kota nedeniyle CLI incelemesi bekliyor; aynı kaynak yerel olarak ayrıca incelenebilir, bekleme otomatik başarı sayılmaz.
- ARRIVALS-002 8fa1409 teslim edilmiş, bu incelemede aktif sürüme alınmadı. Önce gerçek kaynak/diff ve birleşik test kapısı.
- BODYCAM-V3 b4666dd tüm paketi beklemeye devam eder. Kapı deliğinde sınırlı shader tekrar kullanımı genel kamera kabulü değildir.
- I-02 kaynak bağlantıları doğrulandı, görsel kusurun nedeni henüz yeniden üretilmedi. I-03 için yürüyerek yeniden üretme henüz bu incelemede yapılmadı.
- I-07 ve I-09 görsel seçenekleri henüz üretilmedi. Bu karar dosyası yeni oyun, görsel veya animasyon teslimi değildir.
- Görsel kabul: aynı kamera/gündüz-gece/güç var-yok görüntüleri; düşük hareket ayarı; 720p/1080p okunurluk. Oyun kabulü: merdiven geçişi, aynı kapı/oda durumu, gerçek NPC/tek konum ve save/load. Yeni veri alanları kaybolmamalı.
