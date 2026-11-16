# Gün 4 — Accusation

DAY4-DESIGN-001 · 2026-11-16 · **Uygulama şartnamesi; uygulanmış özellik değildir.**
Dayanak incelemesi: `automation/integration`, `bf86b12`; eşzamanlı sanat değişiklikleri kapsam dışıdır.
Bu teslim yalnız bu dosyayı oluşturur. Kod, sanat, koordinasyon, stage/commit/branch işlemi içermez.

Ana ajan incelemesi: belge tasarım teslimidir; basit inceleme paneli tek başına özgün Gün 4 suçlama sahnesini tamamlamaz. Yeni kampanyada gerçek gece hareketine dayalı çelişkili ifade için aşağıdaki önkoşul da gerekir; eski kayda geçmiş tanık eklenmez.

## 1. Kaynak ve sınır

AGENTS, CLAUDE, DecisionLog, STATUS, koordinasyon TASKS/HANDOFF ve messages altındaki sekiz mesaj okundu.
Kök TASKS/HANDOFF bulunmadığından `docs/coordination/` kopyaları esas alındı; koordinasyonu ana ajan yönetir.
GDD, NarrativeBible, Day3Design, NightWatchDesign; campaign_director/game_state, power_incident,
shelter_manager, evidence_manager, save_manager ve mevcut olay/kanıt/metin verileriyle karşılaştırıldı.
Özgün uzun spesifikasyon proje belge listesinde bulunmadı; görülmüş sayılmaz. Görevde verilen Accusation kapsamı uygulanır.
Karar önceliği: bu görev talimatı ve DecisionLog; tarihsel taslakların uygulama iddiaları güncel kodla doğrulanır.
Amaç: belirsiz bulgudan insan hakkında karara geçiş; **şüphe kanıt değildir, hiçbir NPC zorunlu değildir.**
İçerik: Daniel ve mevcut Elena Ward, Marcus Hale, Arthur Bell; 0–3 sakin. Yeni ziyaretçi/karakter/gizem basamağı yok.
Mevcut: Gün 3 kesintisi, kanıt/günlük, işler/yataklar, v5 gece ve Gün 4 sabahı.
Önerilen: aşağıdaki Gün 4 görüşme/karar akışı, mevcut yargı kapsamındaki izolasyon/kovma ve kayıt alanları.
Mevcut kodda `LAST_AUTHORED_DAY=3`; `_resolve_night()` Gün 4'te kesiti durdurur. Bu belge o kodu değiştirmez.

## 2. Değişmezler ve şiddet kararı

- Kampanya seed'i ve atanmış `infected` değerleri değişmez; Gün 3 nedeni/faili/snapshot/movement yeniden seçilmez.
- Görünüş, teknik beceri, yalan, susma, erişim veya düşük güven enfeksiyon teşhisi değildir.
- Ölü/kovulmuş/yok kişiler yeni olaya katılmaz; geçmiş kayıtları silinmez. İzole kişi normal iş/yardımcı sayılmaz.
- Olağan temas bulaştırmaz; Gün 4 Daniel maruziyeti yoktur. Enfekte Daniel fixture'ı mevcut durumunu korur.
- Lily kapsam dışıdır; K-001/K-002 koşulsuz korunur. Genel hedef seçicisine yanlışlıkla alınamaz.
- Devam/erteleme, onarımsız ev ve hiç sakin kabul etmemiş kampanya geçerli sonuçlardır.

GDD §10 yetişkin öldürme ve “PEGI 16 / ESRB M sınırının altında” ifadesini içeriyor; kesin derecelendirme belirsizdir.
DecisionLog'da bu kesit için açık yetişkin infaz onayı bulunmadı. **Öldürme etkinleştirilmez ve test kısayolu sunulmaz.**
Yetişkin öldürme kapsamı, gösterimi ve kesin yaş hedefi sahibin açık kararıdır; diğer üç karar bunun cevabını beklemez.

## 3. Giriş, ana olay ve çıkış

