# Elena B — temkinli ilk geliş / 0.1.15 adayı

## Amaç ve sahip kararı
Sahip karşılaştırmadaki ORTA/B stilini seçti; ilk gelişte daha şüpheli görünüm ve konuşma istedi. Onaylı yön kalın kontur, keskin sade gölge, fotogerçekçilik/piksel olmaması. Sağlıklı birinin korkusu/kişisel sırrı da şüpheli görünür; bu sunum enfeksiyon testi değildir. Kliniği ve kayıp kardeşi kanonu korunur. Kendisi kardeşini ölü anlatsa da bu yazarın doğruladığı ölüm değildir.

## Dosyalar ve bağımlılıklar
- assets/characters/elena_ward/graphic/{room,arrival}.png: iki gerçek1024×1536RGBA sprite; eski default.png silinmedi. arrival çantalı/omzu kapalı/geri çekilmiş; room daha sakin eller belde. Gerçek alfa köşelerde0, gövde merkezinde253; araç PNG'si rötuşsuz kopyalandı.
- resources/characters/character_art.json: Elena room/arrival bağları. Diğer NPC'ler mevcut default.png ile sürer.
- scripts/art/character_art.gd: saf texture_path(npc_id,context) çözücü. Gizli enfeksiyon, güven veya kampanya bilgisine erişmez. Bilinmeyen context→room; kaynak yok→eski default.
- scripts/art/room_world.gd: make_figure artık isteğe bağlı context alır, varsayılan room. Aynı RoomWorld kapı aralığı ve oda tam ekranında kullanılır.
- scripts/ui/peephole_view.gd: kapıdaki mevcut visitor için arrival context. Sadece görüntü; yeni ziyaret/kanıt/teşhis üretmez.
- scripts/ui/dialogue_view.gd: *_arrival konuşmalarında arrival, diğerlerinde room. Mevcut AtlasTexture bel üstü kırpma korunur. Geliş konuşması kabul satırına ulaşsa bile bitene kadar arrival kalır; sonraki oda konuşması room kullanır.
- localization/strings.csv ve EN/TR çeviriler: sekiz ilk geliş metni değişti. “İçeride yalnız mısın?”, kısa kimlik bilgisi, spor salonundan ayrılış ve kardeş konusunda yarım kalan ifade. Yeni koşul/flag/bedel/kanıt veya mekanik sonuç yok; elena_arrival.json değiştirilmedi.
- tests/character_art_test.*, mevcut test koşucu listesi: bütün gerçek tüketiciler, alfa, bağlam ve enfeksiyondan bağımsızlık.
- scripts/dev/elena_review.gd + scenes/dev/elena_review.tscn: yalnız TheQuietHours-Tests/ altında çalışan gerçek UI incelemesi. Gerçek kabul akışını kullanır; otomatik kayıt varsa yalnız izole QA alanına yazar.
- docs/art/elena-selected-b/: tam üretim istemleri ve SHA256 köken manifesti. Dahili image_gen; CLI/API kullanılmadı.

Hiyerarşi: HouseBlockout → RoomView/RoomWorld/RoomFigure (room); DialogueView/TextureRect/AtlasTexture (context); FrontDoor/Peephole/PeepholeView/ExteriorViewport/visitor_slot/RoomFigure (arrival). Yeni global singleton yok. Mevcut Roster, Settings, GameState, EventBus, DialogueRunner ve PNG importları yeterlidir. Ek editör düğümü kurmak gerekmez; Godot4.7.2 import eder.

## I05 entegrasyonu
Claude3ca1dcf veranda/sokak,72fbbd3 Codex WIP kayıt ve930b8c1 gece/kesinti tinti alındı. Bakış: giriş kapısındaki küçük fiziksel deliğe E; kapı kanadının diğer alanında eski E yanıtlama sürer. Boş sokak da izlenir. Kapı açılmaz, saat/kaynak/ilişki değişmez; Escape veya Geri dönüş. Yürüyüş kamerası/FOV değişmez, balık gözü yalnız optik görünümde. Viewport kapanınca UPDATE_DISABLED.
Veranda ve saksılar geçici primitif sahne varlıklarıdır; nihai dış mekân sanatı diye sunulmaz. Şebeke kesintisinde karşı sokak lambasının bağımsızlığı açık inceleme konusu, Claude'a ayrı dar düzeltme istendi. I11 koridor daraltması ve I10 ek dekor bu teslimde yok.

## Doğrulama
İlk yeni CharacterArt testinde var olmayan advance() çağrısı yaptım; yalnız test yardımcısındaki hata,90s zaman aşımıyla kaldı. Mevcut gerçek API choose(0) ile düzeltildi; bu başarısız koşu geçti diye sayılmadı.
Son seçili5paket+WASAPI PASS: door49,peephole31,character_art32,presentation89,campaign101,audio35 (runtime/elena-guarded-focused-tests.log). Karakter testi hem healthy hem infected altında aynı ilk poz/karşılama ve çizimin kampanyayı değiştirmemesini kontrol eder. Eski kabul/ret, soru süresi, yatak ve güven etkileri campaign testinde korunur.
Native Forward+/GTX1080Ti1920×1080: ELENA REVIEW PASS,stderr boş, beş gerçek UI PNG: doorstep/greeting/questions/resident/resident-dialogue. Önceki capture yardımcısı oyuncuyu başlangıç koridorunda bırakıyordu; gerçek kapı önüne taşındı ve beş görüntü yeniden üretildi. Çıktılar docs/qa/elena-graphic/ altında, rötuş yok. Bu60FPS veya tüm kampanya elle oynama iddiası değildir.
Geniş35paket koşusu runtime/elena-guarded-full-tests.log; henüz sonuç bitmiş sayılmaz, tamamlanınca aşağıya kaydedilecek.

## Deneme ve sınırlar
Aktif sürüm0.1.15'e bağlandıktan sonra oyunu kapatıp masaüstünden yeniden aç. Gün1 18:00 Elena ziyareti; kapı deliği→geri→normal kapı konuşması→kabul/ret. İlk gelişi geçmiş eski kayıt metinlerini tekrar oynatmaz; kabul edilmiş Elena'nın oda çizimi yeni kaynağı kullanır. Yeni oyun zorunlu değildir; eski enfeksiyon/takvim/sakinler korunur.
Bitti ölçütü: seçilmiş B stili gerçek kaynaklara bağlı, kapı/konuşma/oda aynı kimliği kullanır, EN/TR ve eski karar etkileri geçer, native görüntü incelenir, aktif launcher doğrulanır. Bütün NPC'ler/pozlar ve bütün evin sanat kabulü bu ölçüte dahilmiş gibi gösterilmez. Sonraki bağımlılık aynı onaylı stile Marcus/Arthur dönüşümü; oturma/uyku/iş pozları ayrı I06.
## Son birleşik sonuç
35paket/7756raporlanmış kontrol WASAPI PASS, süreç0 (runtime/elena-guarded-full-tests.log; tqh-tests-651b2285726f4e3cb03e6527fc810c38). Güncel oyun/varlık/test kodu tam koşuda yer aldı; sürüm ve teslim belgeleri sonra güncellendi. Kaynak EN/TR .translation dosyalarının bu koşuda ithal edilenlerle SHA256 eşitliği doğrulandı. Final native5görüntüde gerçek kapı önü konumu, çantalı ilk geliş ve daha sakin oda pozu incelendi; stderr boş. FPS/tüm kampanya elle oynama ve bütün sanatın tamamlanması iddia edilmez.
