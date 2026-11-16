# Gün 2 — Strangers / Yabancılar

Durum: Uygulama şartnamesi; **henüz oyunda uygulanmadı**.
Yazan: Codex, DAY2-001, 2026-11-16.
Kaynak: ana spesifikasyon Gün 2; NarrativeBible ve DecisionLog.
Bağımlılık: SAVE-002'nin çalışan yeni oyun / devam akışı. Kodlama ayrı görevdir.

## 1. Amaç ve sınır

Oyuncu ilk kez bir ev sahibi olmaktan barınak yöneticisi olmaya geçer.
Yeni baskı, daha çok ağız ve farklı insanların bir arada yaşamasıdır.
Marcus ve Arthur isteğe bağlıdır; ikisini de reddetmek kampanyayı durdurmaz.
Elena'nın önceki gün reddedilmesi, unutulması veya ölmesi geçerli başlangıçtır.

Günün hedef süresi 18–25 dakika; saat 07:00–23:00. Ölçüm oynanış testinde yapılacak.
Bu gün cinayet, zorunlu sabotaj, teşhis testi, dışarıda keşif veya NEXUS açıklaması eklemez.
Gece hafıza kaybı yayını duyulur; söylenti bir sakinin enfekte olduğunu doğrulamaz.

## 2. Sabah ve gündüz akışı

| Bölüm | Tetik / içerik | Tamamlama koşulu |
|---|---|---|
| Sabah | Gün 2, 07:00; Gün 1 gece özeti | Tek sefer gösterilir; yükleme tekrar üretmez |
| Yönetim tanıtımı | En az bir sakin varsa oda ve iş atama açıklaması | Atama zorunlu değil; kapatılabilir |
| İlk ziyaret | Marcus, 10:00–13:00 | Kabul / ret / vazgeçip gitme |
| Öğleden sonra | Envanter veya güvenlik kontrolü; radyo | En az bir eylem önerilir, zorlanmaz |
| İkinci ziyaret | Arthur, 15:00–18:00 | Kabul / ret / vazgeçip gitme |
| Akşam | Kişi sayısı ve gece tüketim tahmini; uyku hazırlığı | Kararlar geri alınamaz geçişten önce özetlenir |
| Gece | 23:00'e kadar bekle veya 20:00 sonrası uyku | Gün 3, 07:00; yalnızca bir günlük tüketim |

Marcus ve Arthur'un saatleri dengeleme varsayımıdır; kritik yaratıcı değişiklik değildir.
Ziyaret pencereleri olay verisinde tutulur, NPC adına göre büyüyen match bloğunda tutulmaz.
Mevcut saati ilerletmeyen serbest koridor yürüyüşü kuralı korunur.

### Zaman atlama ve kaçırma kuralları

Bir eylem açık ziyaret saatini aşacaksa önce “Bu sırada kapıdaki kişi gidebilir”
uyarısı verilir. Oyuncu vazgeçebilir; zaman veya kaynak değişmez.
Henüz görünmemiş bir ziyaret başlangıcını aşan bekleme/dinlenme, ilk kapı çalınışında
kesilir. Eylemin kalan süresi harcanmaz, ayrıca kaydedilip otomatik sürdürülmez.
Örnek: 09:40'ta bir saat dinlenmek 10:00'da durur; 20 dakika geçer, Marcus kapıdadır.

Bu, uzun beklemeyle iki karakterin habersizce kaçırılmasını önler. Kapıyı duyduktan
sonra kasten beklemek geçerli tercihtir. Süre bitince durum left olur; rejected olmaz.
Yüklenen kayıtta bekleyen ziyaret aynı kişi ve aynı son saatle devam eder, yeniden atanmaz.
Bir NPC aynı gün ikinci kez gelmez. Aynı anda en çok bir kişi kapıdadır.
İleride çakışan pencerelerde öncelik: başlangıç saati, sonra olay kimliği alfabetik.

## 3. Marcus'un gelişi