Giriş: `day==4`; aktif Gün 3 gecesi varsa `morning_resolved==true`. Sessiz uyku yolu da geçerlidir.
Saat, kaynak, enerji, eksiklik bayrakları ve çözülmemiş güç arızası aynen devralınır; ikinci tüketim yapılmaz.
Önerilen akış: `not_started → available → reviewing → deferred/resolved → completed`.
Daniel'ın odasındaki “Review last night” açılışı isteğe bağlıdır; zorunlu toplantı veya NPC teleportu yoktur.
`reviewing` paneli bilinen olguları, iddiaları, eksikleri ve güncel hedefleri gösterir; kapatmak ücretsizdir.
Ana olay kesinti kaydından doğan kaygıdır; bir kişinin suçluluğunun açığa çıkması değildir.
NPC açılışı yalnız oyuncu `power_failure` olgusunu açıkça paylaşmışsa kullanılır; paylaşım kaydedilir.
Uygun konuşmacılar kimliğe göre sıralanır; enfeksiyon/fail/güven seçimi etkilemez. Aday yoksa Daniel açar.
Uygunluk: resident, present, konuşabilir; devam eden işten çekilmez. İzole kişiyle yalnız kapı görüşmesi yapılır.
Yaralı/etkisiz kişide konuşabilirlik tanımlı değilse NPC konuşması atlanır; bilgi Daniel yolunda kalır.
Hedefi oyuncu seçer; varsayılan şüpheli yoktur. Hedefler mevcut ve erişilebilir yetişkin üçlüyle sınırlıdır.
Delilsiz suçlama mümkündür ama “unsupported” olarak kaydolur; olgu veya otomatik teşhis olmaz.
`deferred`: soruşturma açık; yeni bilgiyle tekrar inceleme mümkündür. `resolved`: karar var, diğer hedefler açık kalabilir.
20:00 sonrası ücretsiz “Complete Day 4 review” onayı; çözülmemiş soruşturma/onarım bunu engellemez.
`completed`: özet ve kesit sonu. Gün 5'e geçilmez, kaynak tüketilmez, yazılmamış gece raporu üretilmez.
İncelemeye dönülebilir; yeni karar kapanış özetini günceller, geçmiş kararları silmez. Tekrar kapanış ücretsizdir.

## 4. Mevcut kanıt ve tanıklığın gerçek nedeni

| Kaynak | İzin verilen yorum | Sınır |
|---|---|---|
| POWER_PANEL_LOOSE / ACCESS_CLEAR | Gevşek bağlantı/aşınma; yeni zorlama yok | Bir kişinin sağlık teşhisi değil |
| POWER_PANEL_GRID / OUTSIDE_DARK | Şebeke sorunu desteklenir | İçeride enfekte fail uydurulmaz |
| POWER_PANEL_TOOL | Çıkarılmış bağlantı, taze alet izi | Kişiyi veya enfeksiyonu belirlemez |
| POWER_ACCESS_UNKNOWN | Güvenilir tanık/kimlik belirleyen iz yok | Gizli movement.actor gösterilmez |
| POWER_OUTSIDE_LIT | Komşuda güç var | İçerideki kişinin eylemini göstermez |
| POWER_MARCUS_CLAIM | Teknik yorum; claim | Alternatif: ücretsiz sigorta kartı |
| POWER_INTERFERENCE | Müdahale şüphesi; suspicion | Fact veya kişi teşhisine yükselmez |
| POWER_WATCH raporu | Işık kaybı raporu; fail belirlenemiyor | Otomatik isimli görgü tanıklığı değil |
| PIPE_HEARD / PIPE_SOURCE | Duyulmuş ses / gevşek destek titreşimi | İnsan yürüdü veya saldırı oldu denmez |

