# Açık suçlama — DAY4-ACCUSATION-001

## Hedef ve sınır
Day4Design §5 açık suçlama/dayanak kaydı ve §8 kişisel yanıtları uygulanır. Bu, izolasyon/kovmadan ayrı bir konuşma kararıdır; otomatik teşhis/ceza/şiddet yok.10dk ve ilk güven−5, tasarımdaki D4-V2 küçük dengeleme varsayımıdır; nihai denge veya ayrı sahip onayı gibi sunulmaz. Değerler resources/events/accusation.json içindedir. Tam Gün4 tahliye radyo yayını ve kalan kampanya henüz yok.

## Dosya ve hiyerarşi
scripts/narrative/accusation.gd: CampaignDirector.accusation RefCounted, ShelterManager enjekte edilir. get_room_actions hedefin gerçek odasında accuse:id sunar. Tamamlanan hedefte aynı eylem ücretsiz yanıt tekrarına dönüşür.

scripts/ui/accusation_view.gd: HouseBlockout tarafından oluşturulan AccusationView(CanvasLayer24)→shade + VBoxPanel→title/guide/ScrollContainer→basis rows(CheckBox+Label)/status/buttons(Cancel,Review-Confirm). Yeni autoload veya görsel varlık yok. EventBus.accusation_requested(room,id) gerçek açık RoomView ile eşleştirilir. completed(content) RoomView.show_response üzerinden aynı odada kişisel yanıtı gösterir. RoomView input modal açıkken odadan çıkmaz; modal Escape önce kendini kapatır. Room kapanışı ve day_started/yükleme modal/teklifi iptal eder.

scripts/core/{event_bus,game_state}.gd: sinyal ve iç içe sayı dönüşümü. scripts/dev/house_blockout.gd: sahne-yerel bağlantı ve kontrol kilidi. scripts/narrative/campaign_director.gd: aday seçim/oda eylemi. scripts/evidence/evidence_manager.gd: yeni claim kataloğu. scripts/save/save_manager.gd: Accusation.valid_state. resources/events/accusation.json ve resources/evidence/accusation.json: içerik/kurallar. localization/strings.csv:18EN/TR anahtarı. tests/accusation_test.gd/.tscn; tools/Run-Tests.ps1.

Kurulum Godot4.7.2 import ve mevcut Start-Game. Gerekli önceki sistemler: GameState/SaveManager/EvidenceManager, NightWitness, Day4Review ve ShelterManager.project_daytime; hepsi gerçek dosyadır. Kod tam kaynakta, yeni harici eklenti yok.

## Davranış ve dayanak doğruluğu
Yalnız Gün4 mevcut, konuşabilir Elena/Marcus/Arthur; absent/injured/incapacitated/busy ve aktif gündüz işindeki kişi dışlanır. Gelecek gece nöbeti ataması gündüz konuşmayı engellemez; gece gerçekten nöbetteyse engeller. İzole kişi yalnız isolation odasında kapıdan cevap verebilir; yerinden çıkarılmaz. Çocuklar/diğer roster bu ilk kapsamın hedefi değildir. Ölü/kovulmuş/yok kişi yeni söz söylemez; geçmiş kaydı kalır.

Seçenek açılması ücretsiz; boş seçim geçerlidir. Yalnız hâlihazırda toplanmış ve izinli kaynak kataloğundaki kayıtlar listelenir. Kendisi/başka suçlama yeni suçlamaya kanıt yapılamaz. Yinelenen veya bulunmayan ID reddedilir. Genel elektrik/boru bulguları kişiyi belirlemez, seçilse de unsupported kalır. Kişiye ilişkin dayanak yalnız gerçek NightWitness.subject ile eşleşen ve gerçekten görüşülmüş observer claim seçildiğinde tanınır. Bunun anlamı yalnız hareket hakkında bir tanık iddiasıdır; sabotaj/enfeksiyon ispatı değildir. Hedef başkaysa aynı ifade ona iliştirilmez. UI ve journal bunu açıklar.

Cancel varsayılan klavye odağıdır. Review accusation ücretsiz ve süre/güven etkisi/sınır açıklamasını gösterir; ikinci açık Confirm uygulanır. Seçim veya dil değişince teklif sıfırlanır. Durum değişirse eski quote kaydedilmez; hata ve yeniden gözden geçirme. Room/Escape/load iptali ücretsiz. Tab odağı checkbox ve iki düğme arasında kalır. Boş listede iptal edip araştırma yolu görünür.

İlk onay10dk ve hedef güven−5 (−100 tabanı), tek kez. Diğer kişilerin bu arada biten gündüz işleri aynı adayda çözülür, time_changed sırasında ikinci kez çözülmez. Erzak/oyuncu enerji/enfeksiyon/yatak/konum/izolasyon değişmez. Bekleyen gece işi tamamlanmış gibi raporlanmaz. Aynı kişiye tekrar eylem yalnız kaydedilmiş kişisel yanıtı okur; bedel yok. Elena bakım/dinlenme, Marcus somut suçlama/teknik bilgi sınırı, Arthur olgu/korku ayrımıyla farklı cevap verir. Yanıtın farklı olması enfeksiyon işareti değildir; sağlıklı/enfekte aynı temel yanıt.