Kısa, doğrudan konuşur; açık kapılara ve tesisata bakması mesleki alışkanlıktır.
Sağlıklı ve enfekte sürümde karşılama metni aynıdır. Yüz, ses veya ilk cevap enfeksiyon
testi olarak kullanılamaz. Suçluluğu geçmişte terk ettiği barınaktan kaynaklanır.
Bu geçmişin ayrıntıları Gün 2'de zorla açıklatılmaz.

| Düğüm / anahtar | İngilizce ilk metin | Sonuç |
|---|---|---|
| D2_MARCUS_HELLO | “Marcus Hale. Electrician. I'm looking for somewhere that still has a lock on the door.” | Soru listesi |
| D2_MARCUS_ASK_ORIGIN | “Where did you spend last night?” | 5 dakika |
| D2_MARCUS_ORIGIN | “A shelter off County Road. I left before daylight.” | Önceki barınak hakkında bir iddia |
| D2_MARCUS_ASK_WORK | “What can you help with?” | 5 dakika |
| D2_MARCUS_WORK | “Wiring. A generator, if you've got one. I won't promise parts you don't have.” | Elektrik becerisi öğrenilir |
| D2_MARCUS_ASK_ALONE | “Anyone else with you?” | 5 dakika |
| D2_MARCUS_ALONE | “Not now.” | Eksik cevap; enfeksiyon kanıtı değil |
| D2_MARCUS_ADMIT | “Come inside. We'll find you a bed.” | Boş yatak seçimi / kabul |
| D2_MARCUS_REJECT | “I can't let you stay.” | Son onay |
| D2_MARCUS_REJECTED | “Then keep the door locked.” | rejected; ziyaret biter |

Sorular birer kez sorulur; konuşmayı kapatmak ziyaretçiyi otomatik reddetmez.
Kabul veya ret açık onaydan sonra kesinleşir. Uyku yerini seçmeden kabul tamamlanmaz.

## 4. Arthur'un gelişi

Nazik, ölçülü, uzun konuşmayı seven fakat burada kısa kalan bir öğretmen.
Otoriteyi ele geçirmeye çalışmaz; önce evin kurallarını sorar. Eski öğrencisi hakkındaki
sır bu gün otomatik ortaya çıkmaz. Sağlıklı/enfekte duruma göre karşılama değişmez.

| Düğüm / anahtar | İngilizce ilk metin | Sonuç |
|---|---|---|
| D2_ARTHUR_HELLO | “Arthur Bell. I used to teach at the high school. Would you hear me out?” | Soru listesi |
| D2_ARTHUR_ASK_ORIGIN | “Where have you been staying?” | 5 dakika |
| D2_ARTHUR_ORIGIN | “The school gym, until yesterday. There were too many people arguing over too few things.” | İddia |
| D2_ARTHUR_ASK_WORK | “What could you do here?” | 5 dakika |
| D2_ARTHUR_WORK | “Keep records. Take a watch. Listen, when people still want to be heard.” | Envanter/nöbet işleri için aday |
| D2_ARTHUR_ASK_RULES | “Would you follow my rules?” | 5 dakika |
| D2_ARTHUR_RULES | “Tell me what they are. I won't agree to a rule I haven't heard.” | Açıklık isteği; otomatik güven cezası yok |
| D2_ARTHUR_ADMIT | “You can stay. Let's choose a bed.” | Boş yatak seçimi / kabul |
| D2_ARTHUR_REJECT | “I can't offer you a place here.” | Son onay |
| D2_ARTHUR_REJECTED | “I understand. Please don't leave someone waiting all night.” | rejected; ziyaret biter |

Metinler özgün ilk taslaktır; henüz JSON diyalog dosyasına veya CSV'ye eklenmedi.
Uygulamada İngilizce ve Türkçe anahtarlar birlikte teslim edilir; NPC özel adları çevrilmez.

## 5. Radyo ve bilgi sınıflandırması

RADIO_D2_MEMORY_LOSS:

> “County emergency services have received reports of people unable to account
> for their movements during the night. These reports remain unverified.
> Keep a written record. Do not act on a single accusation.”