Fiziksel bulgular kaydedilmiş elektrik nedeninden; boru sesi `pressure_shift_in_loose_pipe_support` nedeninden gelir.
Gece uyuyan Daniel'a duyma kaydı eklenmez. Boru incelemesi mevcut uygunluk koşulu izin vermiyorsa zorlanmaz.
Mevcut snapshot bağımsız tanığın uyanıklığını/görüş hattını/gözlem anını saklamaz; geçmişe tanık eklenmez.
Bu kesitte “I saw Marcus at the panel” gibi yeni isimli görgü tanıklığı **yoktur**.
Özgün Gün 4 gece hareketi suçlamasının tam uygulama bağımlılığı: gelecekteki yeni Gün 3 oturumunda,
iki uygun sakin varsa, masum banyo ziyaretinin hedefi ve uyanık gözlemcisi olay anında kaydedilir.
Hedefin hareket nedeni banyo ihtiyacı; gözlemcinin orada bulunma nedeni boru sesi sonrası koridor kontrolüdür.
Saat/rota/oda erişimi/görüş hattı, hedefin sonradan neden inkâr ettiği (suçlanma korkusu) ve gerçek gördüğü şey
aynı kayıt içinde saklanır. Seçim enfeksiyondan bağımsızdır; izole/ölü/yok kişi ve imkânsız rota dışlanır.
Bu hareket/gözlem sistemi henüz yoktur. Yoksa veya eski kayıtsa inceleme ve kaygı yolu geçerli fallback'tir;
bu fallback tam suçlama sahnesi teslimi sayılmaz. Gelecekteki isimli ifade pano sabotajını gördüğünü iddia etmez.
Yeni görüşmeler şimdiki kaygı, teknik yorum veya cevap üretir; iddia olarak tutulur, geçmiş gözleme dönüştürülmez.
Suçlamanın gerçek dayanağı oyuncunun seçtiği gözlem veya açıkça paylaşılan kesinti kaydıdır; gizli enfeksiyon değildir.
İsimli tanıklık ileride yazılırsa olay anındaki observer/subject/action/time/room/sightline/awake/access ve orada bulunma nedeni gerekir.
Bu kayıtlar yokken “no reliable witness” korunur; yeni tanık sistemi Gün 4 teslim bağımlılığı değildir.
NPC'siz yol: tesisat → ücretsiz kart → pano 10 dk / erişim 5 dk / dışarı 5 dk → günlük → karar/erteleme.
Önceden incelenmiş bulguyu okumak ücretsizdir. Kart kişi kimliğini açmaz; teknik yorumun alternatifidir.
`legacy_skipped` kayıtta olay/iz uydurulmaz; kayıt eksikliği açık gösterilir, continue/complete çalışır.

## 5. Süre, kaynak ve maliyetler

**D4-V değerleri önerilen küçük dengeleme varsayımlarıdır; mevcut kod veya sahip onayı değildir.**
Yürüme, günlük okuma, hedef seçimi, onay ve iptal ücretsizdir; süreli eylem tamamlanınca bir kez ücretlenir.
Faz aşılacaksa bitiş saati önceden gösterilip onay alınır. Süre yetmezse işlem başlamaz; kısmi bedel yoktur.
Mevcut `get_action_time_limit()` korunur; Gün 4'e aktif gece eklemek için yalnız saat sınırı büyütülmez.

| İşlem | Süre | Kaynak/sonuç | Dayanak |
|---|---:|---|---|
| Kart / günlük tekrar okuma | 0 | Yok | Mevcut |
| Pano / erişim / dışarı ilk inceleme | 10 / 5 / 5 dk | Yok | Mevcut |
| Gücü düzeltme | Uygun istekli Marcus 25, solo 35 dk | Nedene göre 1 repair / 1 fuel | Mevcut quote |
| Kısa / uzun görüşme | 10 / 20 dk | Benzersiz konu ilk kez; tekrar okuma ücretsiz | D4-V1 |
| Açık suçlamayı kayda geçir | 10 dk | Hedef güven −5, kişi başına bir kez | D4-V2 |
| Soruşturmaya devam | 0 | Tanı/ceza/ödül yok | D4-V1 |
| İzolasyon odasını hazırla | 30 dk, bir kez | 1 repair | D4-V3 |
| İzole et / günlük kontrol | 15 / 15 dk | İlk yerleştirme kontrolü içerir; hedef güven −10 bir kez | D4-V3 |
| Salıver | 10 dk | Güven iadesi ve otomatik iş başlangıcı yok | D4-V3 |
| Evden çıkar | 15 dk | Hedef güven −20; iş/yatak kaybı; stok iadesi yok | D4-V4 |
| Ayrı yatak/iş planı değişikliği | 15 dk | İzolasyon işlemine ayrıca bindirilmez | Mevcut |

