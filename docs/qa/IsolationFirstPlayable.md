# Gün 4 — ilk izolasyon akışı

## Teslim ve kurulum

Küçük odada hazırlama: iki basış, 30 dakika ve 1 repair. Hazırlık tek kişilik kapasiteyi etkinleştirir; kimseyi taşımaz. Sonra uygun üç yetişkinden birinin bulunduğu odada yerleştirme seçilebilir: iki basış, 15 dakika. İlk yerleştirmede hedef güveni −10; tekrar döngüde güven bedeli tekrarlanmaz. Salıverme küçük odada 10 dakika ve ayrı onay ister. Başka eylem/oda çıkışı/oyun görüntüsü değişimi eski onayı geçersiz kılar. Kaydetme başarısızsa canlı etki yoktur.

Dosyalar: scripts/shelter/isolation.gd; resources/events/isolation.json; campaign_director.gd, resident_judgment.gd; core/game_state.gd; save/save_manager.gd; shelter/shelter_manager.gd; ui/shelter_view.gd; localization; tests/isolation_test.gd/.tscn; Run-Tests.ps1. RefCounted Isolation CampaignDirector'a aittir; yeni autoload veya Node gerekmez. Godot 4.7.2 içe aktar, Gün 4'te üst kattaki küçük odayı aç. Hazırlama/yerleştirme/salıverme tüm bağımlılıkları kaynakta vardır.

## Oda, kapasite ve iş

İzole kişi resident kalır; npcs.room eski yatak odasıdır, get_location önceliği isolation olur. Eski yatak rezerv kalır, boş yatak artmaz. Headcount ve günlük food/water ihtiyacı değişmez. Yerleştirme bitmemiş işi iptal eder; eski iş/ürün veya güven salıvermede geri gelmez. Yönetim ekranı rezervi açıkça etiketler; yatak ve iş seçicisi sunmaz. API düzeyinde de değişiklik reddedilir. PowerIncident zaten izole yardımcıyı dışlar. İzolasyondaki yetişkin mevcut evden çıkarma akışıyla çıkarılabilir; rezerv ve isolated bayrağı temizlenir. Çocuklar hedef değildir.

Yeni durum alanı yerine mevcut flags/npcs alanları: isolation_ready, isolation_sequence, isolation_first_<npc>, npcs[id].isolated. İşlem kimliği sırayla benzersizdir. Kayıt sürümü 5; eski kayda izolasyon eklenmez. Yükleyici isolated türünü, en fazla bir occupant, resident/rezerv yatak eşliğini, hazır oda ve işsizliği doğrular. Eski geliştirme fixture'ında yalnız isolated=true yazıp yatak/hazırlık bırakmamak geçerli ürün kaydı sayılmaz.

## Test ve sınırlar

Test, sağlıklı/enfekte eşit davranış, ücretsiz ilk basış/iptal, tek hazırlık maliyeti, tek konum, rezerv ve tüketim, iş reddi ve yatak taşıma engeli, save/load, ikinci occupant reddi, salıverme/tekrar yerleştirme ve izolasyondan kovmayı sınar. Geçersiz rezerv/ikinci occupant yazımı eski geçerli kaydı bozmaz. Yönetim etiketini ve en/tr 1080p/1440p release onayını kontrol eder. Gerçek disk arızası ortak I/O hata enjeksiyonundan farklıdır; elle oynama yapılmadı.

Sık hata: npcs.room'u isolation yapıp eski yatağı kaybetmek, resident yerine özel durum yazarak gıda sayımından düşürmek veya UI seçicisini gizleyip API'yi açık bırakmak. Bu teslim bunları önler.

## Açık işler

Küçük oda resmi eski geçici sanattır; hazırlanmış yatak/sağlam kilit modeli veya hareket animasyonu oluşturulmadı. Bu sürüm kural/arayüz düzeyinde tek günlük izolasyondur; görsel hazırlık katmanı eksik. Günlük bakım görüşmesi, uzun süreli rahatlık/gözetim, kaçış olayları, fiziksel NPC merdiven hareketi, kişisel izolasyon diyaloğu ve genel gece yönetmeni tamamlanmadı. Gün 4 sonrası gece hâlâ kesit dışıdır. Bu nedenle kusursuz veya uzun vadeli izolasyon sistemi teslim edildi denmez. Sonraki bağımlılık: bakım ve kişisel tepki, gerçek gece tanığı, nihai oda sanatı.

Son doğrulama: 20 paket/5946 denetim geçti; isolation paketi 43. GPU capture 47 geçti; TR1080p incelendi. İlk render'daki 2 CanvasItem/4 ObjectDB çıkış uyarısı, erken dönen yönetim satırından önce oluşturulmuş boş VBox düğümüne bağlandı ve giderildi. Aynı gerçek render tekrarında uyarı yok. Son yerel düzeltme yalnız bu düğümün oluşturma yeridir; tam regresyon öncesindeki sürümden sonra hedef paket/GPU yeniden çalıştırıldı.