Günde ilk dinleme 15 dakika; sonraki dinlemeler aynı gün bilgiyi çoğaltmaz.
Günlükte “yayında söylenen iddia” olarak tutulur, “enfeksiyon doğrulandı” olmaz.
Oyuncu radyoyu kaçırırsa Gün 3 sabahında yeniden dinlenebilir.
Elena varsa aynı söylentiyi bir hastadan duyduğunu söyleyebilir; bu bağımsız
doğrulama sayılmaz, çünkü ilk kaynağın aynı olabileceği bilinmez.
Kimse bunu duymadan hafıza kaybı hakkında bilgiliymiş gibi konuşmaz.

## 6. Yatak ve oda atama

İlk toplam altı NPC yatağı: guest_a, guest_b, multipurpose odalarında ikişer yatak.
Daniel'ın yatağı bu kapasiteye dahil değildir. isolation odasında normal kabul yatağı yok;
onu yedinci bedava yatak olarak kullanmak kapasiteyi sessizce artırır ve uygulanmaz.
Odadaki 2D figür konum sayısı yatak kapasitesi değildir.

Elena'nın Gün 1'de aldığı oda korunur. İki yatak aynı odada iki farklı bed_id taşır.
Örnek: guest_a_1, guest_a_2. Uyku oda kimliği yatak tanımından türetilir.
Kabul ekranı otomatik boş yatak önerir; oyuncu değiştirebilir. Kapasite doluysa
kabul devre dışı, açık gerekçe görünür. Birini sessizce kovarak yer açılmaz.

Yönetim ekranında birden çok değişiklik tek oturumda tasarlanır. Onay 15 dakika,
iptal 0 dakika; sadece ekranı açıp kapatmak ücret üretmez. Onay anında bütün değişiklikler
yeniden doğrulanır ve tek işlem olarak uygulanır. Bir yatak iki kişiye verilemez.
İki sakini takas etmek geçici kapasite hatasına takılmamalı; son dağılım doğrulanır.
Bu gün oda tercihleri tavsiye olarak görünür; yeni zorunlu kişisel çatışma yazılmaz.

## 7. İş atama ve konum tutarlılığı

İlk uygulama dört işi açar: envanter, yemek, güvenlik hazırlığı ve gece nöbeti.
Temizlik, çocuk bakımı ve gerçek onarım daha sonraki içerikle açılır; sahte işler sunulmaz.
Bu, tüm oyunun yedi işini azaltmaz; öğretimi kademelendirir.

| İş | Gereken erişim / süre | Gün 2 çıktısı |
|---|---|---|
| Envanter | Kiler; 60 dakika | Bir kez kesin stok özeti; kaynak yaratmaz |
| Yemek | Mutfak; 60 dakika; yiyecek mevcut | Öğün hazır bayrağı ve diyalog tepkisi; şimdilik tüketimi azaltmaz |
| Güvenlik | Giriş / tesisat erişimi; 60 dakika | Kapı kontrol raporu; uydurma hasar ve tamir maliyeti yok |
| Gece nöbeti | Giriş holü; o gece | “Dikkate değer hareket görmedim” raporu; risksiz gece için sahte suçlu yok |

Yemek verimliliği sonraki dengelemede açılacak; Gün 2'de yiyecek sayısını büyüten
veya tekrar atamayla sınırsız tasarruf üreten bir formül eklenmez.
Bu gün beceri farkı raporun ayrıntısını etkiler; işi gereksizce NPC'ye kilitlemez.
Marcus güvenlik/tesisat, Arthur envanter, Elena bakım bilgisiyle yemek için önerilebilir;
hiçbiri iş yapmaya zorlanmaz. Atanmamış olmak açlık veya zorunlu başarısızlık değildir.

Her sakine aynı anda bir aktif iş. İş başı/end_at oyun dakikasıyla saklanır.
İşe yeniden atama eski işi iptal eder; eski süre tamamlanınca ikinci ödül vermez.
İşten ayrılma, ölüm, kovulma veya izolasyon işin çıktısını iptal eder.
Yaralı/yorgun veya erişimi olmayan sakin gerekçeyle reddeder; zaman ve kaynak harcanmaz.
İlk dengelemede güven -40 ve altıysa gönüllü işi reddeder; bu eşik UI'de sayı göstermez.