İzolasyon güvenli oda, Daniel'ın kontrol zamanı ve iş gücü kaybına mal olur; ikinci NPC zorunlu değildir.
Günlük kontrol yapılmazsa care_due uyarısı kaydolur; otomatik ölüm/kaçış/şiddet yoktur. Sürekli nöbet iddia edilmez.
İzole kişi resident kalır; sabah kişi başı 1 food/1 water tüketmeye devam eder. Ek erzak vergisi yoktur.
Kovma yalnız sonraki tüketimin headcount'unu azaltır; önceki tüketim iade edilmez, zorunlu ayrılık paketi yoktur.
Sıfır repair ile hazırlık yapılamaz; kart/inceleme/kovma/erteleme açık kalır. Bedava kaynak üretilmez.
Örnek: 07:00 + ilk üç inceleme 20 + kısa görüşme 10 + hazırlık 30 + izolasyon 15 = 08:15 ve 1 repair.
Üç sakin izole kişi dahil evdeyse sonraki tüketim Daniel ile 4/4; biri kovulmuşsa 3/3 olur.

## 6. Oda, yatak ve iş tutarlılığı

Tesisata yalnız mutfaktan mevcut 2D geçişle girilir; erişim ihtimali tanıklık sayılmaz.
Normal görüşme `get_location()` odasındadır; iş konumu ile uyku odası karıştırılmaz.
İzolasyon en çok bir kişidir. `status=resident`, `isolated=true`; mevcut yatak rezerv kalır, `npcs.room` korunur.
Önerilen `get_location()` önceliği izolasyon → aktif iş → yatak odasıdır; izolasyon normal kabul yatağı değildir.
Yönetim ekranı rezerv yatağı ve izolasyonu ayrı gösterir; izole kişiye iş/yatak taşıma sunmaz.
Yerleştirme tamamlanmamış işi iptal eder, ürün/rapor vermez; tamamlanmış iş geçmişini silmez.
Karar tam iş bitiş dakikasındaysa önce o ana kadar biten işler bir kez çözülür, sonra karar uygulanır.
Mevcut `_complete()` filtresi tek başına yeterli değildir; check_plan/why_refuses/occupants/yardımcı müşterileri de uyarlanmalıdır.
Salıverme rezerv yatağı doğrular; bozuk/doluysa başka kişinin yatağını almaz, geçerli yönetim onarımı ister.
İzolasyon eski blocked_rooms/access_locked/utility_locked değerlerini silmez; salıverme eski kısıtları korur.
Daniel'ın kart/inceleme yolu NPC izolasyonuyla kapanmaz; oda hatasında Daniel panelinden güvenli yönetim yolu kalır.
Mevcut sanat hazır yatak içermez; oda hazırlığı yeni yatak kapasitesi/görseli varmış gibi sunulmaz.
Uzun süreli konfor ve gece gözetimi ayrı bağımlılıktır; bu kesit bir günlük tedbiri tanımlar.

## 7. Karar onayı ve durum varyantları

Quote: hedef, gün/saat, kanıt kimlikleri, süre, kaynak, iş, yatak ve oda durumu; commit öncesi tekrar doğrulanır.
Değişen quote eski onayı geçersiz kılar. Varsayılan Cancel; Esc ücretsizdir. Belirsiz ikinci tık kovma onayı değildir.
İzolasyon hazırlığı ayrı onaydır; hazırlamak kimseyi taşımaz. Dolu oda/aynı hedef tekrarında yeni bedel alınmaz.
Expel onayı isim, bitiş saati, iş iptali, boşalacak yatak ve kesitte geri alınamayacağını açıklar.
Expel: mevcut remove_npc(expelled) yanında izolasyon kaydı da temizlenir; dışarıda öldüğü/teşhis edildiği söylenmez.
İzole kişide kapı görüşmesi/kontrol/release/expel; absent/incapacitated kişide fiziksel karar ertelenir.
Dead/rejected/left/expelled/unknown yeni hedef veya konuşmacı değildir; eski ifadeleri salt okunur kalır.
Marcus yoksa solo/kart; Arthur yoksa panel açıklaması; Elena yoksa görüşmesi atlanır. 0 sakinle tüm çekirdek yol açıktır.
Elena'nın eski yalanı V-024'teki belirsizlik nedenini korur; yeni itiraf veya enfeksiyon belirtisi yapılmaz.
Sağlıklı/enfekte kişiler aynı gözleme aynı temel cevabı verir; susmak/red suç göstergesi olmaz.