## Kayıt ve hata
flags/day4_accusations[target]: target,day,started_at,completed_at,room,basis_ids,unsupported,trust_before,trust_after. Girdi dayanakları oyuncunun seçimi olarak saklanır; sonuç veya teşhis gibi değil. Evidence kaydı ACC_CLAIM_UNSUPPORTED veya ACC_CLAIM_TESTIMONY, typeclaim, name arg. Bu kayıt aynı zamanda Daniel tarafından suçlanma belleğidir. Şema5 optional dictionary, eski kayda suçlama eklenmez. Yüklemede tam sayılar normalize edilir; tam state eşitliği testlidir.

SaveManager.commit_candidate önce aday doğrular/yazar, ardından canlı durum. Disk yazma hatasında saat/güven/iddia/karar yok; modal açık kalır ve yeni review gerekir. Kaynak ID/tarih, tekillik, süre, trustclamp, hedef/oda, kişiye dayanak sınıfı ve claim eşliği semantik doğrulanır. Geçmiş hedefin sonradan kovulması/ölmesi kaydı bozmaz. Load aktif teklifi geri getirmez. Enfeksiyon hiçbir seçme/yanıt/sonuç hesaplamasında okunmaz; sabit kalır.

## Deneme ve QA
Gün4 hedefin odasına git→Accuse→varsa kayıtları seç→Review→Confirm; hedef cevabı aynı odada, Tabgünlükte iddia olarak. Sonra yeniden aynı eylem ücretsiz. Kaydı yeniden açınca tekrar bedel alınmamalı. Bir sonraki hedefte Cancel/Escape ile hiçbir değişiklik olmamalı. Boş dayanak ve genel güç bulgusu unsupported; gerçek gece tanığı yalnız onun gördüğü kişiye bağlı.

Test: üç yetişkin×sağlıklı/enfekte, açma/quote/iptal/Escape ve oda korunumu, ilkbedel/reread/eşityükleme; yok/ölü/kovulmuş/yaralı/busy/aktifiş/çocuk, gelecek nöbeti; kayıtsız/duplicate dayanak, seçim/stalequote, diskhatası, loadcancel, süreyetmeme, trusttabanı/izolasyon ve diğerişbitişi. Gerçek Gün3 nöbeti+görüşme üzerinden destekli hareket iddiası, yanlışkişiye dayanak, aynıquoteçiftuygulama, bozukrecordsemantics, kovulma sonrasıgeçmiş. GerçekTabodağı ve EN/TR720p/1080p/1440p modal taşması. GPUiki dil ekranı incelenir; elle baştan sona oynama sayılmaz.

Sık hata: Gece tanık hareketini bilmeden WITNESS_OBSERVER gösterilmez; önce yeni nöbet ve gerçek görüşme gerekir. NPC aktif işteyse işin bitmesini bekle. Yeterli dakika yoksa işlem başlamaz. İngilizce anahtar görünürse CSV import et. Kamuya açık kesin enfeksiyon olasılığı gösterilmez.

Bitti ölçütü testler+regresyon+gerçekGPU+launcher sürümü+Git/devir. Sonraki bağımlılık Gün4 radyosu ve üç ana karakterin daha geniş yazarlı olaylarıdır; genel ilişkiler veya tüm14gün tamamlanmadı.

Görsel QA: Varsayılan seçim kutuları koyu zeminde silik bulundu. assets/icons/evidence_checked.svg ve evidence_unchecked.svg özgün24px kaynak vektörlerdir; raster AI üretimi veya dış kaynak varlık değildir. CheckBox checked/unchecked tema override sözleşmesi resmi belgeyle doğrulandı: https://docs.godotengine.org/en/stable/classes/class_checkbox.html . Birleşik ikon+test komutu çalıştırılmadan otomatik denetim tarafından blocked by policy ile reddedildi. Aynı komut tekrar denenmedi; dosyalar apply_patch ile, test ise mevcut Run-Tests aracıyla ayrı tamamlandı. Önceki oyun/kanıt mantığı bu okunabilirlik düzenlemesinde değişmedi.

Sonuç:27paket/6809 gerçekWASAPI PASS, accusation139; GPU141(iki yakalama dahil)PASS. EN/TR nihai ikonlu görüntüler incelendi; seçimler okunur. Günlük C:\Users\eyups\AppData\Local\Temp\tqh-tests-6ff2d9bbfbf3412d80ef8163cae50548, makine kanıtı accusation-last-run.json. Yeni etiketler nedeniyle NightWitness testindeki dinamik düğme sınaması83→89 ve localization sayısı da artar; önceki kontroller gevşetilmedi.