sleep_room ile activity_room ayrı tutulur. Örneğin Elena mutfaktayken yatak odasının
2D katmanında da görünemez. Kapalı odalarda etkinlik konumu zaman eşiğinde güncellenir;
kapı açılınca güncel konum çizilir. Açık oda ekranında kişi çıkarsa katman kısa solmayla
kaldırılır; aynı figür bir kare boyunca iki odada gösterilmez.
Koridorlarda NPC yürüme animasyonu bu kapsamda yok; fiziksel hareket gözlenmiş gibi
tanıklık veya delil üretilmez. Gelecek gece gözlemleri ayrıca yazılacaktır.

## 8. Kaynak baskısı ve gece

Gün 1 sonunda Elena kabul edilmişse yiyecek 10, su 12; yalnız Daniel varsa 11 ve 13.
İki yeni kişi kabul edilip Elena da içerideyse Gün 2 gecesi kişi sayısı 4 olur:
Gün 3 sabahı yiyecek 6, su 8. Atama yapmak bu tüketimi ikinci kez tetiklemez.
Ekran mevcut stok ile beklenen gece tüketimini ayrı gösterir. Eşit stok yetiyor sayılır;
eksik stok bir gün önceden uyarılır. Eksikliği sessizce 0'a kırpmak kıtlık raporu yerine geçmez.

Bu gün yazar kaynaklı saldırı veya sabotaj yok. Enfekte sakinler pasif kalabilir.
Oyuncuya ilk nöbet tercihi gösterilebilir; asıl dört bloklu aktif gece sistemi bu kapsamda
uygulanmış sayılmaz. “Nöbet tut” seçeneği gerçekten oynanmıyorsa sunulmaz.
Uyuma ve gün geçişi var olan akışı kullanır; Gün 3'ün içerik sınırı açıkça belirtilir.

## 9. Dayanıklılık matrisi

| Durum | Zorunlu davranış |
|---|---|
| Elena sağlıklı veya enfekte, resident | Mevcut oda/güven korunur; işleri gönüllü alabilir |
| Elena rejected / left / unknown | Sesi, portresi veya yönlendirmesi görünmez; UI öğretir |
| Elena dead / expelled | Normal konuşma yok; işi ve yatağı temizlenir; anı isteğe bağlı |
| Elena isolated | Oda erişimi sınırlı; ev içinde iş yapmaz; izolasyonda geçerli konuşma varsa kullanılır |
| Marcus/Arthur sağlıklı veya enfekte | Aynı karşılama; gizli atama değişmez; pasif enfekte geçerli |
| Marcus/Arthur zaten dead / expelled / rejected / left | Aynı NPC'yi ziyaret olarak geri yaratma |
| Marcus/Arthur isolated | Kapıda bekleyen veya normal işe uygun sayma |
| Her ikisi reddedildi / gelmedi | Tüm yönetim atlanabilir; Daniel kendi işlerini yapar; gün ilerler |
| Daniel sağlıklı | Normal rota; zorunlu maruziyet yok |
| Daniel enfekte (test/gelecek kayıt) | Yeni enfeksiyon ataması yok; erişilebilir çekirdek bilgi aynı |
| Radyo bilgisi kaçırıldı | İlerleme kilidi yok; sonraki gün tekrar dinlenebilir |
| Hiç enfekte resident yok | Kıtlık, söylenti ve sosyal baskı; enfekte fail uydurulmaz |
| Kayıt ziyaret sırasında yüklendi | Bekleyen kişi, süre ve atama aynen korunur; yeni ziyaret tekrarlanmaz |

Bu gün öldürme/kovma/izolasyon arayüzünü tanıtmaz; testte bu durumlar verilirse
yukarıdaki kontroller uygulanır. Önceki gelecek kayıtların varlığı NPC'yi diriltmez.

## 10. Uygulama sınırları ve veri sözleşmesi