## 8. İngilizce oyun metni taslakları

Anahtarlar öneridir; henüz strings.csv/JSON'a eklenmemiştir. Argümanlar yalnız görünür veri ve Roster isimleridir.

| Key | English draft | Türkçe karşılık / koşul |
|---|---|---|
| D4_OPEN | The lights went out. What happened still needs to be understood. | Işıklar söndü; ne olduğunu anlamak gerekiyor. İnsan fail varsayılmaz |
| D4_CONCERN | You've shown me the outage record. What will you do? | Kaydı gösterdin; ne yapacaksın? Yalnız paylaşılmış bilgi |
| D4_UNSUPPORTED | No supporting observation selected. This is an accusation, not a finding. | Destekleyici gözlem yok; bu bir suçlama |
| D4_ELENA | Ask me what I know. What I don't know isn't proof. | Bildiğimi sor; bilmediğim kanıt değildir |
| D4_MARCUS | I know wiring. That doesn't tell you whose hands were on it. | Elektrikten anlamam kimin dokunduğunu söylemez |
| D4_ARTHUR | Let's separate what we saw from what we fear. | Gördüğümüzle korktuğumuzu ayıralım |
| D4_NO_WITNESS | No reliable witness identifies a person. | Güvenilir tanık kişiyi belirlemiyor |
| D4_CONTINUE | Keep investigating. Leave the accusation unresolved. | Araştırmayı sürdür; suçlamayı açık bırak |
| D4_ISOLATE | Isolate {name}? {minutes} minutes. Work stops; their bed stays reserved. Food and water are still needed. | Süre, iş kaybı, rezerv yatak ve tüketim açık |
| D4_EXPEL | Expel {name}? {minutes} minutes. Work stops and their bed is freed. You cannot bring them back in this slice. | Geri dönüşsüz sonuç açık |
| D4_LEGACY | No incident was recorded. You can leave the question open. | Kayıt yok; soru açık kalabilir |
| D4_END | Day 4 review complete. The next night is not included in this build. | Dürüst kesit sonu |

## 9. Event/save ve hata kurtarma sözleşmesi

Yeni yerel AccusationSession; yeni autoload yok. İçerik veri dosyalarında, kalıcı durum GameState içinde önerilir.
`day4_accusation`: schema=1, id, day=4, state, entry_mode(recorded/legacy), opened_at, completed_at,
shared_fact_ids, conversations[{id,npc,topic,time,key}], accusations[{target,basis_ids,unsupported,time}],
decisions[{transaction_id,target,action,time,quote,basis_ids}], applied_transactions, outcome(open/no_action/precaution/expulsion/mixed).
`isolation_state`: prepared, occupant, reserved_bed, entered_at, last_check_day, care_due; tek occupant.
Yerel event'ler: claim_recorded/decision_committed/isolation_changed/review_completed; gizli fail verisi taşımaz.
Günlük mevcut id/key/kind/day/minutes yapısını korur; isimli satırlar için args desteği ve katalog genişletmesi gerekir.
Mevcut EvidenceManager args render etmez; önceden biçimlenmiş İngilizce save edilmez. Claim fact'e yükseltilmez.
Entegrasyonda sürüm hâlâ 5 ise v6 adaydır; eski v1–v5'e boş alanlar, Gün 4'te gönüllü giriş uygulanır.
Eski gün>4 kayda Gün 4 kararı/gece/kanıt eklenmez; legacy işareti korunur. Seed/enfeksiyon/kaynak değişmez.
Doğrulama: tür/enum/izinli ID, zaman sırası, gerçek evidence referansı, benzersiz işlem, resident/isolated/rezerv yatak eşliği.
Onay/modal save edilmez; yüklemede yeni quote gerekir. Her maliyet ve güven etkisi transaction başına bir kez uygulanır.
Mevcut save_game doğrudan yazar; atomik garanti yoktur. Geri dönüşsüz karar için gerekli uygulama bağımlılığı:
aday durumu doğrula → geçici dosyaya yaz/doğrula → güvenli dosya değişimi → canlı durum/sinyalleri yayımla.
Yazma hatasında eski dosya ve canlı durum korunur; Retry/Cancel, bedel yok. Bozuk yükleme kısmi mutasyon yapmaz.
Kaynak yetersizse defer; oda doluysa release/continue; hedef değiştiyse quote iptal; eksik metinde nötr hata ve panele dönüş.
Gelecek Gün 4 gecesi ayrı entegrasyondur: ölü/kovulmuş/izole aktör yok, Day3 olayları tekrarlanmaz, tek sabah tüketimi korunur.