Önerilen yeni dosyalar (henüz oluşturulmadı):
- resources/events/day2_arrivals.json: kimlik, NPC, başlangıç/bitiş, gün, fallback.
- resources/dialogue/marcus_arrival.json ve arthur_arrival.json: mevcut diyalog biçimi.
- resources/jobs/day2_jobs.json: süre, yer, uygunluk, çıktı kimliği.
- scripts/shelter/shelter_manager.gd: yatak ve tek işlemli atamalar; sahne-yerel.
- scripts/shelter/job_manager.gd: zaman değişiminde iş çözümleme; sahne-yerel.
- scripts/ui/shelter_view.gd: uyku yeri, iş ve tüketim tahmini.
- tests/day2_test.gd ve .tscn: aşağıdaki kabul matrisi.

Gerekli kalıcı alanlar: beds (bed_id → npc_id), jobs (npc_id → job_id, start_at,
end_at, activity_room), completed_job_ids, resolved_arrival_ids ve rapor kimlikleri.
State alanları değişecekse SAVE_VERSION artırılır ve v1 göçü yazılır. Eski `npcs.room`
alanı ilk boş yatakla eşleştirilir; çakışan kayıtta karakter silinmez, kullanıcıya hata
gösterilir. Enfeksiyon eşleşmesi göç sırasında yeniden hesaplanmaz.

V1 kayıtlarında ziyaret sonucu NPC status'undan, Elena gelişinin çözülmüş olması
mevcut bayraklardan çıkarılır; yeni ziyaret kimlikleri yalnızca bundan sonra doldurulur.
Göç deterministik ve tekrar uygulanabilir olmalı, sessiz hikâye kararı vermemelidir.

SAVE-002 bittikten sonra gerçek API'ler yeniden okunacak. Bu dosyadaki öneriler
mevcut olmayan fonksiyon veya sinyallerin var olduğunu iddia etmez.

## 11. Kabul testleri ve bitti tanımı

1. Elena'nın kabul/ret/kapıyı açmama Gün 1 kayıtlarından Gün 2'ye gir.
2. Marcus ve Arthur için kabul/ret/kaçırma: 3×3 sonuç kombinasyonunda Gün 3'e ulaş.
3. Yeni sakinlerin enfeksiyon bayrakları yeni oyunla aynı; yükleme ve yatak ataması değiştirmez.
4. 09:40'ta dinlenme 10:00'da kesilir; 13:00'ı geçen açık bekleyişte Marcus bir kez left olur.
5. Yükleme ziyaretçiyi çoğaltmaz; kaçmış veya ölmüş kişiyi kapıya getirmez.
6. Aynı yatağa iki kişi atanamaz; dolu kapasitede kabul açıklamalı reddedilir; yatak takası geçer.
7. Yönetim iptali 0, geçerli onayı 15 dakika; geçersiz onay veriyi yarım uygulamaz.
8. Aynı işin iki kez çözülmesi stok/rapor çoğaltmaz; ölme/izolasyon işi durdurur.
9. Sakin aynı anda iş ve yatak odasında görünmez; UI gizli enfeksiyonu sızdırmaz.
10. Dört kişi için Gün 3 stoku örneği tutar; kıtlık önceden bildirilir.
11. İki karakter de yokken gün tıkanmaz; radyo kaçırılması ana gizemi kilitlemez.
12. V1 göçünde enfeksiyon, güven, gün/saat ve kararlar değişmez; v2 round-trip kayıpsızdır.
13. İngilizce/Türkçe uzun cevaplar 1080p ve 1440p'de taşmaz; klavye odağı görünür.
14. İş arayüzü, kabul onayı ve akşam tüketim özeti gerçek pencerede elle denenir.

Bitti tanımı: bu maddeler kodda ve içerikte karşılanır, ilgili regresyonlar geçer,
gerçek ekran görüntüleri incelenir. **Bu tasarım dosyasının varlığı Gün 2'nin bitmesi değildir.**
Gün 3 sabotajı, aktif gece nöbeti ve sonraki karakterler ayrı görevlerdir.