## 10. Kabul matrisi ve teslim ölçütü

| Test | Kurulum / beklenen sonuç |
|---|---|
| A1 | Üç kişinin 8 resident alt kümesi: 0–3 sakinle giriş/continue/complete; zorunlu kişi yok |
| A2 | Aynı seed, ters sözlük sırası, save/load: aynı seçim; enfeksiyon ve Day3 gerçekliği değişmez |
| A3 | Üç elektrik nedeni × bulunmuş/kaçırılmış kanıt: yalnız görünür bilgi; fail/teşhis sızıntısı yok |
| A4 | POWER_WATCH/ACCESS_UNKNOWN ve boru bulgusu: isimli tanık/insan fail uydurulmaz; uyuyana duyma verilmez |
| A5 | Marcus yok/ölü/kovulmuş/izole/yorgun/isteksiz: kart/solo yol açık; enfeksiyon yardım ölçütü değil |
| A6 | Kaynak 0, güç kapalı, süre tam/yetersiz: ücretsiz bilgi yolu açık; bedel atomik, negatif stok yok |
| A7 | İptal/Esc ve quote sonrası kişi/saat/iş değişimi: bedelsiz iptal veya yeni onay |
| A8 | İzole et/tekrar/ikinci hedef: tek occupant, rezerv yatak, iş iptali, tüketim değişmez; tekrar ceza yok |
| A9 | Release/expel: eski kilitler korunur; kovmada yatak/iş/izolasyon temiz; stok iadesi yok |
| A10 | İş bitişi karar anında/sonrasında: biten iş tek ürün; iptal iş sıfır ürün |
| A11 | Göç ve bozuk occupant/bed/ID/transaction: geçmiş korunur veya yükleme atomik reddedilir |
| A12 | Disk/yazma/değiştirme hatası ve çift tık/reload: eski geçerli kayıt veya tek yeni işlem; yarım karar yok |
| A13 | 20:00/23:59, açık soruşturma: kapanış mümkün; Gün 5 tüketimi/raporu yok; tekrar ücretsiz |
| A14 | en/tr 1080p/1440p ve klavye/fare: modal taşmaz, olgu/iddia ayrılır, kontrol geri gelir |
| A15 | Gün 1–3 regresyonu ve gece sınır save/load: ziyaret/iş/yatak/enerji/tek tüketim korunur |

Uygulama bitti ölçütü: testler, gerçek render incelemesi, 0 ve 3 sakinle elle akış ve kayıt-hata sınaması birlikte geçer.
Bu belge tesliminde motor testi yapılmadı; kaynak tutarlılığı ve belge biçimi kontrol edildi.
Sahip kararı gereken açık konu: yetişkin öldürme, kesin yaş hedefi ve gösterim sınırı. Yeni yaratıcı yön önerilmez.
D4-V süre/maliyet/güven değerleri ana ajanın inceleme/playtest varsayımlarıdır; uzun vadeli izolasyon gecesi ayrı bağımlılıktır.
Sonraki somut adım: ana ajanın bu belgeyi incelemesi; ardından ayrı kod görevi. Koordinasyon/commit ana ajana aittir.
